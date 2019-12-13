#! /usr/bin/env perl
# Advent of Code 2019 Day 13 - Care Package - complete solution
# Problem link: http://adventofcode.com/2019/day/13
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d13
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
my $pos = [ 0, 0 ];

my $program = [ split( /,/, $file_contents[0] ) ];
my $res = run_vm(
    {
        state     => [@$program],
        positions => $pos,
        input_ary => []
    }
);
my $Map;
my $block_count = 0;
my @output      = @{ $res->{output_ary} };

while (@output) {
    my $col  = shift @output;
    my $row  = shift @output;
    my $tile = shift @output;
    $block_count++ if $tile == 2;
}
is( $block_count,372 ,"part 1");
say "Part 1: ",$block_count;
my %blocks = ( 0 => ' ', 1 => '#', 2 => '=', 3 => '_', 4 => 'o' );

$program->[0] = 2;

# initial state
my $score = 0;
$res = run_vm(
    {
        state     => [@$program],
        positions => [ 0, 0 ],
        input_ary => [0]
    }
);

my $row_count = 0;
my @ball_pos  = ();
my $paddle_col;
my $joystick = 0;
while ( @{ $res->{output_ary} } ) {
    my $col  = shift @{ $res->{output_ary} };
    my $row  = shift @{ $res->{output_ary} };
    my $tile = shift @{ $res->{output_ary} };
    $Map->[$row]->[$col] = $tile;
    if ( $tile == 4 ) {
        @ball_pos = ( $row, $col );
    }
    if ( $tile == 3 ) {
        $paddle_col = $col;
    }
}
my $count = 1;

while ( $count < 150000 ) {
    say "Count: $count Score: $score" if $count % 1000 == 0;
    $res = run_vm(
        {
            state     => $res->{state},
            positions => $res->{positions},
            input_ary => [$joystick]
        }
    );
    last if scalar @{ $res->{output_ary} } == 0;
    while ( @{ $res->{output_ary} } ) {
        my $col  = shift @{ $res->{output_ary} };
        my $row  = shift @{ $res->{output_ary} };
        my $tile = shift @{ $res->{output_ary} };
        if ( $row == 0 and $col == -1 ) {
            $score = $tile;
        }
        else {
            if ( $tile == 4 ) {
                @ball_pos = ( $row, $col );
            }
            if ( $tile == 3 ) {
                $paddle_col = $col;
            }
            $Map->[$row]->[$col] = $tile;
        }

    }

    # move paddle

    if ( $ball_pos[1] < $paddle_col ) {
        $joystick = -1;
    }
    elsif ( $ball_pos[1] > $paddle_col ) {
        $joystick = 1;
    }
    else {
        $joystick = 0;
    }

    $count++;
}
is( $score,19297,"part 2");
say "Count: $count";
say "Part 2: ", $score;

    done_testing;
sub dump_output {
    my ($data) = @_;
    while (@$data) {
        my $col  = shift @$data;
        my $row  = shift @$data;
        my $tile = shift @$data;
        say "R: $row C: $col T: $tile";
    }

}

sub paint_screen {
    my $row_count = 0;
    my $width     = 36;
    print ' ';
    for ( 0 .. $width ) {
        print $_% 10;
    }

    print "\n";

    for my $r (@$Map) {
        print $row_count% 10;
        for my $c ( @{$r} ) {
            print $blocks{$c};
        }
        print "\n";
        $row_count++;
    }
    print ' ';
    for ( 0 .. $width ) {
        print $_% 10;
    }

    print "\n";
    say "Score: $score";

}

__END__
