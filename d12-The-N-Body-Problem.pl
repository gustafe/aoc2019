#! /usr/bin/env perl
# Advent of Code 2019 Day 12 - The N-Body Problem - complete solution
# Problem link: http://adventofcode.com/2019/day/12
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d12
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use List::Util qw/sum any all/;
use Data::Dumper;
use Test::More;
use ntheory qw/lcm/;
#### INIT - load input data from file into array
my $testing = 0;
my $debug   = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
my @moons;
my $id = 0;
my @initial_pos;
foreach my $line (@file_contents) {
    if ( $line =~ m/<x=(-?\d+), y=(-?\d+), z=(-?\d+)>/ ) {
        my @pos = ( $1, $2, $3 );
        $moons[$id]->{pos} = [@pos];
        push @initial_pos, [@pos];
        $moons[$id]->{vel} = [ 0, 0, 0 ];
    }
    else {
        die "can't parse line: $line!";
    }
    $id++;
}

my $steps = 1;
my @cycles = ( [], [], [] );
while ( any { scalar @{ $cycles[$_] } == 0 } ( 0 .. 2 ) ) {
    say "After $steps steps:" if $debug;
    foreach ( 0 .. 3 ) {
        printf(
            "pos=<x=%2d, y=%2d, z=%2d>, vel=<x=%2d, y=%2d, z=%2d>\n",
            @{ $moons[$_]->{pos} },
            @{ $moons[$_]->{vel} }
        ) if $debug;
    }
    print "\n" if $debug;
    my @deltas;
    foreach my $i ( 0 .. 3 ) {
        foreach my $j ( 0 .. 3 ) {
            next if $i == $j;
            foreach my $k ( 0 .. 2 ) {    # x,y,z
                my $delta = 0;
                if ( $moons[$i]->{pos}->[$k] < $moons[$j]->{pos}->[$k] ) {
                    $delta = $delta + 1;
                }
                elsif ( $moons[$i]->{pos}->[$k] > $moons[$j]->{pos}->[$k] ) {
                    $delta = $delta - 1;

                }
                elsif ( $moons[$i]->{pos}->[$k] == $moons[$j]->{pos}->[$k] ) {
                }
                else {
                    die "how did we get here?!";
                }
                push @{ $deltas[$i]->[$k] }, $delta;
            }
        }
        for my $k ( 0 .. 2 ) {
            my $sum = sum( @{ $deltas[$i]->[$k] } );
            $moons[$i]->{vel}->[$k] += $sum;
        }

    }
    foreach my $i ( 0 .. 3 ) {
        foreach my $k ( 0 .. 2 ) {

            $moons[$i]->{pos}->[$k] += $moons[$i]->{vel}->[$k];
        }
    }

    # energy for part 1
    if ( $steps == 1000 ) {
        my $total;
        for my $i ( 0 .. 3 ) {
            my $pot = sum map { abs($_) } @{ $moons[$i]->{pos} };

            my $kin = sum map { abs($_) } @{ $moons[$i]->{vel} };

            #    say "id: $i pot: $pot kin: $kin";
            $total += ( $pot * $kin );
        }
        is( $total, 8044, "part 1" );
        say "Part 1:", $total;

    }

    # check if we have a repeat
    # for each dimension
    for my $k ( 0 .. 2 ) {
        if ( all { $moons[$_]->{pos}->[$k] == $initial_pos[$_]->[$k] }
            ( 0 .. 3 )
              and all { $moons[$_]->{vel}->[$k] == 0 } ( 0 .. 3 ) )
        {
            say "cycle for $k at step $steps";
            push @{ $cycles[$k] }, $steps;
        }
    }

    $steps++;
}

my $part2 = lcm( map { $cycles[$_]->[0] } ( 0 .. 2 ) );
is( $part2, 362375881472136, "part 2" );
say "Part 2: ", $part2;
done_testing;

