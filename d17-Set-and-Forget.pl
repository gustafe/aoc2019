#! /usr/bin/env perl
# Advent of Code 2019 Day 17 - Set and Forget - complete solution
# Problem link: http://adventofcode.com/2019/day/17
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d17
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################

use Modern::Perl '2015';
# useful modules
use List::Util qw/sum any all/;
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
my $res = run_vm(
    {
        state     => [@$program],
        positions => [ 0, 0 ],
        input_ary => []
    }
);
my $Map;

my $row;
foreach ( @{ $res->{output_ary} } ) {

    if ( $_ != 10 ) {
        push @$row, $_;
    }
    else {
        push @$Map, $row;
        $row = [];
    }

}

#print_grid();

# part1
my $crosses;
for ( my $r = 0 ; $r < scalar @{$Map} ; $r++ ) {
    for ( my $c = 0 ; $c < scalar @{ $Map->[$r] } ; $c++ ) {
        my $cur   = $Map->[$r]->[$c];
        my $left  = $Map->[$r]->[ $c - 1 ];
        my $right = $Map->[$r]->[ $c + 1 ];
        my $up    = $Map->[ $r - 1 ]->[$c];
        my $down  = $Map->[ $r + 1 ]->[$c];

        if ( all { $_ == ord('#') }
            map { defined $_ ? $_ : 0 } ( $cur, $up, $down, $left, $right ) )
        {
            $crosses += $r * $c;
        }
    }
}

is( $crosses, 6024, "Part 1: $crosses" );

$program->[0] =2;

# this sequence found by inspection:
my $seq =  'A,B,A,B,C,C,B,A,B,C';
my $s_A = 'L,12,L,6,L,8,R,6';
my $s_B = 'L,8,L,8,R,4,R,6,R,6';
my $s_C = 'L,12,R,6,L,8';

my $input;
for my $str ($seq, $s_A, $s_B,$s_C) {
    my @a=map{ord($_)}((split(//,$str)));
    push @$input,(@a,10);
}

push @$input, (ord('n'),10);
$res = run_vm({state=>[@$program],
	       positions=>[0,0],
		  input_ary=>[@$input]});


my $part2=$res->{output_ary}->[-1];
is($part2 ,897344 ,"Part 2: $part2");
done_testing();

sub dump_output {
    my ( $out ) = @_;
    while (@$out) {
	my $c = shift @$out;
	print $c>127?$c:chr($c);
    }
}
sub print_grid {
    foreach my $row (@{$Map}) {
	foreach my $chr (@{$row}) {

	    print chr($chr);
	}
	print "\n";
    }

}
