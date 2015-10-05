#!/usr/bin/env perl
use warnings;
use strict;

# This is still somewhat buggy about indented Javadocs. In particular it fails to reintroduce the * on the subsequent lines. Also, we need to do the underscore hack to fix how wide fmt formats things to.

# also buggy when called with blank (i.e. /^\s*\*\s*$/) first line
# Also buggy when the closing */ is on the same line

chomp (my $a = <>);
$a =~ s/\s+$//;

chomp (my $b = <>);
$b =~ s/\s+$//;

sub fmt { my ($line) = @_;
	
	#$line =~ s/  / /g; # This won't get everything, but \s+ also grabs leading tabs. It's buggy about indentation after * though.
	
	$line =~ s/^ \* //;
	$line =~ s/^/   /;
	
	$line =~ s/'/'\\''/g; # This won't account for backslash escapes in $line
	my @lines = `echo '$line' | fmt`;
	# Consider also s/^(\t*)  ?(?!\*)/$1 \* /, still buggy but differently
	return join '', map { $_ =~ s/^(\t*)  /$1 \*/; $_ } @lines;
}

if ($b !~ m/^\s*\*(?:\s*(?:<[pP]>|$|@)|\/)/) {
	$b =~ s/^\s*\*\s*//;
	print fmt("$a $b");
} else {
	print fmt("$a");
	print "$b\n";
}

__END__
