#!/bin/env perl

my $filename = "input.h";
my $line;

open(IN,$filename) || die;

my @lines = <IN>;
foreach my $l (@lines) {
  chomp ($l);
  $line .= $l;
}

$line =~ s/\s//g;
$line =~ m/(.*)\{(.*)\}(.*)/;
my $match = $2;
my @in = split (/,/,$match);

print "in = [ " . join(" ",@in) . "];\n";
