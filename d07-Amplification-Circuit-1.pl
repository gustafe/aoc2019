#! /usr/bin/env perl
# Advent of Code 2019 Day 7 - Amplification Circuit - part 1
# Problem link: http://adventofcode.com/2019/day/7
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d07
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################

use Modern::Perl '2015';
# useful modules
use List::Util qw/sum/;
use Data::Dumper;
use Test::Simple tests=>1;
#### INIT - load input data from file into array
my $testing = 0;
my $debug = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
# generate list of starting phase  settings
my @program = split(',',$file_contents[0]);
my @list_of_phases;
my @range= (0..4);
for my $a (@range) {
    for my $b (@range) {
	for my $c (@range) {
	    for my $d (@range) {
		for my $e (@range) {
		    my %seen = map {$_ => 1} ($a,$b,$c,$d,$e);
		    next unless scalar %seen == 5;
		    push @list_of_phases,[$a,$b,$c,$d,$e];
		}
	    }
	}
    }
}
my $ptr;
my $halt = 99;
my $max = {val=>0, phase => '' };
foreach my $phase(@list_of_phases) {
    my @inputs= (0);
    for my $register (0..4) {
    
	my $input = $inputs[-1];
	my $p = $phase->[$register];
	my ( $out_state, $out_val) = run_vm(\@program, [$p,$input]);
	say "$register ", join(',',@$out_val) if $debug;
	push @inputs, $out_val->[-1];
    }
    if ($inputs[-1] > $max->{val}) {
	$max->{val} = $inputs[-1];
	$max->{phase}  =join ('', @$phase);
    }
#    say "Phase: ",join ('', @$phase), " gives $inputs[-1]";
}
ok( $max->{val} == 116680 );
say "Part 1: $max->{val}";
### Subs

sub run_vm {
    my ( $state, $in_val ) = @_;

    #    my @state = @{$program};
    my @input = @{$in_val};
    my $ptr   = 0;
    my $out_val;
    while ( $state->[$ptr] != $halt ) {
        my ( $op, $a1, $a2, $a3 ) =
          @$state[ $ptr, $ptr + 1, $ptr + 2, $ptr + 3 ];
#        say join( ' ', $ptr, $op, $a1, $a2, $a3 ) if $debug;
        my $mask;
        if ( length $op > 2 )
        {    # assume values in this position are either 2 digits or more

            my @instr = split( //, $op );
            my @tail;
            for ( 1, 2 ) {
                unshift @tail, pop @instr;
            }
            $op = join( '', @tail ) + 0;
            while ( scalar @instr < 3 ) {
                unshift @instr, 0;
            }
            $mask = [ reverse @instr ];
        }
        else {
            $mask = [ 0, 0, 0 ];
        }
        my %ops = (
            1 => sub { $state->[ $_[2] ] = $_[0] + $_[1]; $ptr += 4 },
            2 => sub { $state->[ $_[2] ] = $_[0] * $_[1]; $ptr += 4 },
            4 => sub { push @{$out_val}, $_[0]; $ptr += 2 },
            5 => sub {
                if ( $_[0] != 0 ) { $ptr = $_[1]; }
                else              { $ptr += 3; }
            },
            6 => sub {
                if ( $_[0] == 0 ) { $ptr = $_[1]; }
                else              { $ptr += 3; }
            },
            7 => sub {
                if   ( $_[0] < $_[1] ) { $state->[ $_[2] ] = 1; }
                else                   { $state->[ $_[2] ] = 0; }
                $ptr += 4;
            },
            8 => sub {
                if ( $_[0] == $_[1] ) {
                    $state->[ $_[2] ] = 1;
                }
                else {
                    $state->[ $_[2] ] = 0;
                }
                $ptr += 4;
            },

        );

        if ( $op == 3 ) {
            $state->[$a1] = shift @$in_val;
            $ptr += 2;
        }
        else {
            $a1 = $mask->[0] ? $a1 : $state->[$a1];
            $a2 = $mask->[1] ? $a2 : $state->[$a2];
            $ops{$op}->( $a1, $a2, $a3 );
        }
    }
    return ( $state, $out_val );

}
sub dump_state {    # shows a pretty-printed grid of the current state
    my @show = split( ',', $_[0] );
    print '   ';
    for my $i ( 0 .. 9 ) { printf( "___%d ", $i ) }
    print "\n";
    my $full_rows = int( scalar @show / 10 );

    my $r;
    for $r ( 0 .. $full_rows - 1 ) {
        printf "%2d|", $r;
        for my $c ( 0 .. 9 ) {
            my $el = shift @show;
            printf "%4d ", $el;

        }
        print "\n";
    }
    printf "%2d|", $full_rows;
    while (@show) {
        my $el = shift @show;
        printf "%4d ", $el;
    }
    print "\n";

}


