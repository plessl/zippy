#!/usr/bin/env perl

use Data::Dumper;
use strict;

use Tools::Util;

my @a = ("a","b","c","d","e","f","g");

print "array test\n";
for (my $i=0;$i<5;$i++){
	my $s = Tools::Util::listChooseAny(\@a);
	print "selected $s\n";
}

print "list: (" . join(",",@a) .")\n";
print "removing 'c' from list\n";
@a = @{ Tools::Util::listRemoveElement("c",\@a) };
print "list: (" . join(",",@a) .")\n";


print "listRemoveAny test\n";
my ($s,$an);
for (my $i=0;$i<4;$i++){
	($s,$an) = Tools::Util::listRemoveAny(\@a);
	@a = @$an;
	print "removed $s\n";
	print "list: (" . join(",",@a) .")\n";
}