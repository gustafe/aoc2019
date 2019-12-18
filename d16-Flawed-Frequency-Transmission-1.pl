#! /usr/bin/env perl
# Advent of Code 2019 Day 16 - Flawed Frequency Transmission - part 1
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
my $file = $testing ? 'test'.$testing.'.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
my @mask = (0, 1, 0, -1);

my $input =$file_contents[0];
say "===> $input" if $debug;
my $matrix;
say "calculating matrix...";
generate_matrix( length $input );

my $round = 1;
my @signal = split(//,$input);
while ($round <=100 ) {
    my @result;
    for (my $i=0; $i<scalar @signal;$i++) {
	my $sum;
	for (my $j= $i;$j<scalar @signal; $j++) {
	    $sum += $matrix->[$i]->[$j]*$signal[$j]
	}
	push @result, abs( $sum )%10;
    }
    printf("%03d: %s\n", $round, join('',@result)) if $debug;
    @signal = @result;
    $round++;
}
my $part1 = join('',splice(@signal,0,8));
my %correct = (1=>24176176,
	       2=>73745418,
	       3=>52432133,
	       live=>45834272);
if ($testing) {
    is( $part1, $correct{$testing}, "testing $testing: $part1");
}
else {
    is($part1, $correct{live} ,"Part 1: $part1");    
}

done_testing;
sub generate_matrix {
    my ( $l ) = @_;
    for my $pos (1..$l) {
	my @pattern;
	for my $i (0..3) {
	    push @pattern, ($mask[$i]) x $pos;
	}
	while (scalar @pattern -1 < $l) {
	    @pattern = (@pattern, @pattern);
	}
	shift @pattern;
	push @{$matrix}, [@pattern];
    }
}
