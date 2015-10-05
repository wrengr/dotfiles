#!/usr/bin/perl -w
# mailcount.pl for Irssi, author: Marcin "derwan" Ró¿ycki (e-mail: derwan@irssi.pl)
# Adds item mailcount = { }, to your statusbar, ex. /statusbar window add mailcount
# Settings:
#	/SET mailcount_mailbox [ path[:path1] ]
#		ex. /set mailcount_mailbox /var/spool/mail/derwan
#		    /set mailcount_mailbox /var/spool/mail/derwan:/home/derwan/mail/inbox2
#	/SET mailcount_check_ofset [ seconds ]
#	/SET mailcount_info_level [ 0-5 ]
#	/SET mailcount_hide_empty [ On/Off ]
# Usage:
#	/MAILCOUNT	- mailcount checks for new mail and refresh sbitem

use strict;
use vars qw($VERSION %IRSSI);

$VERSION = "1.0pre4";
%IRSSI = (
	authors		=> 'Marcin "derwan" Ró¿ycki',
	contact		=> 'derwan@irssi.pl',
	name		=> 'mailcount',
	description	=> 'Adds statusbar item mailcount and displays info about new mails in active window',
	license		=> 'GNU GPL v2',
	url		=> 'http://irssi.pl/~derwan/',
	changed		=> '1021885719'
);

use Irssi;
use Irssi::TextUI;

# defaults
my $mailcount_info_level = 5;
my $mailcount_mailbox = "$ENV{'MAIL'}";
my $mailcount_check_ofset = 60;
my $mailcount_hide_empty = 0;

#my $mailcount_status_new = "04";
my $mailcount_status_new = "01";
my $mailcount_status_seen = "08";
my $mailcount_status_cache = "03";
my $mailcount_status_old = "14";
my $mailcount_lock = undef;
my $mailcount_last_ofset = undef;
my $mailcount_last_sbitem = undef;
my $mailcount_timeout_tag = undef;

my %mailcount = ();


