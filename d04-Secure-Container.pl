#! /usr/bin/env perl
# Advent of Code 2019 Day 4 - Secure Container - complete solution
# Problem link: http://adventofcode.com/2019/day/4
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d04
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use List::Util qw/sum all any none/;
use Test::Simple tests => 2;
my $testing = 0;

### CODE

# problem input
my @limits = ( 245182, 790572 );
if ($testing) { $limits[1] = 300000 }

my $part1;
my $part2;

for my $N ( $limits[0] .. $limits[1] ) {
    my @digits = split( //, $N );

    # increasing?
    my $inc = all { $digits[$_] <= $digits[ $_ + 1 ] } ( 0 .. 4 );

    # duplicated digits?
    my $dbl = any { $digits[$_] == $digits[ $_ + 1 ] } ( 0 .. 4 );

    next unless ( $inc && $dbl );

    $part1++;

    my %hist;
    for my $d (@digits) { $hist{$d}++ }

    # discard any solutions where there are only groups of 3 or more,
    # and no separate doubles
    next if ( any { $_ > 2 } values %hist and none { $_ == 2 } values %hist );

    $part2++;
}

ok( $part1 == 1099 );
ok( $part2 == 710 );
say "Part 1: $part1";
say "Part 2: $part2";
