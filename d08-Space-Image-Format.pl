#! /usr/bin/env perl
# Advent of Code 2019 Day 8 - Space Image Format - complete solution
# Problem link: http://adventofcode.com/2019/day/8
#   Discussion: http://gerikson.com/blog/comp/Advent-of-Code-2019.html#d08
#      License: http://gerikson.com/files/AoC2019/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;
use Data::Dumper;
use Test::Simple tests => 2;
#### INIT - load input data from file into array
my $testing = 0;
my $debug   = 0;
my @file_contents;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @file_contents, $_; }

### CODE

my @input        = split( //, $file_contents[0] );
my $height       = 6;
my $width        = 25;
my $size         = scalar @input;
my $chunks       = $size / $width;
my $no_of_layers = $chunks / $height;
#say "size: $size chunks: $chunks layers: $no_of_layers";

my $layers;

while (@input) {
    my $count = 0;
    my $layer;

    while ( $count < $height * $width ) {
        push @$layer, shift @input;
        $count++;
    }
    push @$layers, $layer;
}

my ( $product, $min ) = ( undef, 10_000 );

foreach my $layer (@$layers) {
    my $count;
    foreach my $d (@$layer) {
        $count->{$d}++;
    }
    if ( $count->{0} < $min ) {
        $min     = $count->{0};
        $product = $count->{1} * $count->{2};
    }
}
say "Part 1: ",$product;
say "Part 2:";
my $image;
foreach my $row ( 0 .. $height - 1 ) {
    foreach my $col ( 0 .. $width - 1 ) {
        my $current_idx = $row * $width + $col;
        foreach my $layer (@$layers) {
            my $char = $layer->[$current_idx];
            if ( $char != 2 ) {
                print $char == 0 ? ' ' : '█';
                $image .= $char;
                last;
            }
        }
    }
    print "\n";
}
ok ( $product == 1950 );
ok ( $image eq '111101001001100100101000010000101001001010010100001110011000100101111010000100001010011110100101000010000101001001010010100001000010010100101001011110');
