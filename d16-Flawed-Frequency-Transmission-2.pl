#! /usr/bin/env perl
# Advent of Code 2019 Day 16 - Flawed Frequency Transmission - part 2
# Problem link: http://adventofcode.com/2019/day/16
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d16
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
my $file = $testing ? 'test2_'.$testing.'.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
my @mask = (0, 1, 0, -1);

my $input =$file_contents[0];
my $offset= substr( $input, 0,7);

my @signal =split(//,$input);
for (1..10_000-1) {
    for (0..(length $input)-1) {
	push @signal, $signal[$_];
    }
}
die "not correct length: ", scalar @signal unless scalar @signal == 10_000 * length($input);
@signal = splice(@signal, $offset);
say scalar @signal if $debug; 

my $round = 1;
while ($round <=100) {
    say $round unless $testing;
    my @result;
    unshift @result, $signal[-1];
    for (my $k=scalar @signal-1;$k>=0;$k--) {
	$result[$k]=($signal[$k]+(defined $result[$k+1]?$result[$k+1]:0))%10;
    }
    @signal= @result;
    $round++;
}
my @p2 =splice( @signal, 0,8);
my $part2 = join('',@p2);
my %correct = (1=>84462026
	       ,2=>78725270
	       ,3=>53553731);

if ($testing) {
    is( $part2, $correct{$testing}, "test $testing: ".$correct{$testing});
} else {
    is($part2, 37615297, "Part 2: $part2");    
}


done_testing;
