#! /usr/bin/env perl
# Advent of Code 2019 Day 7 - Amplification Circuit - part 2 
# Problem link: http://adventofcode.com/2019/day/7
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d07
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;
use Data::Dumper;
use Test::Simple tests => 1;
#### INIT - load input data from file into array
my $testing = 0;
my $debug   = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE
# generate list of starting phase  settings
my @program = split( ',', $file_contents[0] );
my @list_of_phases;
my @range = ( 5 .. 9 );
for my $a (@range) {
    for my $b (@range) {
        for my $c (@range) {
            for my $d (@range) {
                for my $e (@range) {
                    my %seen = map { $_ => 1 } ( $a, $b, $c, $d, $e );
                    next unless scalar %seen == 5;
                    push @list_of_phases, [ $a, $b, $c, $d, $e ];
                }
            }
        }
    }
}

my $halt = 99;
my $max = { val => 0, phase => '' };

foreach my $phases (@list_of_phases) {

    my $amp_states;
    for ( 0 .. 4 ) { push @$amp_states, { state => \@program, ptr => 0 } }

    my $loop_cnt = 0;
    my $amp      = 0;
    my $prev     = [0];
    my $ptr;
    my $state;
    my @last_amp_res;
    do {

        for my $amp ( 0 .. 4 ) {
	    # only add the current phase in the very first pass
            my $in_val =
              $loop_cnt == 0 ? [ $phases->[$amp], $prev->[0] ] : [ $prev->[0] ];
            ( $prev, $ptr, $state ) = run_vm(
                $in_val,
                $amp_states->[$amp]->{ptr},
                $amp_states->[$amp]->{state}
            );
            $amp_states->[$amp]->{ptr}   = $ptr;
            $amp_states->[$amp]->{state} = $state;

            push @last_amp_res, $prev->[0] if $amp == 4 and defined $prev->[0];
        }
        $loop_cnt++;

    } while ( scalar @$prev > 0 );
    if ( $last_amp_res[-1] > $max->{val} ) {
        $max = {
            val   => $last_amp_res[-1],
            phase => join '',
            @$phases
        };
    }

}
ok( $max->{val} == 89603079 );
say "Part 2: ", $max->{val};

### Subs

sub run_vm {
    my ( $in_val, $start_ptr, $state ) = @_;

    my @input   = @{$in_val};
    my $ptr     = $start_ptr;
    my $out_val = [];
  LOOP: while ( $state->[$ptr] != $halt ) {
        my ( $op, $a1, $a2, $a3 ) =
          @$state[ $ptr, $ptr + 1, $ptr + 2, $ptr + 3 ];
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

        dump_state($state) if $debug;

        if ( $op == 3 ) {
            my $in = shift @$in_val;
            if ( !defined $in ) {
                last LOOP;
            }
            $state->[$a1] = $in;
            $ptr += 2;
        }
        else {
            $a1 = $mask->[0] ? $a1 : $state->[$a1];
            $a2 = $mask->[1] ? $a2 : $state->[$a2];
            $ops{$op}->( $a1, $a2, $a3 );
        }
    }

    return ( $out_val, $ptr, $state );

}

sub dump_state {    # shows a pretty-printed grid of the current state
    my ($in) = @_;

    my @show = @{$in};

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

