#! /usr/bin/env perl
# Advent of Code 2019 Day 25 - Cryostasis - complete solution
# Problem link: http://adventofcode.com/2019/day/25
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d25
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
my $input;

# the map has been explored manually
# gather the non-lethal items
my @ins = ( 'north', 'take mouse' );
push @ins, ( 'north', 'take pointer' );
push @ins, qw/south south west/;
push @ins, 'take monolith';
push @ins, qw/north west/;
push @ins, ( 'take food ration', 'south', 'take space law space brochure' );
push @ins, qw/north east south south/;
push @ins, ('take sand');
push @ins, qw/south west/;
push @ins, ( 'take asterisk', 'south', 'take mutex' );
push @ins, qw/north east north north east south south west south/;

# these found by brute forcing all combos
push @ins, 'drop pointer';
push @ins, 'drop monolith';
push @ins, 'drop mouse';
push @ins, 'drop sand';
push @ins, 'east';
for my $str (@ins) {
    my @a = map { ord($_) } ( ( split( //, $str ) ) );
    push @$input, ( @a, 10 );
}

my $res = run_vm(
    {
        state     => [@$program],
        positions => [ 0, 0 ],
        input_ary => [@$input]
    }
);

print_output( $res->{output_ary} );

sub print_output {
    my ($out) = @_;
    while (@$out) {
        my $c = shift @$out;
        print $c> 127 ? $c : chr($c);
    }
}
