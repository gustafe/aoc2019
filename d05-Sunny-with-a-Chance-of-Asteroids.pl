#! /usr/bin/env perl
# Advent of Code 2019 Day 5 - Sunny with a Chance of Asteroids - complete solution
# Problem link: http://adventofcode.com/2019/day/5
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d05
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################
use Modern::Perl '2015';
# useful modules
use List::Util qw/sum/;
use Data::Dumper;
use Test::Simple tests => 1;
#### INIT - load input data from file into array
my $testing = 0;
my $debug   = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
my $halt        = 99;
my $part2       = shift || 0;
my $initial_val = $part2 ? 5 : 1;

my $program = [ split( ',', $file_contents[0] ) ];

#dump_state($program);
my ( $out_state, $out ) = run_vm( $program, [$initial_val] );
my $ans = $out->[-1];
if ($part2) {
    ok( $ans == 7616021 );
}
else {
    ok( $ans == 15259545 );
}
say $part2? "Part 2: " : "Part 1: ", $ans;

### SUBS

sub run_vm {
    my ( $state, $in_val ) = @_;

    #    my @state = @{$program};
    my @input = @{$in_val};
    my $ptr   = 0;
    my $out_val;
    while ( $state->[$ptr] != $halt ) {
        my ( $op, $a1, $a2, $a3 ) =
          @$state[ $ptr, $ptr + 1, $ptr + 2, $ptr + 3 ];
        say join( ' ', $ptr, $op, $a1, $a2, $a3 ) if $debug;
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
        my %ops = (
            1 => sub { $state->[ $_[2] ] = $_[0] + $_[1]; $ptr += 4 },
            2 => sub { $state->[ $_[2] ] = $_[0] * $_[1]; $ptr += 4 },
            4 => sub { push @{$out_val}, $_[0]; $ptr += 2 },
            5 => sub {
                if ( $_[0] != 0 ) { $ptr = $_[1]; }
                else              { $ptr += 3; }
            },
            6 => sub {
                if ( $_[0] == 0 ) { $ptr = $_[1]; }
                else              { $ptr += 3; }
            },
            7 => sub {
                if   ( $_[0] < $_[1] ) { $state->[ $_[2] ] = 1; }
                else                   { $state->[ $_[2] ] = 0; }
                $ptr += 4;
            },
            8 => sub {
                if ( $_[0] == $_[1] ) {
                    $state->[ $_[2] ] = 1;
                }
                else {
                    $state->[ $_[2] ] = 0;
                }
                $ptr += 4;
            },

        );

        if ( $op == 3 ) {
            $state->[$a1] = shift @$in_val;
            $ptr += 2;
        }
        else {
            $a1 = $mask->[0] ? $a1 : $state->[$a1];
            $a2 = $mask->[1] ? $a2 : $state->[$a2];
            $ops{$op}->( $a1, $a2, $a3 );
        }
    }
    return ( $state, $out_val );

}

sub dump_state {    # shows a pretty-printed grid of the current state
    my @show = split( ',', $_[0] );
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

