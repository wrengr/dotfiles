# Lists ticket numbers when announced on the specified channels
# Status (A=active,F=fixed,C=archive)
# Priority (C=comp, W=wait, H=hold, !=hot, S=sticky, _=general)

use lib '/pkgs/uns/irssi/current/lib/5.6.1/sun4-solaris';
use Irssi;
use Date::Parse;
use Date::Format;
use strict;
use vars qw($VERSION %IRSSI);

$VERSION = '2.04';
%IRSSI = (
	'authors'		=> 'koninkje, MaddHatter',
	'name'			=> 'snot-autolist',
	'description'	=> 'Access snot from irssi',
	'license'		=> '(c) 2006'
);

# Vars for get_tts_info()
my $archspool   = '/u/snot/spool/archive';
my $fxspool     = '/u/snot/spool/fixed';
my $actspool    = '/u/snot/spool/active';
my $snotappend  = '/u/snot/logs/appendage';
my $snotadminb  = 'X' x 18 . '  Administrative Information Follows  ' . 'X' x 22;


# User-modifiable settings ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# General:
Irssi::settings_add_str('snot' => 'snot_listenchans' => '#hack #meow #hotsheet');
Irssi::settings_add_str('snot' => 'snot_ignorenicks' => 'bugbot');
Irssi::settings_add_bool('snot' => 'snot_check_all_spools' => 0);

# Formatting:

# Used when some field is too long to fit in its space
Irssi::settings_add_str('snot' => 'snot_morechar' => "\xE2");

# Used to format %lupdate and other times
Irssi::settings_add_str('snot' => 'snot_timestamp' => '%Y/%m/%d');

Irssi::settings_add_int('snot' => 'snot_msg_short_size' => 70);
Irssi::settings_add_str('snot' => 'snot_msg_short_format'
	=> '%[-6]tts %status%pri %[9]from %[*]subj');

Irssi::settings_add_int('snot' => 'snot_msg_med_size' => 100);
Irssi::settings_add_str('snot' => 'snot_msg_med_format'
	=> '%[-6]tts %status%pri %[4]flag %[11]from %[8]resp %[*]subj');

Irssi::settings_add_str('snot' => 'snot_msg_full_format'
	=> '%[-6]tts %status%pri %[11]flag %[13]from %[8]resp %[8]guard %[*]subj %[10]lupdate');


# Find an element in a list which meets a criterion ~~~~~~~~~~~~~~~~~~~~~~~~~~~
# metaprogramming++ (functional programming)++
sub find (&@) {
	my ($sub, @list) = @_;
	foreach (@list) {
		return $_ if (&$sub);
	}
	return undef;
}


# We recieved our own public message/action/notice! ~~~~~~~~~~~~~~~~~~~~~~~~~~~
Irssi::signal_add_last('message own_public'     => \&event_ownpubmsg);
Irssi::signal_add_last('message irc own_action' => \&event_ownpubmsg);
Irssi::signal_add_last('message irc own_notice' => \&event_ownpubmsg);
sub event_ownpubmsg {
	my ($server, $message, $target) = @_;
	event_pubmesg($server, $message, Irssi::settings_get_str("user_name"), undef, $target);
}


# We got a public message/action/notice! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Irssi::signal_add_last('message public'     => \&event_pubmesg);
Irssi::signal_add_last('message irc action' => \&event_pubmesg);
Irssi::signal_add_last('message irc notice' => \&event_pubmesg);
sub event_pubmesg {
	my ($server, $message, $nick, $usermask, $target) = @_;
	
	my $winitem = Irssi::window_find_item($target);
	
	$target = lc $target;
	return unless find { lc $_ eq $target }
		split /\s+/, Irssi::settings_get_str('snot_listenchans');
	
	print_tts($message, $winitem, $winitem, MSGLEVEL_PUBLIC, $nick);
}


