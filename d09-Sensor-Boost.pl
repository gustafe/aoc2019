#! /usr/bin/env perl
# Advent of Code 2019 Day 9 - Sensor Boost - complete solution
# Problem link: http://adventofcode.com/2019/day/9
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d09
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;
use Data::Dumper;
use Test::More tests => 2;

#### INIT - load input data from file into array

my $debug = 0;
my @file_contents;

my $file = 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE

my $program = [ split( /,/, $file_contents[0] ) ];
my @ans = ( 3512778005, 35920 );
for my $part ( 1, 2 ) {

    my $initial = [$part];
    my $res     = run_vm(
        { state => [@$program], positions => [ 0, 0 ], input_ary => $initial }
    );
    say "Part $part: ", $res->{output_ary}->[0];
    is( $res->{output_ary}->[0], $ans[ $part - 1 ] );

}
### SUBS

sub run_vm {
    my ($params) = @_;

    my $input_ary = $params->{input_ary};
    my ( $ptr, $offset ) = @{ $params->{positions} };
    my $state      = $params->{state};
    my $output_ary = [];

    ### keep our opcodes here, called later from a dispatch table;
    my $add = sub {
        say "1 [add] => add $_[0] to $_[1], store in position $_[2]" if $debug;
        $state->[ $_[2] ] = $_[0] + $_[1];
        $ptr += 4;
    };
    my $multiply = sub {
        say "2 [multiply] => multiply $_[0] with $_[1], store in position $_[2]"
          if $debug;
        $state->[ $_[2] ] = $_[0] * $_[1];
        $ptr += 4;
    };
    my $write = sub {
        say "4 [write] => push $_[0] to output array" if $debug;
        push @{$output_ary}, $_[0];
        $ptr += 2;
    };
    my $jump_if_true = sub {
        say "5 [jump-if-true] => checking $_[0] for truth: ",
          $_[0] != 0
          ? " it is true, set pointer to $_[1]"
          : " it is false, skip instruction"
          if $debug;
        if ( $_[0] != 0 ) { $ptr = $_[1]; }
        else              { $ptr += 3; }
    };
    my $jump_if_false = sub {
        say "6 [jump-if-false] => compare $_[0] to 0: ",
          $_[0] == 0
          ? " it is 0, set pointer to $_[1] "
          : " skip to next instruction"
          if $debug;
        if ( $_[0] == 0 ) { $ptr = $_[1]; }
        else              { $ptr += 3; }
    };
    my $less_than = sub {
        say "7 [less-than] => compare $_[0] to $_[1]: ",
          $_[0] < $_[1]
          ? " it is less, set position $_[2] to 1 "
          : " it is not less, set position $_[2] to 0"
          if $debug;
        if   ( $_[0] < $_[1] ) { $state->[ $_[2] ] = 1; }
        else                   { $state->[ $_[2] ] = 0; }
        $ptr += 4;
    };
    my $equals = sub {
        say "8 [equals] => compare $_[0] to $_[1]: ",
          $_[0] == $_[1]
          ? " they are equal, set position $_[2] to 1 "
          : " they differ, set position $_[2] to 0"
          if $debug;
        if ( $_[0] == $_[1] ) {
            $state->[ $_[2] ] = 1;
        }
        else {
            $state->[ $_[2] ] = 0;
        }
        $ptr += 4;
    };
    my $adjust_offset = sub {
        say "9 [adjust-offset] => modify offset by $_[0]" if $debug;
        $offset = $offset + $_[0];
        $ptr += 2;
    };

    my $loop_counter = 0;
  LOOP: while ( $state->[$ptr] != 99 ) {
        my ( $op, $a1, $a2, $a3 ) =
          @$state[ $ptr, $ptr + 1, $ptr + 2, $ptr + 3 ];
        my $raw = [ $op, $a1, $a2, $a3 ];
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
            1 => $add,
            2 => $multiply,
            4 => $write,
            9 => $adjust_offset,
            5 => $jump_if_true,
            6 => $jump_if_false,
            7 => $less_than,
            8 => $equals,

        );
        if ($debug) {
            my $addr = 1024;

            #	    dump_state($state);
            print "--------------------------------------------------\n";
            say "Value at $addr: ", $state->[$addr] ? $state->[$addr] : 0;
            say "Pass $loop_counter Position [$ptr, $offset] IN ["
              . join( ',', @$input_ary )
              . "] OUT ["
              . join( ',', @$output_ary ) . ']';
            print '['
              . join( ',', @$raw ) . '] => '
              . join( ' ', ( $op, $a1, $a2, $a3 ) );
            print ' [' . join( ',', @$mask ) . "]\n";

        }
	# we keep this operand outside the dispatch table because it
	# has control flow - if no input is received, it will pause
	# the VM
        if ( $op == 3 ) {
            my $in = shift @$input_ary;
            if ( !defined $in ) {
                last LOOP;
            }
            if ( $mask->[0] == 2 ) {
                $state->[ $a1 + $offset ] = $in;
            }
            else {
                $state->[$a1] = $in;
            }

            $ptr += 2;
        }
        else {

            # first operand handled by $mask->[0]
            if ( $mask->[0] == 0 ) {    # position mode
                $a1 = $state->[$a1] ? $state->[$a1] : 0;
            }
            elsif ( $mask->[0] == 1 ) {    # immediate mode
                $a1 = $a1;
            }
            elsif ( $mask->[0] == 2 ) {    # relative mode
                $a1 = $state->[ $offset + $a1 ] ? $state->[ $offset + $a1 ] : 0;
            }
            else {
                die "unknown mode: ", $mask->[0];
            }

            # second operand handled by $mask->[1]
            if ( $mask->[1] == 0 ) {       # position mode
                $a2 = $state->[$a2] ? $state->[$a2] : 0;
            }
            elsif ( $mask->[1] == 1 ) {    # immediate mode
                $a2 = $a2;
            }
            elsif ( $mask->[1] == 2 ) {    # relative mode
                $a2 = $state->[ $offset + $a2 ] ? $state->[ $offset + $a2 ] : 0;
            }
            else {
                die "unknown mode: ", $mask->[1];
            }

            # third operand
            if ( $mask->[2] == 2 ) {       #relative mode
                $a3 = $offset + $a3;
            }

            $ops{$op}->( $a1, $a2, $a3 );
        }
        $loop_counter++;
    }

    return { output_ary => $output_ary, positions => [$ptr], state => $state };

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
            printf "%4d ", $el ? $el : 0;

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
