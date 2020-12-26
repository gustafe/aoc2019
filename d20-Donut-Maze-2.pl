#! /usr/bin/env perl
# Advent of Code 2019 Day 20 - Donut Maze - part 2
# Problem link: http://adventofcode.com/2019/day/20
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d20
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum all/;
use Data::Dump qw/dump/;
use Test::More tests => 1;
use Time::HiRes qw/gettimeofday tv_interval/;

my $start_time = [gettimeofday];

#### INIT - load input data from file into array
my $testing = 0;
my $debug   = 0;
my @file_contents;
my $file = $testing ? 'test_2.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
my $Map;
foreach my $line (@file_contents) {
    push @$Map, [ split( //, $line ) ];
}

# scan for wormholes
my %wormholes;

for ( my $row = 0; $row < scalar @$Map; $row++ ) {

    for ( my $col = 0; $col < scalar @{ $Map->[$row] }; $col++ ) {

        # only consider tiles we can occupy
        next unless $Map->[$row]->[$col] eq '.';

        # read left
        if ( all { $Map->[$row]->[ $col - $_ ] =~ m/[A-Z]/ } ( 2, 1 ) ) {
            push @{$wormholes{$Map->[$row]->[$col-2].$Map->[$row]->[$col-1]}},
                { exit  => [ $row, $col ], entry => [ $row, $col - 1 ] };
        }

        # read up
        if ( all { $Map->[ $row - $_ ]->[$col] =~ m/[A-Z]/ } ( 2, 1 ) ) {
            push @{$wormholes{$Map->[$row-2]->[$col].$Map->[$row-1 ]->[$col]}},
                { exit  => [ $row,     $col ], entry => [ $row - 1, $col ] };
        }

        # read right
        if ( all { $Map->[$row]->[ $col + $_ ] =~ m/[A-Z]/ } ( 1, 2 ) ) {
            push @{$wormholes{$Map->[$row]->[$col+1].$Map->[$row]->[$col+2]}},
                { exit  => [ $row, $col ], entry => [ $row, $col + 1 ] };
        }

        # read down
        if ( all { $Map->[ $row + $_ ]->[$col] =~ m/[A-Z]/ } ( 1, 2 ) ) {
            push @{$wormholes{$Map->[$row+1]->[$col].$Map->[$row+2]->[$col]}},
	      { exit  => [ $row,     $col ], entry => [ $row + 1, $col ] };
        }
    }
}

my $entries;
for my $lbl ( keys %wormholes ) {
    next if ( $lbl eq 'AA' or $lbl eq 'ZZ' );
    die unless scalar @{ $wormholes{$lbl} } == 2;
    $entries->{ $wormholes{$lbl}->[0]->{entry}->[0] }
        ->{ $wormholes{$lbl}->[0]->{entry}->[1] } = {
        exit  => $wormholes{$lbl}->[1]->{exit},
        entry => $wormholes{$lbl}->[1]->{entry},
        label => $lbl
        };
    $entries->{ $wormholes{$lbl}->[1]->{entry}->[0] }
        ->{ $wormholes{$lbl}->[1]->{entry}->[1] } = {
        exit  => $wormholes{$lbl}->[0]->{exit},
        entry => $wormholes{$lbl}->[0]->{entry},
        label => $lbl
        };
}
# identify the edges
my %edges ;
my @rows_e = sort { $a <=> $b } keys %$entries;
$edges{rows}->{outer}->{ shift @rows_e }++;
$edges{rows}->{outer}->{ pop @rows_e }++;
$edges{rows}->{inner}->{ shift @rows_e }++;
$edges{rows}->{inner}->{ pop @rows_e }++;
my %cols_e;
foreach my $r (@rows_e) {
    map { $cols_e{$_}++ } keys %{ $entries->{$r} };
}
my @cols_e = sort { $a <=> $b } keys %cols_e;

$edges{cols}->{outer}->{ shift @cols_e }++;
$edges{cols}->{outer}->{ pop @cols_e }++;
$edges{cols}->{inner}->{ shift @cols_e }++;
$edges{cols}->{inner}->{ pop @cols_e }++;

my ( $start_a, $end_z )
    = ( $wormholes{AA}->[0]->{exit}, $wormholes{ZZ}->[0]->{exit} );
printf( "finding path between AA at [%2d,%2d] and ZZ at [%2d,%2d]\n",
    @$start_a, @$end_z );

#exit 0;
my $part2 = find_shortest_path( $wormholes{AA}->[0]->{exit},
    $wormholes{ZZ}->[0]->{exit} );
is( $part2, 6546, "Part 2: " . $part2 );
say "Duration: ", tv_interval($start_time) * 1000, "ms";

sub find_shortest_path {
    my ( $start, $end ) = @_;
    my $seen;
    my $shortest = 0;
    push @$start, 0;    # add initial level
    my @states = ( [ 0, $start ] );

LOOP: {
        while (@states) {
            my $move = shift @states;
            my $step = $move->[0];
            my ( $r, $c, $l ) = @{ $move->[1] };
            if ( exists $seen->{$r}->{$c}->{$l} ) {
                next;
            }
            else {
                $seen->{$r}->{$c}->{$l}++;
            }

            # try to move
            $step += 1;
            my @new = (
                [ $r - 1, $c,     $l ],
                [ $r + 1, $c,     $l ],
                [ $r,     $c - 1, $l ],
                [ $r,     $c + 1, $l ]
            );
            while (@new) {
                my $try = shift @new;
                my ( $t_r, $t_c, $t_l ) = @{$try};
                next unless ( defined $Map->[$t_r]->[$t_c] );
                if (    $Map->[$t_r]->[$t_c] ne '#'
                    and $Map->[$t_r]->[$t_c] ne ' ' )
                {
                    if ( exists $entries->{$t_r}->{$t_c} ) {
                        my ( $j_r, $j_c )
                            = @{ $entries->{$t_r}->{$t_c}->{exit} };

                        # how do we move between levels?
                        my $new_l;
                        if (   $edges{rows}->{outer}->{$t_r}
                            or $edges{cols}->{outer}->{$t_c} )
                        {
                            next if $t_l == 0;
                            $new_l = $t_l - 1;

                        }
                        elsif ($edges{rows}->{inner}->{$t_r}
                            or $edges{cols}->{inner}->{$t_c} )
                        {
                            $new_l = $t_l + 1;
                        }
                        else {
                            die "can't figure out the level: $t_r,$t_c";
                        }
                        printf(
                            "step %2d: hit %s at [%2d,%2d,%2d], jumping to [%2d,%2d,%2d], adding [%2d,%2d,%2d] to seen list, setting level from %d to %d\n",
                            $step, $entries->{$t_r}->{$t_c}->{label}, $t_r,
                            $t_c, $t_l, $j_r, $j_c, $new_l,
                            @{ $entries->{$t_r}->{$t_c}->{entry} }, $new_l,
                            $t_l, $new_l
                        ) if $debug;

                        $seen->{ $entries->{$t_r}->{$t_c}->{entry}->[0] }
                            ->{ $entries->{$t_r}->{$t_c}->{entry}->[1] }
                            ->{$new_l}++;
                        $try = [ $j_r, $j_c, $new_l ];
                    }

                    if (    $t_r == $end->[0]
                        and $t_c == $end->[1]
                        and $t_l == 0 )
                    {
                        $shortest = $step;
                        last LOOP;
                    }
                    push @states, [ $step, $try ];
                }
            }
        }
    }
    return $shortest;
}
