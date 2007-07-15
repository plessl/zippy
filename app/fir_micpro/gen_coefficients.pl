#!/bin/env perl

use Data::Dumper;

$coef_file = "coefficients.txt";
$header_file = "coefficients.h";
$matlab_file = "coefficients.m";

open(COEF,$coef_file) || die "cannot open $coef_file";
open(HFILE,"> $header_file") || die "cannot open $header_file for writing";
open(MFILE,">$matlab_file") || die "cannot open $matlab_file for writing";

my (@filter, @subfilter, @coefs);
my $coef_ind;
my $subf_ind = 0;

while (<COEF>) {
  next if $_ =~ m/^(\s*)#(.*)/;
  $line = strip_comment($_);
  print "line: $line\n";
  @coefs = split(/,/,$line);
  push @filter, [ @coefs[0..$#coefs] ];
#  print "     {" .join(',',@coefs[0..$#coefs]) ."}\n";
}

my $subf_no  = scalar $#filter + 1;
my $subf_len = $#{$filter[1]} + 1;

############################################################
# c header file generation
############################################################

print HFILE "static const subf_no = $subf_no;\n";
print HFILE "static const subf_len = $subf_len;\n";

print HFILE "static const short subf[$subf_no][$subf_len]= {\n";

for ($i=0;$i<$subf_no;$i++) {
  print HFILE "\t{" .join(',',@{$filter[$i]}) ."}";
  print HFILE "," unless ($i == $subf_no -1);
  print HFILE "\n";
}

print HFILE "};\n";

############################################################
# matlab file generation
############################################################

for ($i=0;$i<$subf_no;$i++) {
  print MFILE "sub_f$i = [" .join(' ',@{$filter[$i]}) ."];\n";
}

print MFILE "coeffs = " . conv_gen($subf_no-1) . ";\n";

sub conv_gen{
  my $num = shift;
  if ($num == 0) {
    return "sub_f$num";
  } else {
    return "conv(sub_f$num,".conv_gen($num-1) .")";
  }
}




#print STDOUT "#subfilters: $subf_no length: $subf_len\n";




sub strip_comment{
  my $line = shift;
  $line =~ s/^(.*)#(.*)/$1/;
  $line =~ s/\s\s/ /g;
  return $line;
}

close COEF;
close HFILE;
