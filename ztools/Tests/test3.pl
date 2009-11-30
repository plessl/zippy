#!/usr/bin/env perl

use Data::Dumper;
use strict;

use Tools::Util;




my @b = ( 1, 2, 3);

my @a = (4,5,6);

print "(" . join(",",@a) . ")\n";
@a = @{\@b};
print "(" . join(",",@a) . ")\n";

