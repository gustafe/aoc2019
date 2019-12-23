#! /usr/bin/env perl
# Advent of Code 2019 Day 23 - Category Six - complete solution
# Problem link: http://adventofcode.com/2019/day/23
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d23
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum all/;
use Data::Dumper;
use Test::More;
use lib '/home/gustaf/prj/AdventOfCode/Intcode';
use Intcode qw/run_vm/;

#### INIT - load input data from file into array
my $testing = 0;
my $debug   = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
my $program = [ split( /,/, $file_contents[0] ) ];
my %nics;
my %queues;
my $NAT_id = 255;
my $prev_Y = undef;
my $round  = 1;
my ( $part1, $part2 ) = ( undef, undef );

# initialize the NICs
foreach my $id ( 0 .. 49 ) {
    say "initializing $id... " if $debug;
    my $res = run_vm(
        {
            state     => [@$program],
            positions => [ 0, 0 ],
            input_ary => [$id]
        }
    );
    if ( scalar @{ $res->{output_ary} } > 2 ) {    # we get a packet immediately
        say "  packet emitted..." if $debug;
        while ( @{ $res->{output_ary} } ) {
            print Dumper @{ $res->{output_ary} } if $debug;
            my $dest = shift @{ $res->{output_ary} };
            push @{ $queues{$dest} },
              [ shift @{ $res->{output_ary} }, shift @{ $res->{output_ary} } ];
        }
    }
    $nics{$id} = {
        state     => $res->{state},
        positions => $res->{positions}
    };
}
LOOP: while (1) {
    if ($debug) {
        foreach my $addr ( sort { $a <=> $b } keys %queues ) {
            if ( scalar @{ $queues{$addr} } > 0 ) {
                print "$addr: ";
                for my $p ( @{ $queues{$addr} } ) {
                    printf( "[%d,%d]", @$p );
                }
                print "\n";
            }
            else {

                say "$addr: []";
            }
        }

    }
    foreach my $id ( 0 .. 49 ) {
        say "NIC $id working..." if $debug;
        my @list;
        if ( exists $queues{$id} and scalar @{ $queues{$id} } > 0 ) {
            while ( @{ $queues{$id} } ) {
                say "we have inputs waiting... " if $debug;
                push @list, shift @{ $queues{$id} };
            }
        }
        else {
            push @list, [-1];

        }
        while (@list) {
            my $res = run_vm(
                {
                    state     => $nics{$id}->{state},
                    positions => $nics{$id}->{positions},
                    input_ary => shift @list
                }
            );
            if ( scalar @{ $res->{output_ary} } > 2 ) {
                say "  packet(s) emitted..." if $debug;
                while ( @{ $res->{output_ary} } ) {
                    my ( $dest, $X, $Y ) =
                      splice( @{ $res->{output_ary} }, 0, 3 );
                    printf( "[%2d %d %d]", ( $dest, $X, $Y ) ) if $debug;
                    if ( $dest != $NAT_id ) {
                        push @{ $queues{$dest} }, [ $X, $Y ];
                    }
                    else {
                        # overwrite existing value
                        $queues{$dest}->[0] = [ $X, $Y ];
                    }

                    print "\n" if $debug;

                }
            }
            $nics{$id} = {
                state     => $res->{state},
                positions => $res->{positions}
            };
        }

    }

    # check if every NIC is idle...
    if ( all { scalar @{ $queues{$_} } == 0 }
        grep { $_ != $NAT_id } keys %queues )
    {
        if ($debug) {
            say "all NICs are idle!";
            printf( "[%d,%d]\n", @{ $queues{$NAT_id}->[0] } );

        }
        if ( $round == 1 ) {
            $part1 = $queues{$NAT_id}->[0]->[1];
        }
        if ( $queues{$NAT_id}->[0]->[1] == $prev_Y ) {
            $part2 = $queues{$NAT_id}->[0]->[1];
            last LOOP;
        }
        push @{ $queues{0} }, [ @{ $queues{$NAT_id}->[0] } ];
        $prev_Y = $queues{$NAT_id}->[0]->[1];
        $round++;
    }
}

is( $part1, 23057, "Part 1: $part1" );
is( $part2, 15156, "Part 2: $part2" );
done_testing();
