#! /usr/bin/env perl
# Advent of Code 2019 Day 21 - Springdroid Adventure - complete solution
# Problem link: http://adventofcode.com/2019/day/21
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d21
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

### CODE
my $program = [ split( /,/, $file_contents[0] ) ];

my @ins;
my $walk;
my $res;

# part 1
# https://www.reddit.com/r/adventofcode/comments/edocmd/2019_day_21_part_1_all_41_instruction_solutions/
@ins = ( 'NOT A T',
	 'NOT C J',
	 'OR T J',
	 'AND D J' );
$walk = 'WALK';
my $input;
for my $str ( @ins, $walk ) {
    my @a = map { ord($_) } ( ( split( //, $str ) ) );
    push @$input, ( @a, 10 );
}

$res = run_vm(
    {
        state     => [@$program],
        positions => [ 0, 0 ],
        input_ary => [@$input]
    }
);
my $part1 = $res->{output_ary}->[-1];
is( $part1, 19355227, "Part 1: $part1" );

# Part 2
# https://www.reddit.com/r/adventofcode/comments/edntkk/2019_day_21_minimal_instructions/
@ins = ( 'OR B J',
	 'AND C J',
	 'NOT J J',
	 'AND D J',
	 'AND H J',
	 'NOT A T',
	 'OR T J' );
$walk  = 'RUN';
$input = undef;
for my $str ( @ins, $walk ) {
    my @a = map { ord($_) } ( ( split( //, $str ) ) );
    push @$input, ( @a, 10 );
}
$res = run_vm(
    {
        state     => [@$program],
        positions => [ 0, 0 ],
        input_ary => [@$input]
    }
);

my $part2 = $res->{output_ary}->[-1];
is( $part2, 1143802926, "Part 2: $part2" );
done_testing();

sub dump_output {
    my ($out) = @_;
    while (@$out) {
        my $c = shift @$out;
        print $c> 127 ? $c : chr($c);
    }
}
