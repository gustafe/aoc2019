#! /usr/bin/env perl
# Advent of Code 2019 Day 1 - The Tyranny of the Rocket Equation - complete solution
# Problem link: http://adventofcode.com/2019/day/1
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d01
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;
use Data::Dumper;
use Test::More;
use POSIX qw/floor/;

#### INIT - load input data from file into array
my $testing = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my $sum;
my $sum2;
while (@input) {
    my $mass = shift @input;
    my $fuel = floor( $mass / 3 ) - 2;
    say "$mass $fuel" if $testing;
    $sum  += $fuel;
    $sum2 += $fuel;
    while ( $fuel >= 6 ) {
        $fuel = floor( $fuel / 3 ) - 2;
        say $fuel if $testing;
        $sum2 += $fuel;
    }

}
is( $sum, 3216868, "Part 1: $sum");
is( $sum2, 4822435, "Part 2: $sum2");
done_testing();

