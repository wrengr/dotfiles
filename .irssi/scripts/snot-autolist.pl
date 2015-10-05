# Lists ticket numbers when announced on the specified channels
# Status (A=active,F=fixed,C=archive)
# Priority (C=comp, W=wait, H=hold, !=hot, S=sticky, K=check, _=general)

use lib '/pkgs/uns/irssi/current/lib/5.6.1/sun4-solaris';
use Irssi;
use Date::Parse;
use Date::Format;
use strict;
#use warnings; # turned off because of a bug circa line 94 re Irssi::*
use vars qw($VERSION %IRSSI);

$VERSION = '2.06';
%IRSSI = (
	'authors'     => 'koninkje, MaddHatter',
	'name'        => 'snot-autolist',
	'description' => 'Access snot from irssi',
	'license'     => '(c) 2006'
);

# Vars for get_tts_info()
# These aren't my()ed because of strange warnings due to this code being run in eval()
# cf. "my () Scoped Variable in Nested Subroutines" in...
# http://perl.apache.org/docs/general/perl_reference/perl_reference.html
our $archspool  = '/u/snot/spool/archive';
our $fxspool    = '/u/snot/spool/fixed';
our $actspool   = '/u/snot/spool/active';
our $snotappend = '/u/snot/logs/appendage';
our $snotadminb = 'X' x 18 . '  Administrative Information Follows  ' . 'X' x 22;


# User-modifiable settings ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# These are the defaults, don't change them but instead change your irssi config

# General
Irssi::settings_add_str('snot' => 'snot_listenchans' => '#hack #meow #hotsheet');
Irssi::settings_add_str('snot' => 'snot_ignorenicks' => 'bugbot');
Irssi::settings_add_bool('snot' => 'snot_check_all_spools' => 0);

# Formatting

# Used when some field is too long to fit in its space
Irssi::settings_add_str('snot' => 'snot_morechar' => "\xE2");

# Used to format %lupdate and other times
Irssi::settings_add_str('snot' => 'snot_timestamp' => '%Y/%m/%d');

# The short format and the usable width up to which to use it
Irssi::settings_add_int('snot' => 'snot_msg_short_size' => 70);
Irssi::settings_add_str('snot' => 'snot_msg_short_format'
	=> '%[-6]tts %status%pri %[9]from %[.*]subj');

# The medium format and the usable width up to which to use it
Irssi::settings_add_int('snot' => 'snot_msg_med_size' => 100);
Irssi::settings_add_str('snot' => 'snot_msg_med_format'
	=> '%[-6]tts %status%pri %[4]flag %[11]from %[8]resp %[.*]subj');

# The full format for screens wider than medium
Irssi::settings_add_str('snot' => 'snot_msg_full_format'
	=> '%[-6]tts %status%pri %[11]flag %[13]from %[8]resp %[8]guard %[*]subj %[10]lupdate');


# Find an element from a list which meets a criterion ~~~~~~~~~~~~~~~~~~~~~~~~~
# (this is like the built-in grep function, except that we just
# return the first match, not all of them)
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
	# Just do a handoff, but find out our nick first
	event_pubmesg($server, $message, Irssi::settings_get_str('user_name'), undef, $target);
}