# We got a private message! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Irssi::signal_add_last 'message private' => sub {
	my ($server, $message, $nick, $usermask) = @_;
	
	my $qh = Irssi::query_find($nick);
	
	# We're totally guessing on window widths here... hopefully
	# all windows are the same width (a bad assumption, but I
	# didn't see how to track down the width of a query window)
	my $win = find { $_->{'width'} > 0 } Irssi::windows();
	return unless defined $win;
	
	print_tts($message, $win, $qh, MSGLEVEL_MSGS, $nick);
};


# Someone manually invoked the program ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Irssi::command_bind 'snot' => sub {
	my ($message, $server, $winitem) = @_;
	return unless $winitem;
	
	print_tts($message, $winitem->window(), $winitem, MSGLEVEL_PUBLIC, undef, 1);
};


# This is where all the magic happens ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sub print_tts {
	my ($message, $win, $winitem, $msglevel, $nick, $check_all) = @_;
	
	# Search recieved message for ticket numbers
	my @ttslist = $message =~ m/\b(\d{5,6})\b/g;
	return unless @ttslist;
	
	# Ignore specified users
	if (defined $nick) {
		$nick = lc $nick;
		return if find { lc $_ eq $nick }
			split /\s+/, Irssi::settings_get_str('snot_ignorenicks');
	}
	
	# Get the usable width of the window
	my $width = $win->{'width'}
		- 1 # for the space
		- length(time2str(Irssi::settings_get_str('timestamp_format'), time)) # timestamp
		;
	
	# Get appropriate format for printing
	my $format;
	if ($width      < Irssi::settings_get_int('snot_msg_short_size') ) {
		$format     = Irssi::settings_get_str('snot_msg_short_format');
	} elsif ($width < Irssi::settings_get_int('snot_msg_med_size')   ) {
		$format     = Irssi::settings_get_str('snot_msg_med_format');
	} else {
		$format     = Irssi::settings_get_str('snot_msg_full_format');
	}
	
	my $timestamp = Irssi::settings_get_str('snot_timestamp');
	
	# For each found tix# get its info and print it
	foreach my $tts (@ttslist) {
		my %ticket = get_tts_info($tts, $check_all);
		delete $ticket{''}; # because for some reason `undef` becomes `{'' => undef}`
		next unless keys %ticket;
		
		# Shorten all flags to three characters
		$ticket{'flag'} = join ',', map { substr($_,0,3) } split m/,/, $ticket{'flag'};
		
		# Reset %lupdate and %rcvd to user's prefered format
		# strftime() requires a literal array, so can't combine these
		my @tm = strptime($ticket{'lupdate'});
		$ticket{'lupdate'} = strftime($timestamp, @tm);
		@tm = strptime($ticket{'rcvd'});
		$ticket{'rcvd'} = strftime($timestamp, @tm);
		
		$winitem->print(expand($format, \%ticket, $width), $msglevel);
		#$winitem->printformat($msglevel, 'snot_format_all', $message);
	}
}


# Expland variables in a formatting string ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sub expand {
	my ($string, $format, $width) = @_;
	
	# Do all the normal replacements first
	while (my ($exp, $repl) = each %$format) {
		while (my ($pattern, $mod, $length, $pad)
			= $string =~ m/(%(?:\[(\.|-)?(\d+)(.)?\])?$exp)/) {
				
			if ($length) {
				# Fix the magic-escaping having been canceled
				$pattern =~ s/(\[|\])/\\$1/g;
				$repl = pad_truncate($repl, $mod, $length, $pad);
				$string =~ s/$pattern/$repl/g;
			} else {
				$string =~ s/%$exp/$repl/g;
			}
		}
	}
	
	# Now do automagical widths
	while (my ($exp, $repl) = each %$format) {
		while (my ($pattern, $mod, $pad) = $string =~ m/(%\[(\.|-)?\*(.)?\]$exp)/) {
			my $length = $width - length($string) + length($pattern);
			
			# Fix the magic-escaping having been canceled
			$pattern =~ s/(\[|\*|\])/\\$1/g;
			
			if ($length > 0) {
				$repl = pad_truncate($repl, $mod, $length, $pad);
			} else {
				$repl = '';
			}
			$string =~ s/$pattern/$repl/g;
		}
	}
	return $string;
}


