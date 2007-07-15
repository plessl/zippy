#!/usr/sepp/bin/perl

$debug = 1;

$file = $ARGV[0];
$outfile = $ARGV[1];

die "cannot open $file\n" unless -f $file;

open(INFILE,$file);

if (undef $ARGV[1]) {
  open (OUTFILE,STDOUT);
} else {
  open(OUTFILE,"> $outfile");
}


my $opcodes;
my $match = 0;

foreach $line (<INFILE>) {

  $match = 0;

  if ($line =~ /(\s+)(\S+)(\s+)(\S+)(.*)/) {
    ($instr,$args) = ($2,$4);
#    print "i: $instr args: $args\n" if $debug;

    if ($instr eq "zippy_get_reg") {
      $match = 1;
      #print "zippy_get_reg detected!!\n";
      #print "args = " . join("/",get_args($args)) ."\n";

      @theArgs = get_args($args);
      $opcodes = get_opcode_zippy_get_reg(@theArgs);

    } elsif ($instr eq "zippy_set_reg") {
      $match = 1;
      #print "zippy_set_reg detected!!\n";
      #print "args = " . join("/",get_args($args)) ."\n";
      @theArgs = get_args($args);
      $opcodes = get_opcode_zippy_set_reg(@theArgs);
    } elsif ($instr eq "zippy_stop_sim") {
      $match = 1;
      $opcodes = get_opcode_zippy_stop_sim();
    }
  }

  if ($match) {
    chomp($line);
    print OUTFILE "# $line      #### replaced by fix_instruction\n";
    print OUTFILE $opcodes;
  } else {
    print OUTFILE $line;
  }

}

close(INFILE);
close(OUTFILE);

#sub get_opcode_1op {
#  $an,$op,$ru,$rs,$rt,$rd =
#
#}




## zippy_get_reg %1,%2
##
## gets value of zipppy register (address in %2) and saves it to 
## register %1 of the CPU register file

sub get_opcode_zippy_get_reg {
  my $dest = shift (@_);
  my $zreg = shift (@_);

  #print "zippy_get_reg $dest,$zreg\n";
  #print "dest = $dest zreg = $zreg\n";
  $res  = "\t.word 0x";
  $res .= sprintf "%04x",0;             # annotation
  $res .= sprintf "%04x",hex("00b0");   # opcode
  $res .= "\n";                         #
  $res .= "\t.word 0x";                 #
  $res .= sprintf "%02x",$zreg;         # rs
  $res .= sprintf "%02x",0;             # rt
  $res .= sprintf "%02x",$dest;         # rd
  $res .= sprintf "%02x",0;             # shamt
  $res .=" \n";
  return $res;
}

## zippy_set_reg %0,%1,%2
##
## sets zippy register (address in %1) to value (value in %2). The
## result of this operation (if any) is returned in %1.
##

sub get_opcode_zippy_set_reg {
  my $dest = shift(@_);      # save result to this CPU register
  my $zreg = shift(@_);      # zippy register to which value is stored
  my $valuereg = shift(@_);  # register containing value to be stored in 
                             # zippy register zreg

  #print "zippy_set_reg $dest,$zreg,$valuereg\n";
  #print "dest = $dest zreg = $zreg valuereg=$valuereg\n";

  $res  = "\t.word 0x";
  $res .= sprintf "%04x",0;             # annotation
  $res .= sprintf "%04x",hex("00b1");   # opcode
  $res .= "\n";                         #
  $res .= "\t.word 0x";                 #
  $res .= sprintf "%02x",$zreg;         # rs
  $res .= sprintf "%02x",$valuereg;     # rt
  $res .= sprintf "%02x",$dest;         # rd
  $res .= sprintf "%02x",0;             # shamt
  $res .=" \n";
  return $res;

}

sub get_opcode_zippy_stop_sim {
  $res  = "\t.word 0x";
  $res .= sprintf "%04x",0;             # annotation
  $res .= sprintf "%04x",hex("00b3");   # opcode
  $res .= "\n";                         #
  $res .= "\t.word 0x00000000";         #
  $res .=" \n";
  return $res;
}


sub get_args {
  $parm = shift(@_);
  @args = split(/,/,$parm);

  for ($i=0;$i<=$#args;$i++) {
    $args[$i] =~ s/\$(\d{1,2}?)/$1/;
  }
  return @args;
}

#  if ($line =~ /^\s*zippy_get_reg\s*(\$\d{1,2}?)\,(\$\d{1,2}?)(.*)$/){
#    print "zippy_get_reg \$$1,\$$2\n";
#  }

#  print $line;



