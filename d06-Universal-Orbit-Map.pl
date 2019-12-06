#! /usr/bin/env perl
# Advent of Code 2019 Day 6 - Universal Orbit Map - complete solution
# Problem link: http://adventofcode.com/2019/day/6
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d06
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;
use Data::Dumper;
use Test::Simple tests => 2;
#### INIT - load input data from file into array
my $testing = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE

my %orbits;
while (@input) {
    my ( $p, $s ) = split( /\)/, shift @input );
    $orbits{$s} = $p;
}

my $count = 0;
foreach my $s ( keys %orbits ) {
    count_orbits($s);
}
ok( $count == 314702 );
say "Part 1: $count";

# credit: rtbrsp
# https://www.reddit.com/r/adventofcode/comments/e6tyva/2019_day_6_solutions/f9tb2gi/
my %path;
my $S;
my $Y;
my $s;
for ( $s = 'SAN' ; $s ne 'COM' ; $s = $orbits{$s} ) {
    $path{ $orbits{$s} } = $S++;
}
for ( $s = 'YOU' ; !$path{ $orbits{$s} } ; $s = $orbits{$s} ) {
    $Y++;
}
$Y += $path{ $orbits{$s} };
ok( $Y == 439 );
say "Part 2: $Y";

# credit: /u/domm_plix
# https://www.reddit.com/r/adventofcode/comments/e6tyva/2019_day_6_solutions/f9tr612/
sub count_orbits {
    no warnings 'recursion';
    my ($in) = @_;
    return unless exists $orbits{$in};
    $count++;
    count_orbits( $orbits{$in} );
}