# Take a decomposed %[x]y variable and return what it should be replaced with ~
sub pad_truncate {
	my ($string, $mod, $length, $pad) = @_;
	
	my $more = '';
	my $diflen = $length - length($string);
	if ($diflen < 0) {
		# BUG: length() isn't working right for unicode.
		# `use utf8;` and `use encoding 'utf8';` aren't helping
		$more = Irssi::settings_get_str('snot_morechar') || '';
		$length -= length($more);
	} else {
		$pad ||= ' ';
		$string .= $pad x $diflen if ($mod eq '');
		$string = $pad x $diflen . $string if ($mod eq '-');
	}
	
	return substr($string,0,$length) . $more;
}


# Finds a ticket file and collects all manner of information about the ticket.
# Returns a hash of that info suitable for expand()ing
sub get_tts_info {
	my %ticket = (
		'tts'		=> findappendage($_[0]),
		'status'	=> '',
		'pri'		=> '',
		'flag'		=> '',
		'from'		=> '',
		'resp'		=> '',
		'guard'		=> '',
		'lupdate'	=> '',
		'recvd'		=> '',
		'subj'		=> '',
	);
	my $check_all = $_[1] || Irssi::settings_get_bool('snot_check_all_spools');
	
	# Find the appropriate file in the appropriate spool
	if (open(TFILE,'<',$actspool.'/'.$ticket{'tts'})) {
		$ticket{'status'} = 'A';
	} elsif ($check_all) {
		if (open(TFILE,'<',$fxspool.'/'.$ticket{'tts'})) {
			$ticket{'status'} = 'F';
		} elsif (open(TFILE,'<',$archspool.'/'.substr($ticket{'tts'},0,-3).'/'.$ticket{'tts'})) {
			$ticket{'status'} = 'C';
		} else {
			return undef;
		}
	} else {
		return undef;
	}
	
	# Start parsing the file
	while (<TFILE>) {
		chomp;
		$ticket{'from'} = $1 if m/^From:.*?(\w+)@/;
		last if m/^$/;
	}
	while (<TFILE>) {
		last if m/^$snotadminb/;
	}
	while (<TFILE>) {
		chomp;
		$ticket{'subj'}    = $1 if m/^SUBJECT:\s+(.*)/;
		if (m/^PRIORITY:\s+(.*)/) {
			my $pri = $1;
			$ticket{'pri'} = 'C' if $pri =~ s/^+//;
			$ticket{'pri'} = '!' if $pri eq 'HOT';
			$ticket{'pri'} = 'W' if $pri eq 'WAIT';
			$ticket{'pri'} = 'H' if $pri eq 'HOLD';
			$ticket{'pri'} = 'S' if $pri eq 'STICKY';
			$ticket{'pri'} = ' ' if $pri eq 'GENERAL';
		}
		$ticket{'flag'}    = $1 if m/^FLAGS:\s+(.*)/;
		$ticket{'recvd'}   = $1 if m/^RECVDATE:\s+(.*)/;
		$ticket{'lupdate'} = $1 if m/^LAST\s+UPDATE:\s+(.*)/;
		$ticket{'resp'}    = $1 if m/^ASSIGNED\s+TO:\s+(.*)/;
		$ticket{'guard'}   = $1 if m/^SUPERVISOR:\s+(.*)/;
	}
	close(TFILE);
	$ticket{'resp'}  =~ s/@.*//;
	$ticket{'guard'} =~ s/@.*//;
	
	return %ticket;
}


# Finds the (parent) ticket to which a given ticket # was appended ~~~~~~~~~~~~
sub findappendage {
    my $tts = $_[0];
	unless (open(APPENDLOG,'<',$snotappend)) {
		return $tts;
	}
	while (<APPENDLOG>) {
		chomp;
		s/^\s*//;
		s/(?:#.*|\s*)$//;
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
