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
my $run_nr = 1;
while (<DATA>) {
    chomp;
    my @data              = split( /\|/, $_ );
    my $part2             = pop @data;
    my $part1             = pop @data;
    my $energy_loop_count = pop @data;
    my $moons;
    my $initial_pos;
    my $id = 0;

    foreach my $line (@data) {
        if ( $line =~ m/<x=(-?\d+), y=(-?\d+), z=(-?\d+)>/ ) {
            my @pos = ( $1, $2, $3 );
            $moons->[$id]->{pos} = [@pos];
            push @{$initial_pos}, [@pos];
            $moons->[$id]->{vel} = [ 0, 0, 0 ];
        }
        else {
            die "can't parse line: $line!";
        }
        $id++;
    }


    my $res = run_code( $moons, $initial_pos, $energy_loop_count );
    is( $res->[0], $part1, "test $run_nr part 1");
    is( $res->[1], $part2, "test $run_nr part 2");
#    next unless $run_nr==3;
    say "==Answers==";
    say "Part 1: $res->[0]";
    say "Part 2: $res->[1]";
        $run_nr++;
}

### CODE

sub run_code {
    my ( $matrix, $start_matrix, $energy_loop_count ) = @_;
    my $steps = 1;
    my $energy;
    my @cycles = ( [], [], [] );
    while ( any { scalar @{ $cycles[$_] } == 0 } ( 0 .. 2 ) ) {
        my @deltas;
        foreach my $i ( 0 .. 3 ) {
            foreach my $j ( 0 .. 3 ) {
                next if $i == $j;
                foreach my $k ( 0 .. 2 ) {    # x,y,z
                    my $delta = 0;
                    if ( $matrix->[$i]->{pos}->[$k] <
                        $matrix->[$j]->{pos}->[$k] )
                    {
                        $delta = $delta + 1;
                    }
                    elsif ( $matrix->[$i]->{pos}->[$k] >
                        $matrix->[$j]->{pos}->[$k] )
                    {
                        $delta = $delta - 1;

                    }
                    elsif ( $matrix->[$i]->{pos}->[$k] ==
                        $matrix->[$j]->{pos}->[$k] )
                    {
                    }
                    else {
                        die "how did we get here?!";
                    }
                    push @{ $deltas[$i]->[$k] }, $delta;
                }
            }
            for my $k ( 0 .. 2 ) {
                my $sum = sum( @{ $deltas[$i]->[$k] } );
                $matrix->[$i]->{vel}->[$k] += $sum;
            }

        }
        foreach my $i ( 0 .. 3 ) {
            foreach my $k ( 0 .. 2 ) {

                $matrix->[$i]->{pos}->[$k] += $matrix->[$i]->{vel}->[$k];
            }
        }

        # energy for part 1

        if ( $steps == $energy_loop_count ) {
            for my $i ( 0 .. 3 ) {
                my $pot = sum map { abs($_) } @{ $matrix->[$i]->{pos} };

                my $kin = sum map { abs($_) } @{ $matrix->[$i]->{vel} };

                #    say "id: $i pot: $pot kin: $kin";
                $energy += ( $pot * $kin );
            }
        }

        # check if we have a repeat
        # for each dimension
        for my $k ( 0 .. 2 ) {
            if (
                all { $matrix->[$_]->{pos}->[$k] == $start_matrix->[$_]->[$k] }
                ( 0 .. 3 )
                  and all { $matrix->[$_]->{vel}->[$k] == 0 } ( 0 .. 3 )
              )
            {
                say "cycle for $k at step $steps";
                push @{ $cycles[$k] }, $steps;
            }
        }

        $steps++;
    }

    my $cycle_loops = lcm( map { $cycles[$_]->[0] } ( 0 .. 2 ) );
    return [ $energy, $cycle_loops ];

}

done_testing;

__END__
<x=-1, y=0, z=2>|<x=2, y=-10, z=-7>|<x=4, y=-8, z=8>|<x=3, y=5, z=-1>|10|179|2772
<x=-8, y=-10, z=0>|<x=5, y=5, z=10>|<x=2, y=-7, z=3>|<x=9, y=-8, z=-3>|100|1940|4686774924
<x=-13, y=-13, z=-13>|<x=5, y=-8, z=3>|<x=-6, y=-10, z=-3>|<x=0, y=5, z=-5>|1000|8044|362375881472136
