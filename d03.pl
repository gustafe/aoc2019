#! /usr/bin/env perl
# Advent of Code 2019 Day 3 - Crossed Wires - complete solution
# Problem link: http://adventofcode.com/2019/day/3
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d03
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;

use Test::Simple tests => 2;
#### INIT - load input data from file into array
my $testing = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE

my $grid;

sub manhattan_distance;
my %set_line = (
    U => \&up,
    D => \&down,
    L => \&left,
    R => \&right,
);

my $id = 1;
foreach my $line (@input) {
    say "loading a line....";
    my $cur = [ 0, 0, 0 ];
    push @{ $grid->{0}->{0} }, { id => $id, dir => 'O' };
    my @list = split( /,/, $line );
    my $prev = '';
    while (@list) {

        my $move = shift @list;
        if ( $move =~ m/(U|D|L|R)(\d+)/ ) {
            $cur = $set_line{$1}->( $id, $cur, $2 );
        }
        else {
            die "can't parse move: $move";
        }
    }
    $id++;
}

say "finding crossings...";

my @distances;
my @signals;
for my $x ( keys %$grid ) {

    for my $y ( keys %{ $grid->{$x} } ) {
        if ( ref $grid->{$x}->{$y} eq 'ARRAY'
            and scalar @{ $grid->{$x}->{$y} } > 1 )
        {
            my %ids;
            my $signal = 0;
            foreach my $el ( @{ $grid->{$x}->{$y} } ) {
                $ids{ $el->{id} }++;
                $signal += sum( map { $el->{$_} ? $el->{$_} : 0 } ( 1, 2 ) );

            }
            if ( scalar keys %ids > 1 and ( $x != 0 and $y != 0 ) ) {

                # part 1
                push @distances, sum( map { abs($_) } ( $x, $y ) );

                # part 2
                push @signals, $signal;
            }

        }
    }
}

my $part1 = ( sort { $a <=> $b } @distances )[0];
my $part2 = ( sort { $a <=> $b } @signals )[0];

ok( $part1 == 1626 );
ok( $part2 == 27330 );

say "Part 1: $part1";
say "Part 2: $part2";

### Subs

sub up {
    my ( $id,  $start, $steps ) = @_;
    my ( $x_0, $y_0,   $d_0 )   = @$start;

    for ( my $y = 0 ; $y <= $steps ; $y++ ) {
        push @{ $grid->{$x_0}->{ $y_0 + $y } }, { id => $id, $id => $d_0 + $y };
    }
    return [ $x_0, $y_0 + $steps, $d_0 + $steps ];
}

sub down {
    my ( $id,  $start, $steps ) = @_;
    my ( $x_0, $y_0,   $d_0 )   = @$start;

    for ( my $y = 0 ; $y >= -$steps ; $y-- ) {
        push @{ $grid->{$x_0}->{ $y_0 + $y } },
          { id => $id, $id => $d_0 + abs($y) };

    }
    return [ $x_0, $y_0 - $steps, $d_0 + $steps ];
}

sub left {
    my ( $id,  $start, $steps ) = @_;
    my ( $x_0, $y_0,   $d_0 )   = @$start;

    for ( my $x = 0 ; $x >= -$steps ; $x-- ) {
        push @{ $grid->{ $x_0 + $x }->{$y_0} },
          { id => $id, $id => $d_0 + abs($x) };
    }
    return [ $x_0 - $steps, $y_0, $d_0 + $steps ];
}

sub right {
    my ( $id,  $start, $steps ) = @_;
    my ( $x_0, $y_0,   $d_0 )   = @$start;

    for ( my $x = 0 ; $x <= $steps ; $x++ ) {
        push @{ $grid->{ $x_0 + $x }->{$y_0} }, { id => $id, $id => $d_0 + $x };
    }

    return [ $start->[0] + $steps, $start->[1], $d_0 + $steps ];
}
