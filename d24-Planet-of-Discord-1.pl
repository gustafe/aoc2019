#! /usr/bin/env perl
# Advent of Code 2019 Day 24 - Planet of Discord - part 1
# Problem link: http://adventofcode.com/2019/day/24
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d24
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;
use Data::Dumper;
use Test::More;
#### INIT - load input data from file into array
my $testing = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
my $map;
my %patterns;
my $row = 0;
for my $line (@file_contents) {
    my $col = 0;
    for my $c ( split( //, $line ) ) {
        $map->{$row}->{$col} = $c;
        $col++;
    }
    $row++;
}

$patterns{ generate_pattern($map) }++;

my $tick = 0;
my $part1;
LOOP: while (1) {
    my $newmap;
    for my $r ( 0 .. 4 ) {
        for my $c ( 0 .. 4 ) {
            my $bugcount = 0;
            for my $dir ( [ -1, 0 ], [ 0, 1 ], [ 1, 0 ], [ 0, -1 ] ) {
                if ( exists $map->{ $r + $dir->[0] }->{ $c + $dir->[1] }
                    and $map->{ $r + $dir->[0] }->{ $c + $dir->[1] } eq '#' )
                {
                    $bugcount++;
                }
            }
            if ( $map->{$r}->{$c} eq '.'
                and ( $bugcount == 1 or $bugcount == 2 ) )
            {
                $newmap->{$r}->{$c} = '#';
            }
            elsif ( $map->{$r}->{$c} eq '#'
                and ( $bugcount == 0 or $bugcount > 1 ) )
            {
                $newmap->{$r}->{$c} = '.';
            }
            else {
                $newmap->{$r}->{$c} = $map->{$r}->{$c};
            }
        }
    }
    $map = $newmap;
    my $pattern = generate_pattern($map);
    if ( exists $patterns{$pattern} ) {
        $part1 = $pattern;
        last LOOP;
    }
    $patterns{$pattern}++;
    $tick++;
}
is( $part1, 7543003, "Part 1: found recurring pattern at tick $tick: $part1" );
done_testing();

sub generate_pattern {
    my ($m) = @_;
    my $p   = '';
    my $pow = 0;
    my @bio;
    for my $r ( 0 .. 4 ) {
        for my $c ( 0 .. 4 ) {
            $p .= $m->{$r}->{$c};
            if ( $m->{$r}->{$c} eq '#' ) {
                push @bio, 2**$pow;
            }
            $pow++;

        }
    }
    return sum @bio;

    #    return $p;
}

sub print_map {
    my ($m) = @_;
    for my $r ( 0 .. 4 ) {
        for my $c ( 0 .. 4 ) {
            print $m->{$r}->{$c};
        }
        print "\n";
    }
}

