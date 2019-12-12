#! /usr/bin/env perl
# Advent of Code 2019 Day 10 - Monitoring Station - complete solution
# Problem link: http://adventofcode.com/2019/day/10
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d10
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum any/;
use Data::Dumper;
use Test::More;
use Math::Trig;
#### INIT - load input data from file into array
my $testing = 0;
my $debug   = 0;

my @files   = ('input.txt');
my @correct = ( '292,20,20', 317 );
my $testnr  = 0;
foreach my $file (@files) {
    my @file_contents;
    open( my $fh, '<', $file );
    while (<$fh>) {
        chomp;
        s/\r//gm;
        push @file_contents, $_;
    }
    close $fh;
    my $y = 0;
    my $x;
    my $Map;
    while (@file_contents) {
        $x = 0;
        foreach ( split( //, shift @file_contents ) ) {
            if ( $_ eq '#' ) {
                $Map->{$x}->{$y} = 1;
            }
            $x++;
        }
        $y++;
    }

    my $seen = find_occlusions($Map);
    my @result;
    foreach my $x ( keys %$seen ) {
        foreach my $y ( keys %{ $seen->{$x} } ) {
            push @result, [ scalar keys %{ $seen->{$x}->{$y} }, $x, $y ];

        }
    }
    my $ans = ( sort { $b->[0] <=> $a->[0] } @result )[0];
    is( join( ',', @$ans ), $correct[$testnr], "part 1 - test $testnr" );
    printf( "Part 1: %d at (%d,%d)\n", @$ans );
    my $part2;

    $part2 = fire_laser( $seen, $ans );
    is( $part2, $correct[ $testnr + 1 ], "part 2 - test $testnr" );
    say "Part 2: ", $part2;

    $testnr++;

}

done_testing;

sub fire_laser {
    my ( $data, $center ) = @_;
    shift @$center;    # discard count
    my %angles = %{ $data->{ $center->[0] }->{ $center->[1] } };

    # re-sort for running
    my @list;
    my @tail;
    for my $angle ( sort { $a <=> $b } keys %angles ) {
        if ( $angle < -90 ) { # this value found by inspection
            push @tail, $angle;
        }
        else {
            push @list, $angle;
        }
	# reorder by distance
	my @objects = sort {$a->[0] <=> $b->[0]} @{$angles{$angle}};
	$angles{$angle} = [@objects];
    }
    my $ans;
    my $count   = 1;
    foreach my $entry (@list,@tail) {
	my $target = shift @{$angles{$entry}};
	if ($count==200) {
	    $ans = $target->[1]*100 + $target->[2];
	    last;
	}
	$count++;
    }
    die "seems there's a flaw in the algorithm!" unless defined $ans;
    return $ans;
}

sub find_occlusions {
    my ($map) = @_;
    my $result;
    foreach my $i ( keys %$map ) {
        foreach my $j ( keys %{ $map->{$i} } ) {
            foreach my $x ( keys %$map ) {
                foreach my $y ( keys %{ $map->{$x} } ) {
                    next if ( $x == $i and $y == $j );    # skip same point

                    # angle between (i,j) and (x,y)
                    my $key = sprintf(
                        "%.06f",

                        atan2( ( $y - $j ), ( $x - $i ) ) * 180 / pi

                    );
                    printf( "Angle between (%d,%d) and (%d,%d): %s\n",
                        $i, $j, $x, $y, $key )
                      if $debug;
                    my $cartesian = sqrt( ( $x - $i )**2 + ( $y - $j )**2 );
                    push @{ $result->{$i}->{$j}->{$key} },
                      [ $cartesian, $x, $y ];
                }
            }
        }
    }
    return $result;
}