# We got a public message/action/notice! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Irssi::signal_add_last('message public'     => \&event_pubmesg);
Irssi::signal_add_last('message irc action' => \&event_pubmesg);
Irssi::signal_add_last('message irc notice' => \&event_pubmesg);
sub event_pubmesg {
	my ($server, $message, $nick, $usermask, $target) = @_;
	
	# BUG: Can't locate package Irssi::Nick for @Irssi::Irc::Nick::ISA
	# but only with warnings turned on
	my $winitem = Irssi::window_find_item($target);
	
	# Ignore unless in a channel we're told to listen to
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
	return unless $winitem; # Note, this means we can't use the status window
	
	# If first thing on the line is a flag, enter flag argument processing mode
	if ($message =~ s/\s*-//) { # substitute just to simplify the regexes later on
		if ($message =~ m/(?:-help|h)\b/) {
			$message = join ' ',
				'I listen to channels and tell you about snot tickets people',
				'mention. Look at `/set snot` to see what variables you can',
				'configure. I can also be manually invoked with the command',
				'`/snot`. When invoked, if you pass me a flag then I\'ll do',
				'something special, otherwise I\'ll just pretend like I heard',
				'someone on the channel say what you tell me, though I will',
				'check all spools even if configured not to when eavesdropping.';
			$message .= join "\n", '', '',
				'Here are the flags I know:',
				'    --help     -h    Print this help information',
				'    --version  -v    Print version number',
				'    --fab            Print Doghaus (FAB60) tickets',
				'    --eb             Print Kennel (EB) tickets',
				'    --tutor --tutors Print tutors tickets',
				'    --searcher -s    Run searcher passing it arguments',
				'                     N.B. Can take a very long time!',
				'               -su   short for `--searcher -unq`';
				
			$winitem->print($message, MSGLEVEL_PUBLIC);
			return;
			
		} elsif ($message =~ m/(?:-version|v)\b/) {
			$winitem->print("$IRSSI{'name'}, version $VERSION", MSGLEVEL_PUBLIC);
			return;
			
		} elsif ($message =~ m/-fab\b/) {
			$message = `/u/snot/bin/snot -lu | egrep 'FAB60 - |FAB and EB' | cut -b 4-9`;
			
		} elsif ($message =~ m/-eb\b/) {
			$message = `/u/snot/bin/snot -lu | egrep 'EB - |MCAE - |FAB and EB' | cut -b 4-9`;
			
		} elsif ($message =~ m/-tutors?\b/) {
			$message = `/u/snot/bin/snot -lu | grep 'Tutor - ' | cut -b 4-9`;
			
		} elsif ($message =~ s/(?:-searcher|s(u?))\b//) {
			$message = '-unq ' . $message if ($1);
			$message = `/cat/bin/searcher $message`;
			
		} else {
			$winitem->print("$IRSSI{'name'}: Unknown option. For help type `/snot -h`", MSGLEVEL_PUBLIC);
			return;
		}
		
		# Since the search tools give newline-delimited, remove newlines
		$message =~ s/\n/ /g;
		
		# Diagnostic message for failed searches, rather than just doing nothing
		unless ($message) {
			$winitem->print("$IRSSI{'name'}: No matches found.", MSGLEVEL_PUBLIC);
			return;
		}
	}
	
	# otherwise if not a flag, or if the flag gave us tix, treat line as if spoken in a channel
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
	
	# For each found tts# get its info and print it
	foreach my $tts (@ttslist) {
		my %ticket = get_tts_info($tts, $check_all);
		delete $ticket{''}; # because for some reason `undef` becomes `{'' => undef}`
		next unless keys %ticket;
		
		# Shorten all flags to three characters
		$ticket{'flag'} = join ',', map { substr($_,0,3) } split m/,/, $ticket{'flag'};
		
		# Reset %lupdate and %rcvd to user's prefered format
		# strftime() requires a literal array, so we can't combine these
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
				$pattern =~ s/(\[|\.|\*|\])/\\$1/g;
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
			$pattern =~ s/(\[|\.|\*|\])/\\$1/g;
			
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
	
	my $more = ''; # defined empty here in case not needed, cf concatenation in return
	my $diflen = $length - length($string);
	if ($diflen < 0) {
		# BUG: length() isn't working right for unicode.
		# `use utf8;` and `use encoding 'utf8';` aren't helping
		$more = Irssi::settings_get_str('snot_morechar') || '';
		$length -= length($more);
	} else {
		$pad ||= ' ';
		if ($mod eq '') {
			$string .= $pad x $diflen;
		} elsif ($mod eq '-') {
			$string = $pad x $diflen . $string;
		} # else $mod eq '.' so no padding
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
	if (open(TFILE, '<', $actspool.'/'.$ticket{'tts'})) {
		$ticket{'status'} = 'A';
	} elsif ($check_all) {
		if (open(TFILE, '<', $fxspool.'/'.$ticket{'tts'})) {
			$ticket{'status'} = 'F';
		} elsif (open(TFILE, '<', $archspool.'/'.substr($ticket{'tts'},0,-3).'/'.$ticket{'tts'})) {
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
		if    (m/^SUBJECT:\s+(.*)/)  { $ticket{'subj'} = $1; }
		elsif (m/^PRIORITY:\s+(.*)/) {
			my $pri = $1;
			if    ($pri =~ m/^\+/)    { $ticket{'pri'} = 'C'; }
			elsif ($pri eq 'HOT')     { $ticket{'pri'} = '!'; }
			elsif ($pri eq 'WAIT')    { $ticket{'pri'} = 'W'; }
			elsif ($pri eq 'HOLD')    { $ticket{'pri'} = 'H'; }
			elsif ($pri eq 'STICKY')  { $ticket{'pri'} = 'S'; }
			elsif ($pri eq 'CHECK')   { $ticket{'pri'} = 'K'; }
			elsif ($pri eq 'GENERAL') { $ticket{'pri'} = ' '; }
			else                      { $ticket{'pri'} = '?'; } # something goofy
		}
		elsif (m/^FLAGS:\s+(.*)/)         { $ticket{'flag'}    = $1; }
		elsif (m/^RECVDATE:\s+(.*)/)      { $ticket{'recvd'}   = $1; }
		elsif (m/^LAST\s+UPDATE:\s+(.*)/) { $ticket{'lupdate'} = $1; }
		elsif (m/^ASSIGNED\s+TO:\s+(.*)/) { $ticket{'resp'}    = $1; }
		elsif (m/^SUPERVISOR:\s+(.*)/)    { $ticket{'guard'}   = $1; }
	}
	close(TFILE);
	$ticket{'resp'}  =~ s/@.*//;
	$ticket{'guard'} =~ s/@.*//;
	
	return %ticket;
}


# Finds the (parent) ticket to which a given ticket # was appended ~~~~~~~~~~~~
sub findappendage {
    my $tts = $_[0];
	unless (open(APPENDLOG, '<', $snotappend)) {
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
