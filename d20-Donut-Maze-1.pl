#! /usr/bin/env perl
# Advent of Code 2019 Day 20 - Donut Maze - part 1
# Problem link: http://adventofcode.com/2019/day/20
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d20
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum all/;
use Data::Dumper;
use Test::More;
#### INIT - load input data from file into array
my $testing = 0;
my $debug   = 0;
my @file_contents;
my $file = $testing ? 'test2.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
my $Map;
foreach my $line (@file_contents) {
    push @$Map, [ split( //, $line ) ];
}

# scan for wormholes
my %wormholes;

for ( my $row = 0 ; $row < scalar @$Map ; $row++ ) {

    for ( my $col = 0 ; $col < scalar @{ $Map->[$row] } ; $col++ ) {

        # only consider tiles we can occupy
        next unless $Map->[$row]->[$col] eq '.';

        # read left
        if ( all { $Map->[$row]->[ $col - $_ ] =~ m/[A-Z]/ } ( 2, 1 ) ) {

            push @{     $wormholes{ $Map->[$row]->[ $col - 2 ]
                      . $Map->[$row]->[ $col - 1 ] } },
              {
                exit  => [ $row, $col ],
                entry => [ $row, $col - 1 ]
              };

        }

        # read up
        if ( all { $Map->[ $row - $_ ]->[$col] =~ m/[A-Z]/ } ( 2, 1 ) ) {

            push @{     $wormholes{ $Map->[ $row - 2 ]->[$col]
                      . $Map->[ $row - 1 ]->[$col] } },
              {
                exit  => [ $row,     $col ],
                entry => [ $row - 1, $col ]
              };
        }

        # read right
        if ( all { $Map->[$row]->[ $col + $_ ] =~ m/[A-Z]/ } ( 1, 2 ) ) {
            push @{     $wormholes{ $Map->[$row]->[ $col + 1 ]
                      . $Map->[$row]->[ $col + 2 ] } },
              {
                exit  => [ $row, $col ],
                entry => [ $row, $col + 1 ]
              };
        }

        # read down
        if ( all { $Map->[ $row + $_ ]->[$col] =~ m/[A-Z]/ } ( 1, 2 ) ) {

            push @{     $wormholes{ $Map->[ $row + 1 ]->[$col]
                      . $Map->[ $row + 2 ]->[$col] } },
              {
                exit  => [ $row,     $col ],
                entry => [ $row + 1, $col ]
              };
        }

    }
}

my $entries;
for my $label ( keys %wormholes ) {
    next if ( $label eq 'AA' or $label eq 'ZZ' );
    die unless scalar @{ $wormholes{$label} } == 2;
    $entries->{ $wormholes{$label}->[0]->{entry}->[0] }
      ->{ $wormholes{$label}->[0]->{entry}->[1] } = {
        exit  => $wormholes{$label}->[1]->{exit},
        entry => $wormholes{$label}->[1]->{entry},
        label => $label
      };
    $entries->{ $wormholes{$label}->[1]->{entry}->[0] }
      ->{ $wormholes{$label}->[1]->{entry}->[1] } = {
        exit  => $wormholes{$label}->[0]->{exit},
        entry => $wormholes{$label}->[0]->{entry},
        label => $label
      };
}
my ( $start_a, $end_z ) =
  ( $wormholes{AA}->[0]->{exit}, $wormholes{ZZ}->[0]->{exit} );
printf( "finding path between AA at [%2d,%2d] and ZZ at [%2d,%2d]\n",
	@$start_a, @$end_z );
my $part1 =  find_shortest_path( $wormholes{AA}->[0]->{exit},
    $wormholes{ZZ}->[0]->{exit} );

is( $part1, 568, "Part 1: $part1");
done_testing;

sub find_shortest_path {
    my ( $start, $end ) = @_;
    my $seen;
    my $shortest = 0;
    my @states = ( [ 0, $start ] );
  LOOP: {
        while (@states) {
            my $move = shift @states;
            my $step = $move->[0];
            my ( $r, $c ) = @{ $move->[1] };
            if ( exists $seen->{$r}->{$c} ) {
                next;
            }
            else {
                $seen->{$r}->{$c}++;
            }

            # try to move
            $step += 1;
            my @new =
              ( [ $r - 1, $c ], [ $r + 1, $c ], [ $r, $c - 1 ],
                [ $r, $c + 1 ] );
            while (@new) {
                my $try = shift @new;
                my ( $t_r, $t_c ) = @{$try};
                next unless ( defined $Map->[$t_r]->[$t_c] );
                if (    $Map->[$t_r]->[$t_c] ne '#'
                    and $Map->[$t_r]->[$t_c] ne ' ' )
                {
                    printf( "step %2d: trying [%2d,%2d]\n", $step, @$try )
                      if $debug;

                    if ( exists $entries->{$t_r}->{$t_c} ) {
                        my ( $j_r, $j_c ) =
                          @{ $entries->{$t_r}->{$t_c}->{exit} };
                        printf(
"step %2d: hit %s at [%2d,%2d], jumping to [%2d,%2d], adding [%2d,%2d] to seen list\n",
                            $step,
                            $entries->{$t_r}->{$t_c}->{label},
                            $t_r,
                            $t_c,
                            $j_r,
                            $j_c,
                            @{ $entries->{$t_r}->{$t_c}->{entry} }
                        ) if $debug;

                        $seen->{ $entries->{$t_r}->{$t_c}->{entry}->[0] }
                          ->{ $entries->{$t_r}->{$t_c}->{entry}->[1] }++;
                        $try = [ $j_r, $j_c ];
                    }

                    if ( $t_r == $end->[0] and $t_c == $end->[1] ) {
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
