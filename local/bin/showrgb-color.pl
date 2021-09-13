#!/usr/bin/env perl
use warnings;
use strict;

# TODO: we'd need to use 'open3' if we want to get the child PID;
#   see my `psed` script for more info.
# Probably ASCII is more accurate
open(my $fh, "-| :encoding(UTF-8)", 'showrgb')
    || die "$0: can't open pipe from \`showrgb\`: $!";

# this idiom is copypasta from `accumulate`, though the details differ.
my %K;
while (<$fh>) {
    chomp;
    s/^\s*//;
    my @F = split /\s+/, $_, 4;
    my $hex = sprintf "%02x%02x%02x", @F[0..2];
    if (defined $F[3]) {
        my $name = $F[3];
        $name =~ s/\s/_/g;
        push @{$K{$hex}}, $name;
    }
}
die "$0: unexpected error while reading: $!"
    if $!;

foreach (sort { hex $a <=> hex $b } keys %K) {
    my ($r,$g,$b) = $_ =~ m/^(..)(..)(..)$/ or die;
    print
        "\e[38:2::" . (hex $r) . ':' . (hex $g) . ':' . (hex $b) . 'm',
        $_, "\t", (join ' ', @{$K{$_}}), "\e[0m\n";
}
