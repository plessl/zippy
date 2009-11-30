#!/usr/bin/env perl

use Data::Dumper;
use strict;

use Tools::Util;

sub foo {
    my $ar = shift;
    $ar->[0] = 5;
    return;
}

sub bar {
    my $ar = shift;
    my @b = (7,8,9);
    
}


my @a = \( 1, 2, 3);

print "(" . join(",",@a) . ")\n";
foo(\@a);
print "(" . join(",",@a) . ")\n";
