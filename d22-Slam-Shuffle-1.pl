#! /usr/bin/env perl
# Advent of Code 2019 Day 22 - Slam Shuffle - part 1
# Problem link: http://adventofcode.com/2019/day/22
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d22
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;
use Data::Dumper;
use Test::More;
#### INIT - load input data from file into array
my $testing = shift || 0;
my $debug = $testing;
my @file_contents;
# files test{1..4}.txt contain the instructions for the test examples
my $file = $testing ? 'test' . $testing . '.txt' : 'input.txt';
open( my $fh, '<', "$file" ) or die "can't open file $file: $!";
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
my $size = $testing ? 10 : 10_007;
my @deck = ( 0 .. $size - 1 );

for my $instr (@file_contents) {
    say "==> $instr" if $debug;
    if ( $instr eq 'deal into new stack' ) {
        @deck = reverse @deck;
        say @deck if $debug;

    }
    if ( $instr =~ m/cut (-?\d+)/ ) {
        my @cut;
        if ( $1 > 0 ) {
            @cut = splice( @deck, 0, $1 );
            @deck = ( @deck, @cut );
        }
        else {
            @cut = splice( @deck, $1 );
            @deck = ( @cut, @deck );
        }
        say @deck if $debug;
    }
    if ( $instr =~ m/deal with increment (\d+)/ ) {
        my $incr = $1;
        my $pos  = 0;
        my @stack;
        push @stack, shift @deck;    # first card
        while (@deck) {
            $pos = ( $pos + $incr ) % $size;
            $stack[$pos] = shift @deck;
        }
        @deck = @stack;
        say @deck if $debug;
    }
}
my $part1;
for ( my $idx = 0 ; $idx < scalar @deck ; $idx++ ) {
    if ( $deck[$idx] == 2019 ) {
        $part1 = $idx;
        last;
    }
}

my %correct = (
    1    => '0 3 6 9 2 5 8 1 4 7',
    2    => '3 0 7 4 1 8 5 2 9 6',
    3    => '6 3 0 7 4 1 8 5 2 9',
    4    => '9 2 5 8 1 4 7 0 3 6',
    live => 6831
);

if ($testing) {
    is( join( ' ', @deck ), $correct{$testing}, "test $testing" );
}
else {
    is( $part1, $correct{live}, "Part 1: $part1" );
}
done_testing();
