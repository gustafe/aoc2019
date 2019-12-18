#! /usr/bin/env perl
# Advent of Code 2019 Day 15 - Oxygen System - complete solution
# Problem link: http://adventofcode.com/2019/day/15
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d15
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;
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
my $limit = shift || 10;
### CODE
my $program = [ split( /,/, $file_contents[0] ) ];

my $res = {
    state     => [@$program],
    positions => [ 0, 0 ]
};

my $Map;
my @start = ( 21, 21 );
my $dpos = [@start];
$Map->{ $dpos->[0] }->{ $dpos->[1] } = '>';
my $visited;
$visited->{ $dpos->[0] }->{ $dpos->[1] }++;

my $out;
my $orientation = 1;                                       # start north
my %labels = ( 1 => 'N', 2 => 'S', 3 => 'W', 4 => 'E' );

# north (1), south (2), west (3), and east (4)
my %ccw = ( 1 => 3, 3 => 2, 2 => 4, 4 => 1 );
my %cw  = ( 1 => 4, 4 => 2, 2 => 3, 3 => 1 );

my $count = 1;
my @sought;
while ( $visited->{ $start[0] }->{ $start[1] } < 2 ) {
    my $cur = [@$dpos];

    $res = run_vm(
        {
            state     => $res->{state},
            positions => $res->{positions},
            input_ary => [$orientation]
        }
    );
    plot( $orientation, $res->{output_ary}->[0] );
    if ( $dpos->[0] != $cur->[0] or $dpos->[1] != $cur->[1] ) {  # we have moved
            # keep orientation
        $orientation = $cw{$orientation};
        $visited->{ $dpos->[0] }->{ $dpos->[1] }++;
    }
    else {
        # turn so we have our right hand on the wall
        $orientation = $ccw{$orientation};
    }
    $count++;
}
my @node;
paint_map();
say join( ',', @sought );

# find shortest path, overkill with Djikstras
my $infinity = 'inf';

#my $root = join(',',@start);
for my $r ( 0 .. 40 ) {
    for my $c ( 0 .. 40 ) {
        if ( defined $Map->{$r}->{$c} and $Map->{$r}->{$c} ne '█' ) {
            push @node, join( ',', ( $r, $c ) );
        }
    }
}
my $dist1 = djikstras( join( ',', @start ) );
my $part1 = $dist1->{ join( ',', @sought ) };

my $dist2 = djikstras( join( ',', @sought ) );
my $part2 = $dist2->{'1,27'};

is( $part1, 424, "Part 1: $part1" );
is( $part2, 446, "Part 2: $part2" );
done_testing;

#foreach my $n (sort {$dist2->{$b} <=> $dist2->{$a}} keys  %{$dist2}) {    say "$n $dist2->{$n}";}
sub djikstras {
    my ($root) = @_;
    my @unsolved = @node;
    my @solved;
    my %dist;
    my %edge;
    my %prev;
    my $bydistance = sub {
            $dist{$a} eq $infinity ? +1
          : $dist{$b} eq $infinity ? -1
          :                          $dist{$a} <=> $dist{$b};
    };

    # calculate edges
    for my $r ( 0 .. 40 ) {
        for my $c ( 0 .. 40 ) {

            # try to move
            for my $d ( [ -1, 0 ], [ 1, 0 ], [ 0, -1 ], [ 0, 1 ] ) {
                my ( $r2, $c2 ) = ( $r + $d->[0], $c + $d->[1] );
                if ( defined $Map->{$r2}->{$c2}
                    and $Map->{$r2}->{$c2} ne '█' )
                {
                    $edge{ join( ',', $r, $c ) }->{ join( ',', $r2, $c2 ) } = 1;
                }
            }
        }
    }
    foreach my $n (@node) {
        $dist{$n} = $infinity;
        $prev{$n} = $n;
    }
    $dist{$root} = 0;
    while (@unsolved) {
        @unsolved = sort { &{$bydistance} } @unsolved;
        my $n = shift @unsolved;
        push @solved, $n;
        foreach my $n2 ( keys %{ $edge{$n} } ) {
            if (   $dist{$n2} eq $infinity
                || $dist{$n2} > ( $dist{$n} + $edge{$n}->{$n2} ) )
            {
                $dist{$n2} = $dist{$n} + $edge{$n}->{$n2};
                $prev{$n2} = $n;
            }
        }
    }
    return \%dist;
}

sub paint_map {
    foreach my $row ( 0 .. 40 ) {
        print $row% 10;
        foreach my $col ( 0 .. 40 ) {
            if ( $dpos->[0] == $row and $dpos->[1] == $col ) {
                print $labels{$orientation};
            }
            else {
                print $Map->{$row}->{$col} ? $Map->{$row}->{$col} : ' ';
            }
            if ( defined $Map->{$row}->{$col}
                and $Map->{$row}->{$col} eq '*' )
            {
                @sought = ( $row, $col );
            }
        }
        print "\n";
    }
    print ' ';
    foreach ( 0 .. 40 ) {
        print $_% 10;
    }
    print ' ' . join( ',', @$dpos ) . "\n";
}

sub plot {
    my ( $dir, $out ) = @_;

    # mark map
    my %markers = ( 0 => '█', 1 => '•', 2 => '*' );

    if ( $dir == 1 ) {    # N
        $Map->{ $dpos->[0] - 1 }->{ $dpos->[1] } = $markers{$out};
        $dpos->[0]-- unless $out == 0;
    }
    elsif ( $dir == 2 ) {    #S
        $Map->{ $dpos->[0] + 1 }->{ $dpos->[1] } = $markers{$out};
        $dpos->[0]++ unless $out == 0;
    }
    elsif ( $dir == 3 ) {    #W
        $Map->{ $dpos->[0] }->{ $dpos->[1] - 1 } = $markers{$out};
        $dpos->[1]-- unless $out == 0;
    }
    elsif ( $dir == 4 ) {    #E
        $Map->{ $dpos->[0] }->{ $dpos->[1] + 1 } = $markers{$out};
        $dpos->[1]++ unless $out == 0;
    }

}

