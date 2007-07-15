#!/bin/env perl

use Data::Dumper;

$header_file = "input.h";
$matlab_file = "filter_input.m";


open(HFILE,"> $header_file") || die "cannot open $header_file for writing";
open(MFILE,"> $matlab_file") || die "cannot open $matlab_file for writing";

if ($#ARGV != 0 ) {  # 1 argument
  &usage();
}

my $inlen = $ARGV[0];

my ($i,$r);

srand 1;  # initialize random generator

print HFILE "#define INLEN $inlen\n";
print HFILE "\n";
print HFILE "static const short in[INLEN] = {\n\t";

print MFILE "in = [";

for ($i=0;$i<$inlen;$i++) {
  $r = int (rand(5)) -2;
  print HFILE "$r";
  print HFILE "," unless ($i == $inlen-1);
  print HFILE "\n\t" if ($i % 20 == 0 && $i != 0);

  print MFILE "$r ";

}
print HFILE "\n};\n";

print MFILE "];\n";

close HFILE;
close MFILE;

sub usage {
  print "Usage: $0 [no. input samples]\n";
  exit;
}
