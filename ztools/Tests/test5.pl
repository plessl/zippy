#!/usr/bin/env perl

use Data::Dumper;
use strict;

my @b = ( 1, 2, 3);

#### conventional
foreach (@b) {
    printme($_);
}

#### unconventional
map { printme($_) } @b;

sub printme {
    my $s = shift;
    print "$s\n";
}
