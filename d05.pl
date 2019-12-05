#! /usr/bin/env perl
# Advent of Code 2019 Day 5 - Sunny with a Chance of Asteroids - complete solution
# Problem link: http://adventofcode.com/2019/day/5
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d05
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use List::Util qw/sum all/;
use Data::Dumper;
use Test::Simple tests => 1;
#### INIT - load input data from file into array

my $debug = 0;
my @input;
my $file = 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my $part2 = shift || 0;

my @initial = split( /,/, $input[0] );
my $indata = $part2 ? 5 : 1;

my @state = @initial;
my @output;

sub dump_state;
my $halt = 99;

my $ptr = 0;
while ( $state[$ptr] != $halt ) {

    my ( $op, $in1, $in2, $out ) = @state[ $ptr, $ptr + 1, $ptr + 2, $ptr + 3 ];
    my $mask;
    if ( length $op > 2 )
    {    # assume values in this position are either 2 digits or more

        my @instr = split( //, $op );
        my @tail;
        for ( 1, 2 ) {
            unshift @tail, pop @instr;
        }
        $op = join( '', @tail ) + 0;
        while ( scalar @instr < 3 ) {
            unshift @instr, 0;
        }
        $mask = [ reverse @instr ];
    }
    else {
	$mask = [ 0, 0, 0 ];
    }
    say "$ptr: $op $in1 $in2 $out [", join( ',', @$mask ), ']' if $debug;
    perform_op( $op, $in1, $in2, $out, $mask );

}
my $ans = $output[-1];

if ($part2) {
    ok( $ans == 7616021 );
}
else {
    ok( $ans == 15259545 );
}
say $part2? "Part 2: " : "Part 1: ", $ans;

### Subs
sub perform_op {
    my ( $opcode, $arg1, $arg2, $dest, $mask ) = @_;
    my $a1 = $mask->[0] ? $arg1 : $state[$arg1];
    my $a2 = $mask->[1] ? $arg2 : $state[$arg2];

    my %ops = (
        1 => sub { $state[$dest] = $a1 + $a2; $ptr += 4 },
        2 => sub { $state[$dest] = $a1 * $a2; $ptr += 4 },
        3 => sub { $state[$arg1] = $indata;   $ptr += 2 },
        4 => sub { push @output, $a1; $ptr += 2 },
        5 => sub {
            if ( $a1 != 0 ) { $ptr = $a2 }
            else            { $ptr += 3 }
        },

        6 => sub {
            if ( $a1 == 0 ) { $ptr = $a2 }
            else            { $ptr += 3 }
        },
        7 => sub {
            if   ( $a1 < $a2 ) { $state[$dest] = 1 }
            else               { $state[$dest] = 0 }
            $ptr += 4;
        },
        8 => sub {
            if   ( $a1 == $a2 ) { $state[$dest] = 1 }
            else                { $state[$dest] = 0 }
            $ptr += 4;
        },
	      );
    die "unknown opcode: $opcode!" unless exists $ops{$opcode};
    $ops{$opcode}->();
}

sub dump_state {
    my @show = @state;
    print '   ';
    for my $i ( 0 .. 9 ) { printf( "___%d ", $i ) }
    print "\n";
    my $full_rows = int( scalar @show / 10 );

    my $r;
    for $r ( 0 .. $full_rows - 1 ) {
        printf "%2d|", $r;
        for my $c ( 0 .. 9 ) {
            my $el = shift @show;
            printf "%4d ", $el;

        }
        print "\n";
    }
    printf "%2d|", $full_rows;
    while (@show) {
        my $el = shift @show;
        printf "%4d ", $el;
    }
    print "\n";

}