# int mailcount_read_mailbox()
# arguments: 0 - path to mailbox
# shows new mails and returns numebers of new and old mails in mailbox
sub mailcount_read_mailbox
{
	my $mailbox = $_[0];
	my $new = my $old = my $cnt = my $atx = my $mode = 0;

	# mailcount's structure:
	#	$mailcount{/var/spool/mail/derwan} 		= $HASH
	#	$HASH->{info}->{ctime}				= last_ctime
	#	$HASH->{info}->{new}				= last_number_of_new_mails
	#	$HASH->{info}->{old}				= last_number_of_old_mails
	#	$HASH->{mail}->{$mail}->{status}		= status
	#	$HASH->{mail}->{$mail}->{from}			= from
	#	$HASH->{mail}->{$mail}->{subject}		= subject
	#	$HASH->{mail}->{$mail}->{date}			= date
	#	$HASH->{mail}->{$mail}->{attachments}		= number_of_attachments
	#	$HASH->{mail}->{$mail}->{attachment}->{$atx}	= attachment

	if ($mailbox) {
		if (!(-f "$mailbox")) {
			if ($mailcount{$mailbox}) {
				delete $mailcount{$mailbox}->{info};
				delete $mailcount{$mailbox}->{mail};
			}
		} else {
			unless ($mailcount{$mailbox}) {
				$mailcount{$mailbox} = {};
				$mailcount{$mailbox}->{info}->{new} = 0;
				$mailcount{$mailbox}->{info}->{old} = 0;
			}

			my @mbox_stat = stat("$mailbox");
			if ($mbox_stat[9] eq $mailcount{$mailbox}->{info}->{ctime}) {
				$new = $mailcount{$mailbox}->{info}->{new};
				$old = $mailcount{$mailbox}->{info}->{old};
			} else {
				open(MBOX, "<$mailbox") or return $new, $old;

				$mailcount{$mailbox}->{info}->{ctime} = $mbox_stat[9];
				my ($mail, $boundary);
				my %mails = ();

				while (<MBOX>)
				{
					chomp;

					# From derwan@irssi.pl  Wed May 1 17:14:54 2002
					/^From / and do {
						s/^From //;
						$mail = $_;
						$mails{$mail} = $mode = 1;
						if (!$mailcount{$mailbox}->{mail}->{$mail}->{status}) {
							$mailcount{$mailbox}->{mail}->{$mail}->{status} = $mailcount_status_new;
							$new++;
							$cnt++;
						} else {
							if ($mailcount{$mailbox}->{mail}->{$mail}->{status} eq $mailcount_status_old) {
								$old++;
								$mode = 0;
							} else {
								$mailcount{$mailbox}->{mail}->{$mail}->{status} = $mailcount_status_cache;
								$new++;
							}
						}
						$atx = 0;
						undef $boundary;
						next;
					};
					
					next unless ($mode);

					# --1975727318-1029081424-1021482747=:2078
					# --1975727318-1029081424-1021482747=:2078--
					/^--$boundary(-*?)/i and do {
						next unless ($boundary);
						if (/--$/) {
							$mailcount{$mailbox}->{mail}->{$mail}->{attachments} = "+$atx";
							$mode = 0;
						} else {
							$mode = 3;
						}
						next;
					};

					# Content-Type: APPLICATION/octet-stream; name="mailcount.pl"
					/^Content-Type: .*\bname=PLANS/i and $mode = 2, next;
					/^Content-Type: .*\bname=/i and do {
						if ($mode == 3) {
							s/^Content-Type: //i;
							$mailcount{$mailbox}->{mail}->{$mail}->{attachment}->{++$atx} = $_;
							$mode = 2;
						}
						next;
					};

					next unless ($mode == 1);

					# end of headers, mail body
					/^$/ and $mode = 2, next;
					# From: Marcin Rozycki <derwan@irssi.pl>
					/^From: ./i and s/^From: //i, $mailcount{$mailbox}->{mail}->{$mail}->{from} = $_, next;

					# Subject: FOLDER INETRNAL DATA...
					# Status: RO
					/^S(ubject: .*\bfolder internal data\b|tatus: RO)/i and do {
						$mode = 0;
						--$cnt if ($mailcount{$mailbox}->{mail}->{$mail}->{status} eq $mailcount_status_new);
						++$old, $mailcount{$mailbox}->{mail}->{$mail}->{status} = $mailcount_status_old if ($_ =~ /^st/i);
						--$new;
						next;
					};

					# Status: O
					/^Status: O/i and do {
						$mailcount{$mailbox}->{mail}->{$mail}->{status} = $mailcount_status_seen if ($mailcount{$mailbox}->{mail}->{$mail}->{status} eq $mailcount_status_new);
						next;
					};

					# Content-Type: MULTIPART/MIXED; BOUNDARY="1975727318-1029081424-1021482747=:2078"
					/^Content-Type: .*\bBOUNDARY=/i and s/(^.*\bboundary=|\")//ig, $boundary = $_, next;

					# Subject: Yo.
					/^Subject: ./i and s/^subject: //i, $mailcount{$mailbox}->{mail}->{$mail}->{subject} = $_, next;

					# Date: Wed, 15 May 2002 17:14:54 +0200 (CEST)
					/^Date: ./i and s/^date: //i, $mailcount{$mailbox}->{mail}->{$mail}->{date} = $_, next;
				}
				close(MBOX);

				$mailcount{$mailbox}->{info}->{new} = $new;
				$mailcount{$mailbox}->{info}->{old} = $old;

				foreach my $mail (keys %{$mailcount{$mailbox}->{mail}})
				{
					unless ($mails{$mail}) {
						delete $mailcount{$mailbox}->{mail}->{$mail};
					}
				}

			}
		}

		# info abaut new mails
		if ($cnt > 0) {
			my $level = Irssi::settings_get_int("mailcount_info_level");
			$level = $mailcount_info_level if ($level < 0 or $level > 5);
			# You have new mail..
			Irssi::printformat(MSGLEVEL_CRAP, "mailcount_notify", $mailbox, $new, $old) if ($level > 0);
			if ($level > 1) {
				foreach my $mail (keys %{$mailcount{$mailbox}->{mail}})
				{
					next if ($mailcount{$mailbox}->{mail}->{$mail}->{status} =~ /^($mailcount_status_cache|$mailcount_status_old)$/);
					# > From: derwan@irssi.pl...
					Irssi::printformat(MSGLEVEL_CRAP, "mailcount_sender", "\003".$mailcount{$mailbox}->{mail}->{$mail}->{status},
						split(/ +/, $mail, 2), $mailcount{$mailbox}->{mail}->{$mail}->{attachments});
					if ($level == 3 || $level == 5) {
						# Sender:
						Irssi::printformat(MSGLEVEL_CRAP, "mailcount_header", "Sender", $mailcount{$mailbox}->{mail}->{$mail}->{from})
							if ($level == 5 and $mailcount{$mailbox}->{mail}->{$mail}->{from});
						# Date:
						Irssi::printformat(MSGLEVEL_CRAP, "mailcount_header", "Date", $mailcount{$mailbox}->{mail}->{$mail}->{date})
							if ($mailcount{$mailbox}->{mail}->{$mail}->{date});
						# Subject:
						Irssi::printformat(MSGLEVEL_CRAP, "mailcount_header", "Subject", $mailcount{$mailbox}->{mail}->{$mail}->{subject})
							if ($mailcount{$mailbox}->{mail}->{$mail}->{subject});
					}
					next if ($level <= 3);
					foreach my $atx (keys %{$mailcount{$mailbox}->{mail}->{$mail}->{attachment}})
					{
						# >01. TEXT/PLAIN; name="mailcount.pl"..
						Irssi::printformat(MSGLEVEL_CRAP, "mailcount_attachment", sprintf("%02d", $atx), $mailcount{$mailbox}->{mail}->{$mail}->{attachment}->{$atx});
					}
				}
			}
		}
	}

	return $new, $old;
}

# void mailcount()
# arguments: 0 - sbitem, 1 - get_size_only
sub mailcount
{
	my ($sbitem, $get_size_only) = @_;

	if ($mailcount_lock) {
		$sbitem->default_handler($get_size_only, $mailcount_last_sbitem, undef, 1) if ($mailcount_last_sbitem);
		return;
	}

	my $ofset = Irssi::settings_get_int("mailcount_check_ofset");
	if ($ofset == 0) {
		$sbitem->{min_size} = $sbitem->{max_size} = 0 if ($get_size_only);
		return;
	};
	$ofset = $mailcount_check_ofset if ($ofset < 20 or $ofset > 300);

	$mailcount_lock = 1;
	my $new = my $old = 0;
	foreach my $mailbox (split(/\:/, Irssi::settings_get_str("mailcount_mailbox")))
	{
		my ($in, $io) = mailcount_read_mailbox($mailbox);
		$new += $in; $old += $io;
	}
	undef $mailcount_lock;

	if ($new == 0 and $old == 0) {
		$sbitem->{min_size} = $sbitem->{max_size} = 0 if ($get_size_only);
		# hide if empty
		return if (Irssi::settings_get_bool("mailcount_hide_empty"));
	}
	my $sbmail = "{sb Mail: ";
	if ($new > 0) {
		$sbmail .= "\%C$new\%n";
		$sbmail .= ",$old" if ($old > 0);
	} else {
		$sbmail .= "$old";
	}
	$sbmail .= "}";
	$mailcount_last_sbitem = $sbmail;

	$sbitem->default_handler($get_size_only, $sbmail, undef, 1);

	# timer
	if ($ofset ne $mailcount_last_ofset) {
		Irssi::timeout_remove($mailcount_timeout_tag) if ($mailcount_timeout_tag > 0);
		$mailcount_timeout_tag = Irssi::timeout_add($ofset*1000, "refresh", undef);
		$mailcount_last_ofset = $ofset;
	}
}

# void refresh()
sub refresh
{
	Irssi::statusbar_items_redraw("mailcount");
};

# registering themes
Irssi::theme_register([
	'mailcount_notify',		'%YYou have new mail%n in {hilight $0} (new: $1, old: $2)',
	'mailcount_sender',		'$0>%n %CFrom:%n {hilight $1} [$2] $3',
	'mailcount_header',		'  %c$0:%n $1-',
	'mailcount_attachment',		'  %K>$0.%n $1-',
	

]);

# registering settings
Irssi::settings_add_int("misc", "mailcount_info_level", $mailcount_info_level);
Irssi::settings_add_str("misc", "mailcount_mailbox", $mailcount_mailbox);
Irssi::settings_add_int("misc", "mailcount_check_ofset", $mailcount_check_ofset);
Irssi::settings_add_bool("misc", "mailcount_hide_empty", $mailcount_hide_empty);

# registering sbitem
Irssi::statusbar_item_register("mailcount", undef, "mailcount");

# binding command
Irssi::command_bind("mailcount", "refresh");
