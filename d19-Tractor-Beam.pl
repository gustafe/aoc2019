#! /usr/bin/env perl
# Advent of Code 2019 Day 19 - Tractor Beam - complete solution
# Problem link: http://adventofcode.com/2019/day/19
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d19
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use List::Util qw/sum all/;
use Data::Dumper;
use Test::More;
use lib '/home/gustaf/prj/AdventOfCode/Intcode';
use Intcode qw/run_vm/;

#### INIT - load input data from file into array
my $testing = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
my $program = [ split( /,/, $file_contents[0] ) ];
my $res;

my %stats;
for my $y ( 0 .. 49 ) {
    for my $x ( 0 .. 49 ) {
        $res = run_vm(
            {
                state     => [@$program],
                positions => [ 0, 0 ],
                input_ary => [ $x, $y ]
            }
        );
        $stats{ $res->{output_ary}->[0] }++;
    }
}

my $part1 = $stats{1};
is( $part1, 217, "Part 1: $part1" );

my $delta = 99;
my $part2;
LOOP: for my $y ( 937 .. 1175 ) {    # found by inspection
    my $x_1 = int( 0.66 * $y );
    my $x_2 = int( 0.836521739 * $y );
    for my $x ( $x_1 .. $x_2 ) {
        my $ok = check_corners( $y, $x );
        if ($ok) {
            $part2 = 10_000 * $x + $y;
            last LOOP;
        }
    }
}

is( $part2, 6840937, "Part 2: $part2" );

done_testing();

sub check_corners {
    my ( $y_start, $x_start ) = @_;
    my @output;
    for my $corners (
        [ $x_start,          $y_start ],
        [ $x_start + $delta, $y_start ],
        [ $x_start,          $y_start + $delta ],
        [ $x_start + $delta, $y_start + $delta ]
      )
    {
        $res = run_vm(
            {
                state     => [@$program],
                positions => [ 0, 0 ],
                input_ary => [@$corners]
            }
        );
        push @output, $res->{output_ary}->[0];
    }
    if ( all { $_ == 1 } @output ) {
        return 1;
    }
    else {
        return 0;
    }
}
