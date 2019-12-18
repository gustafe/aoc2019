#! /usr/bin/env perl
# Advent of Code 2019 Day 14 - Space Stoichiometry - complete solution
# Problem link: http://adventofcode.com/2019/day/14
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d14
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;
use Data::Dumper;
use Test::More;
#### INIT - load input data from file into array
my $testing = shift || 0;
my $debug = 0;
my @file_contents;
my $file = $testing ? 'test' . $testing . '.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
my $reactions;
my %store;
while (@file_contents) {
    my ( $LHS, $RHS ) = split( / \=\> /, shift @file_contents );
    my $reqs;
    for my $el ( split( /,/, $LHS ) ) {
        if ( $el =~ m/(\d+) (\S+)/ ) {
            $reqs->{$2} = $1;
	    $store{$2}=0;
        }
        else {
            die "can't parse $el!";
        }
    }
    if ( $RHS =~ m/(\d+) (\S+)/ ) {
        $reactions->{$2} = {
            amount   => $1,
            requires => $reqs
        };
        my @reqlist = keys %$reqs;
        if ( scalar @reqlist == 1 and $reqlist[0] eq 'ORE' ) {
            $store{$2} = 0;
        }

    }
    else {
        die "can't parse $RHS";
    }
}
# part 1
my $fuel_amount = 1;
my $part1 = ore_per_fuel($fuel_amount);
my %correct = ( 1=>31, 2=>165,3=>13312,4=>180697,5=>2210736,live=>220019);
if ($testing != 0){

    is ($part1, $correct{$testing}, "testfile $file: $part1");
}
else {  is ($part1, $correct{live}, "Part 1: $part1");}
# part 2
if ($testing==1 or $testing==2) {
    done_testing;
    exit 0;
}
# 3 82892753
# 4 5586022
# 5 460664
# live 5650230
my %ranges = ( 3=>[0,90_000_000],
	       4=>[0,6_000_000],
	       5=>[0,500_000],
	       live=>[0,6_000_000]);
my %correct2 = ( 3=>    82892753,
		 4=>     5586022,
		 5=>      460664,
		 live => 5650230);
# binary search
my $target = 1000000000000;
my $L = $ranges{$testing?$testing:'live'}->[0];
my $R = $ranges{$testing?$testing:'live'}->[1];
while ($L < $R) {
    my $m = int( ($L+$R)/2);
    if (ore_per_fuel($m)> $target ) {
	$R = $m
    } else {
	$L = $m+1
    }
}
my $part2 = $L-1;
if ($testing != 0){

    is ($part2, $correct2{$testing}, "testfile $file: $part2");
}
else {  is ($part2, $correct2{live}, "Part 2: $part2");}

done_testing;



sub ore_per_fuel {
    my ($given) = @_;
    my @queue;
    my $ore_count = 0;
    foreach my $el ( sort keys %{ $reactions->{FUEL}->{requires} } ) {
        push @queue, [ $el, $reactions->{FUEL}->{requires}->{$el} * $given ];
    }
    dump_queue() if $debug;

    while (@queue) {
        my ( $cur, $needed ) = @{ shift @queue };
        if ( exists $reactions->{$cur}->{requires}->{ORE} ) {
            print "[end] Needed: $needed of $cur" if $debug;

            if ( $store{$cur} > $needed ) {
                say " grabbing from store" if $debug;
                $store{$cur} -= $needed;
            }
            else {
                # add from store
                $needed -= $store{$cur};
                $store{$cur} = 0;
                say " reduced to $needed" if $debug;
                next if $needed == 0;

                # consume ORE for this reagent, store excess
                my $multiple = 1;
                my $yield    = $reactions->{$cur}->{amount};
                while ( $needed % $yield != 0 ) {
                    $needed++;
                    $store{$cur}++;
                }
                $needed = $needed / $yield;
                printf(
                    "adding %d x %d = %d to total\n",
                    $needed,
                    $reactions->{$cur}->{requires}->{ORE},
                    $needed * $reactions->{$cur}->{requires}->{ORE}
                ) if $debug;

                $ore_count += $needed * $reactions->{$cur}->{requires}->{ORE};

            }
        }
        else {
            print "[mid] Needed: $needed of $cur" if $debug;
            if ( $store{$cur} > $needed ) {
                say " grabbing from store" if $debug;
                $store{$cur} -= $needed;
                next;
            }
            else {
                $needed -= $store{$cur};
                $store{$cur} = 0;
                say " reduced to $needed" if $debug;
                next if $needed == 0;
                my $yield = $reactions->{$cur}->{amount};
                if ( $needed < $yield ) {
                    say "We will generate an excess of ", $yield - $needed,
                      ", storing"
                      if $debug;
                    $store{$cur} = $yield - $needed;
                    $needed = 1;
                }
                else {
                    while ( $needed % $yield != 0 ) {
                        $needed++;
                        $store{$cur}++;
                        say "Increasing to $needed" if $debug;
                    }
                    $needed = $needed / $yield;

                }
            }
            foreach my $el ( keys %{ $reactions->{$cur}->{requires} } ) {
                push @queue,
                  [ $el, $reactions->{$cur}->{requires}->{$el} * $needed ];
            }
        }

        dump_queue() if $debug;
    }
    return $ore_count;

}

