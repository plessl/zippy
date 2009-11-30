#!/usr/bin/env perl

use Data::Dumper;
use strict;

use Storable;

my $hr = retrieve('rg.bin');
print Dumper($hr);
