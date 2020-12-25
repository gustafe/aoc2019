#! /usr/bin/env perl
# Advent of Code 2019 Day 24 - Planet of Discord - part 2
# Problem link: http://adventofcode.com/2019/day/24
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d24
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use List::Util qw/sum min max/;
use Data::Dump qw/dump/;
use Clone qw/clone/;
use Test::More tests=>1;
use Time::HiRes qw/gettimeofday tv_interval/;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array
my $testing = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

my $Map;
my $newMap;

# row, col, N E S W
my %lookup = (
    0 => {
        0 => [ [ -1, 1, 2 ], [ 0,  0, 1 ], [ 0, 1, 0 ], [ -1, 2, 1 ] ],
        1 => [ [ -1, 1, 2 ], [ 0,  0, 2 ], [ 0, 1, 1 ], [ 0,  0, 0 ] ],
        2 => [ [ -1, 1, 2 ], [ 0,  0, 3 ], [ 0, 1, 2 ], [ 0,  0, 1 ] ],
        3 => [ [ -1, 1, 2 ], [ 0,  0, 4 ], [ 0, 1, 3 ], [ 0,  0, 2 ] ],
        4 => [ [ -1, 1, 2 ], [ -1, 2, 3 ], [ 0, 1, 4 ], [ 0,  0, 3 ] ]
    },

    1 => {
        0 => [ [ 0, 0, 0 ], [ 0, 1, 1 ], [ 0, 2, 0 ], [ -1, 2, 1 ] ],
        1 => [ [ 0, 0, 1 ], [ 0, 1, 2 ], [ 0, 2, 1 ], [ 0,  1, 0 ] ],
        2 => [
            [ 0, 0, 2 ],
            [ 0, 1, 3 ],
            [ 1, 0, 0 ],
            [ 1, 0, 1 ],
            [ 1, 0, 2 ],
            [ 1, 0, 3 ],
            [ 1, 0, 4 ],
            [ 0, 1, 1 ]
        ],
        3 => [ [ 0, 0, 3 ], [ 0,  1, 4 ], [ 0, 2, 3 ], [ 0, 1, 2 ] ],
        4 => [ [ 0, 0, 4 ], [ -1, 2, 3 ], [ 0, 2, 4 ], [ 0, 1, 3 ] ]
    },

    2 => {
        0 => [ [ 0, 1, 0 ], [ 0, 2, 1 ], [ 0, 3, 0 ], [ -1, 2, 1 ] ],
        1 => [
            [ 0, 1, 1 ],
            [ 1, 0, 0 ],
            [ 1, 1, 0 ],
            [ 1, 2, 0 ],
            [ 1, 3, 0 ],
            [ 1, 4, 0 ],
            [ 0, 3, 1 ],
            [ 0, 2, 0 ]
        ],

        # 2,2 is the inner square
        3 => [
            [ 0, 1, 3 ],
            [ 0, 2, 4 ],
            [ 0, 3, 3 ],
            [ 1, 0, 4 ],
            [ 1, 1, 4 ],
            [ 1, 2, 4 ],
            [ 1, 3, 4 ],
            [ 1, 4, 4 ]
        ],
        4 => [ [ 0, 1, 4 ], [ -1, 2, 3 ], [ 0, 3, 4 ], [ 0, 2, 3 ] ]
    },

    3 => {
        0 => [ [ 0, 2, 0 ], [ 0, 3, 1 ], [ 0, 4, 0 ], [ -1, 2, 1 ] ],
        1 => [ [ 0, 2, 1 ], [ 0, 3, 2 ], [ 0, 4, 1 ], [ 0,  3, 0 ] ],
        2 => [
            [ 1, 4, 0 ],
            [ 1, 4, 1 ],
            [ 1, 4, 2 ],
            [ 1, 4, 3 ],
            [ 1, 4, 4 ],
            [ 0, 3, 3 ],
            [ 0, 4, 2 ],
            [ 0, 3, 1 ]
        ],
        3 => [ [ 0, 2, 3 ], [ 0,  3, 4 ], [ 0, 4, 3 ], [ 0, 3, 2 ] ],
        4 => [ [ 0, 2, 4 ], [ -1, 2, 3 ], [ 0, 4, 4 ], [ 0, 3, 3 ] ]
    },

    4 => {
        0 => [ [ 0, 3, 0 ], [ 0,  4, 1 ], [ -1, 3, 2 ], [ -1, 2, 1 ] ],
        1 => [ [ 0, 3, 1 ], [ 0,  4, 2 ], [ -1, 3, 2 ], [ 0,  4, 0 ] ],
        2 => [ [ 0, 3, 2 ], [ 0,  4, 3 ], [ -1, 3, 2 ], [ 0,  4, 1 ] ],
        3 => [ [ 0, 3, 3 ], [ 0,  4, 4 ], [ -1, 3, 2 ], [ 0,  4, 2 ] ],
        4 => [ [ 0, 3, 4 ], [ -1, 2, 3 ], [ -1, 3, 2 ], [ 0,  4, 3 ] ]
    },

);

