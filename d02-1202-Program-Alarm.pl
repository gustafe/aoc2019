# Advent of Code 2019 Day 2 - 1202 Program Alarm - complete solution
# Problem link: http://adventofcode.com/2019/day/2
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d02
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################
#! /usr/bin/env perl
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum all/;
use Data::Dumper;

#### INIT - load input data from file into array
my $testing = 0;
use Test::Simple tests => 6;
my @input;
my $file = 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }
close $fh;
### CODE
my @state;
sub dump_state;
sub run;
my $halt    = 99;
my %opcodes = (
    1 => \&add,
    2 => \&mult,
);

    my @tests;
    while (<DATA>) {
        chomp;
        push @tests, $_;
    }

    foreach my $line (@tests) {

        #	say $line;
        my ( $input, $output ) = split / /, $line;

        #	say "$input $output";
        @state = split( ',', $input );
        run();
        ok( join( ',', @state ) eq $output );
    }


my @initial = split( /,/, $input[0] );
@state = @initial;

my $cur;
my ( $part1, $part2 );
my $target = 19690720;
LOOPS: foreach my $noun ( 0 .. 99 ) {
    foreach my $verb ( 0 .. 99 ) {
        @state    = @initial;
        $state[1] = $noun;
        $state[2] = $verb;
        run();
        if ( $noun == 12 and $verb == 2 ) {
            $part1 = $state[0];
            say "Part 1: ", $part1;
        }
        if ( $state[0] == $target ) {
            $part2 = 100 * $noun + $verb;
            say "Part 2: ", $part2;
            last LOOPS;
        }
    }
}
ok( $part1 == 5434663 );
ok( $part2 == 4559 );
### Subs

sub add {
    my ( $i, $j ) = @_;
    return $state[$i] + $state[$j];
}

sub mult {
    my ( $i, $j ) = @_;
    return $state[$i] * $state[$j];
}

sub dump_state {
    say join( ',', @state );
}

sub run {
    my $cur = 0;
    while ( $state[$cur] != $halt ) {
        my ( $op, $in1, $in2, $out ) =
          @state[ $cur, $cur + 1, $cur + 2, $cur + 3 ];
        last unless all { defined $_ } ( $in1, $in2, $out );
        my $res;
        die "unknown op: $state[$cur]" unless defined $opcodes{$op};
        $res = $opcodes{$op}->( $in1, $in2 );
        $state[$out] = $res;
        $cur += 4;
    }
}

__DATA__
1,0,0,0,99 2,0,0,0,99
2,3,0,3,99 2,3,0,6,99
2,4,4,5,99,0 2,4,4,5,99,9801
1,1,1,4,99,5,6,0,99 30,1,1,4,2,5,6,0,99
