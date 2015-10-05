
# Lists ticket numbers when announced on the specified channels
# Tix# 
# Status (A=active,F=fixed,C=archive)
# Priority (C=comp, W=wait, H=hold, !=hot, S=sticky, _=general)
# Flags
# From
# Responsible
# Guardian
# Subject
# Update date

use lib '/pkgs/uns/irssi/current/lib/5.6.1/sun4-solaris';
use Irssi;
use Date::Parse;
use Date::Format;
use strict;
use vars qw($VERSION %IRSSI);

$VERSION = "1.00";
%IRSSI = (
	authors	    => 'MaddHatter',
	name		=> 'snot-autolist',
	description => 'Lists snot tickets when mentioned in the specified channels',
	license	    => '(c) 2006'
);

my $archspool   = '/u/snot/spool/archive';
my $fxspool     = '/u/snot/spool/fixed';
my $actspool    = '/u/snot/spool/active';
my $snotappend  = '/u/snot/logs/appendage';
my $snotadminb  = 'X' x 18 . "  Administrative Information Follows  " . 'X' x 22;

Irssi::settings_add_str('snot','snot_listenchans','#hack #meow #hotsheet #zot');
Irssi::settings_add_str('snot','snot_ignorenicks','bugbot');

sub findappendage { # Finds the (parent) ticket to which a given ticket # was appended
    my $tts = $_[0];
	unless (open(APPENDLOG,'<',$snotappend)) {
		return $tts;
	}
	while(<APPENDLOG>) {
		chomp;
		s/^\s*//; s/(?:#.*|\s*)$//;
		next if (m/^#/);
		if (m/^(\d+):(\d+)$/) {
			my $ls = $1;
			my $rs = $2;  # $ls was appended to $rs
			if ($tts == $ls) {
				$tts = $rs;
				seek(APPENDLOG,0,0); # Start over at beginning of file
			}
		} # end if m/#:#/
	} # end while
	close(APPENDLOG);
	return $tts;
}

sub getttsinfo { 
	# Finds a ticket file and collects all manner of information about the ticket.
	# Returns a string suitable for printing (a string whose parameter vary
	# depending on the columns available as indicated by the $width parameter.)
	my %Ticket = (
		tts       => 0,
		status    => '',
		pri       => '',
		flag      => '',
		moreflags => ' ',
		from      => '',
		morefrom  => ' ',
		resp      => '',
		guard     => '',
		subj      => '',
		moresubj  => ' ',
		lupdate   => ''
	);
	$Ticket{'tts'} = findappendage($_[0]);
	my $width = $_[1];

	if (open(TFILE,'<',$actspool.'/'.$Ticket{'tts'})) {
		$Ticket{'status'} = 'A';
	} elsif (open(TFILE,'<',$fxspool.'/'.$Ticket{'tts'})) {
		$Ticket{'status'} = 'F';
	} elsif (open(TFILE,'<',$archspool.'/'.substr($Ticket{'tts'},0,-3).'/'.$Ticket{'tts'})) {
		$Ticket{'status'} = 'C';
	} else {
		return undef;
	}
	while (<TFILE>) {
		chomp;
		$Ticket{'from'} = $1 if m/^From:.*?(\w+)@/;
		last if m/^$/;
	}
	while (<TFILE>) {
		last if m/^$snotadminb/;
	}
	while (<TFILE>) {
		chomp;
		$Ticket{'subj'}    = $1 if m/^SUBJECT:\s+(.*)/;
		if (m/^PRIORITY:\s+(.*)/) {
			my $pri = $1;
			$Ticket{'pri'} = 'C' if ($pri =~ s/^+//);
			$Ticket{'pri'} = '!' if ($pri eq 'HOT');
			$Ticket{'pri'} = 'W' if ($pri eq 'WAIT');
			$Ticket{'pri'} = 'H' if ($pri eq 'HOLD');
			$Ticket{'pri'} = 'S' if ($pri eq 'STICKY');
			$Ticket{'pri'} = ' ' if ($pri eq 'GENERAL');
		}
		$Ticket{'flag'}    = $1 if m/^FLAGS:\s+(.*)/;
		$Ticket{'lupdate'} = $1 if m/^LAST\s+UPDATE:\s+(.*)/;
		$Ticket{'resp'}    = $1 if m/^ASSIGNED\s+TO:\s+(.*)/;
		$Ticket{'guard'}   = $1 if m/^SUPERVISOR:\s+(.*)/;
	}
	close(TFILE);
	$Ticket{'resp'}  =~ s/@.*//;
	$Ticket{'guard'} =~ s/@.*//;

	if ($width < 80) {
		# 44444  C C janaka    Re: Facilities throws slight wr...
		my $subjwidth = $width - 22;
		$Ticket{'morefrom'} = "\xBB" if (length($Ticket{'from'}) > 8);
		$Ticket{'moresubj'} = "\xBB" if (length($Ticket{'subj'}) > $subjwidth);
		return sprintf('%-6d %1s %1s %-8s%1s %-'.$subjwidth.'s%1s',
			$Ticket{'tts'},
			$Ticket{'status'},
			$Ticket{'pri'},
			substr($Ticket{'from'},0,8),
			$Ticket{'morefrom'},
			substr($Ticket{'subj'},0,$subjwidth),
			$Ticket{'moresubj'});
	} elsif ($width < 100) {
		# 55555  C C UNI  sarah.du... davburns [Fwd: Returned mail: Host unknown (Name ...
		my $subjwidth = $width - 38;
		$Ticket{'morefrom'} = "\xBB" if (length($Ticket{'from'}) > 10);
		$Ticket{'moreflags'} = "\xBB" if (index($Ticket{'flag'},',') >= 0);
		$Ticket{'moresubj'} = "\xBB" if (length($Ticket{'subj'}) > $subjwidth);
		return sprintf('%-6d %1s %1s %-3s%1s %-10s%1s %-8s %-'.$subjwidth.'s%1s',
			$Ticket{'tts'},
			$Ticket{'status'},
			$Ticket{'pri'},
			substr($Ticket{'flag'},0,3),
			$Ticket{'moreflags'},
			substr($Ticket{'from'},0,10),
			$Ticket{'morefrom'},
			substr($Ticket{'resp'},0,8),
			substr($Ticket{'subj'},0,$subjwidth),
			$Ticket{'moresubj'});
	} else { #really wide
		# 73427  A ! DES,HIS,NE. JanakaJaya... maddhatt maddhatt Can the B1500s be tethered this... 2005/01/06
		my $flaglist = '';
		my $subjwidth = $width - 67;
		$Ticket{'morefrom'} = "\xBB" if (length($Ticket{'from'}) > 12);
		if (index($Ticket{'flag'},',') >= 0) {
			my @flags = split(/,/,$Ticket{'flag'});
			$flaglist = join(',',map({substr($_,0,3)},@flags));
		} else {
			$flaglist = substr($Ticket{'flag'},0,3);
		}
		$Ticket{'moresubj'} = "\xBB" if (length($Ticket{'subj'}) > $subjwidth);
		my @dptokens = strptime($Ticket{'lupdate'});
		my $datestr = 1900+$dptokens[5].'/'.$dptokens[4].'/'.$dptokens[3];
		return sprintf('%-6d %1s %1s %-11s %-12s%1s %-8s %-8s %-'.$subjwidth.'s%1s %-10s',
			$Ticket{'tts'},
			$Ticket{'status'},
			$Ticket{'pri'},
			$flaglist,
			substr($Ticket{'from'},0,12),
			$Ticket{'morefrom'},
			substr($Ticket{'resp'},0,8),
			substr($Ticket{'guard'},0,8),
			substr($Ticket{'subj'},0,$subjwidth),
			$Ticket{'moresubj'},
			$datestr);
	};
}

sub printttsinfo {
	my $message = $_[0]; # Message given to event handler
	my $win = $_[1]; # Where to get width info from
	my $winitem = $_[2]; # Where to write output
	my $msglevel = $_[3]; # Type of output to write

	my @ttslist = $message =~ /\b(\d{5,6})\b/g;
	return unless (scalar(@ttslist) > 0);

	my $timest = Irssi::settings_get_str("timestamp_format");
	my $width = $win->{'width'} - 1 - length(time2str($timest,time)); # 1 for the space
	# print 'Usable width found to be '.$width;

	foreach my $tts (@ttslist) {
		my $ttsinfo = getttsinfo($tts,$width);
		next unless (defined($ttsinfo));
		$winitem->print($ttsinfo,$msglevel);
	}
}

sub event_gotpubmesg { # We got a public message/action/notice!
	# Data arrives in the form of:
	# "message public",     SERVER_REC, char *msg, char *nick, char *address, char *target
	# "message irc action", SERVER_REC, char *msg, char *nick, char *address, char *target
	# "message irc notice", SERVER_REC, char *msg, char *nick, char *address, char *target
	my ($server, $message, $nick, $usermask, $target) = @_;

	my @nicklist = split(/\s+/,Irssi::settings_get_str('snot_ignorenicks'));
	foreach my $inick (@nicklist) {
		return if (lc($inick) eq lc($nick));
	}

	event_gotownpubmsg($server, $message, $target);
}

sub event_gotownpubmsg { # We received our own public message/action/notice!
	# "message own_public",     SERVER_REC, char *msg, char *target
	# "message irc own_action", SERVER_REC, char *msg, char *target
	# "message irc own_notice", SERVER_REC, char *msg, char *target
	my ($server, $message, $target) = @_;
	my $windowwidth = 80;

	my $foundchan = 0;
	my @chanlist = split(/\s+/,Irssi::settings_get_str('snot_listenchans'));
	foreach my $lchan (@chanlist) {
		$foundchan = 1 if (lc($lchan) eq lc($target));
	}
	return unless ($foundchan);

	my $win =  Irssi::window_find_item($target);

	printttsinfo($message,$win,$win,MSGLEVEL_PUBLIC);
}

sub event_gotprivmsg { # We got a private message!
	# "message private", SERVER_REC, char *msg, char *nick, char *address
	my ($server, $message, $nick, $usermask) = @_;

	my $qh = Irssi::query_find($nick);
	my $win = 0;
	# We're totally guessing on window widths here... hopefully
	# all windows are the same width (a bad assumption, but I
	# didn't see how to track down the width of a query window)
	foreach my $window (Irssi::windows()) {
		$win=$window if ($window->{'width'} > 0);
	}

	printttsinfo($message,$win,$qh,MSGLEVEL_MSGS);
}

sub event_slcmd { # Someone manually invoke the list program
	my ($message, $server, $winitem) = @_;
	return unless ($winitem);

	my $win = $winitem->window();

	printttsinfo($message,$win,$winitem,MSGLEVEL_PUBLIC);
}

Irssi::signal_add_last('message public',         'event_gotpubmesg');
Irssi::signal_add_last('message irc action',     'event_gotpubmesg');
Irssi::signal_add_last('message own_public',     'event_gotownpubmsg');
Irssi::signal_add_last('message irc own_action', 'event_gotownpubmsg');
Irssi::signal_add_last('message private',        'event_gotprivmsg');
Irssi::command_bind('snotlist',                  'event_slcmd');