# row,col

### SUBS
sub count_map {
    my ($m) = @_;
    my $count = 0;
    foreach my $level ( keys %$m ) {
        foreach my $row ( keys %{ $m->{$level} } ) {
            foreach my $col ( keys %{ $m->{$level}{$row} } ) {
                $count++ if $m->{$level}{$row}{$col} eq '#';
            }
        }
    }
    return $count;
}

sub count_neighbors {

    my ( $level, $row, $col ) = @_;
    my $count     = 0;
    my @neighbors = @{ $lookup{$row}->{$col} };
    for my $n (@neighbors) {
        no warnings 'uninitialized';
        $count++ if $Map->{ $level + $n->[0] }{ $n->[1] }{ $n->[2] } eq '#';
    }
    return $count;
}

sub dump_map {
    my ($m)      = @_;
    my $minlayer = min( keys %$m );
    my $maxlayer = max( keys %$m );
    my $bugs     = 0;
    for my $layer ( $minlayer - 1, ( sort { $a <=> $b } keys %$m ),
        $maxlayer + 1 )
    {
        say "        Layer $layer";
        for my $r ( 0 .. 4 ) {
            print '                ';
            for my $c ( 0 .. 4 ) {
                if ( $c == 2 and $r == 2 ) {
                    print '?';
                }
                elsif ( defined $m->{$layer}{$r}{$c} ) {
                    print $m->{$layer}{$r}{$c};
                    $bugs++ if $m->{$layer}{$r}{$c} eq '#';

                }
                else {
                    print '.';
                }
            }
            print "\n";
        }
    }
    say "        bugs: $bugs";
}
### CODE
my $row = 0;
for my $line (@file_contents) {
    my $col = 0;
    for my $c ( split( //, $line ) ) {
        $Map->{0}{$row}{$col} = $c;
        $col++;
    }
    $row++;
}

$newMap = clone($Map);
my $tick = 0;
while ( $tick < 200 ) {

    foreach my $level ( keys %$Map ) {
        foreach my $row ( keys %{ $Map->{$level} } ) {
            foreach my $col ( keys %{ $Map->{$level}{$row} } ) {
                my @cells = ( [ $level, $row, $col ] );
                foreach my $n ( @{ $lookup{$row}{$col} } ) {
                    push @cells, [ $level + $n->[0], $n->[1], $n->[2] ];
                }

                foreach my $cell (@cells) {
                    no warnings 'uninitialized';
                    my $count = count_neighbors(@$cell);

                    if ( $Map->{ $cell->[0] }{ $cell->[1] }{ $cell->[2] } eq
                        '#' )
                    {
                        delete $newMap->{ $cell->[0] }{ $cell->[1] }
                            { $cell->[2] }
                            unless $count == 1;
                    }
                    else {
                        if ( $count == 1 or $count == 2 ) {
                            $newMap->{ $cell->[0] }{ $cell->[1] }
                                { $cell->[2] } = '#';
                        }
                    }
                }
            }
        }
    }
    $Map = clone($newMap);
    $tick++;
    say "Time $tick" if $tick % 25 == 0;
}
my $part2 =  count_map($Map);
is( $part2, 1975, "Part 2: ".$part2);
say "Duration: ", tv_interval($start_time) * 1000, "ms";
