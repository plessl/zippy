package Zippy::Netlist::ZippyConfiguration;

$VERSION = 0.01;
use strict;
use warnings;
use Carp;
use Data::Dumper;

use Zippy::Architecture::RoutingGraph;
#use Tools::Attributable;

sub new {
	my $proto = shift;
    my $class = ref($proto) || $proto;
	my $name = shift;
	
	my $self = {};
	bless $self, $class;
    
	$self->name($name);
	
	my %attr = @_;
	foreach my $key (keys %attr){
		$self->set_attribute($key,$attr{$key});
	}
	
	$self->{'nets'} = ();
	return $self;
}

sub name {
	my $self = shift;
	if (@_) {
		$self->{'name'} = shift;
	}
	return $self->{'name'};
}

sub abstractConfiguration {
    my $self = shift;
    if (@_) {
        $self->{'abstractConfiguration'} = shift;
    }
    return $self->{'abstractConfiguration'};
}

## not implemented yet, use Data::Dumper output instead
sub pp {
	my $self = shift;
    return Dumper($self->abstractConfiguration);
}

sub ZippyVHDLConfiguration {
    my $self = shift;
    my $res;
    my %cfg = %{$self->abstractConfiguration};

    my $tmp;

    ################################################################
    # generate cell configuration
    ################################################################
    foreach my $cellName (sort keys %{$cfg{'cell'}}){
        $cellName =~ m/c_(\d+)_(\d+)/;
        my ($r,$c) = ($1,$2);
        
        $res .= sprintf("-- c_%d_%d %s\n", $r,$c,$cfg{'cell'}{$cellName}{'nlname'});
        $res .= sprintf("cfg.gridConf(%d)(%d).procConf.AluOpxS := %s;\n",
                        $r,$c,$cfg{'cell'}{$cellName}{'alu_func'});

        INP: foreach my $input (sort keys %{$cfg{'cell'}{$cellName}{'inputs'}}) {
            my $useReg = $cfg{'cell'}{$cellName}{'inputs'}{$input}{'reg'};
            #print "useReg for input $input of $cellName is $useReg\n";
			next INP if ($useReg eq 'unused');
            
            ### input operand register/constant multiplexer #### 
            if ($useReg eq 'reg_ctxthis') {
                $tmp = 'I_REG_CTX_THIS';
            } elsif ($useReg eq 'reg_ctxother') { 
                $tmp = 'I_REG_CTX_OTHER';
            } elsif ($useReg eq 'noreg') {
                $tmp = 'I_NOREG';
            } elsif ($useReg eq 'const') {
                $tmp = 'I_CONST';
            } elsif ($useReg eq 'unused') {
				# do nothing for the moment
			}
			else {
                die "$useReg is an invalid specification of the input source multiplexer!";
            }
            
            $input  =~ m/^i\.(\d+)/;
            my $inputNo = $1;
            $res .= sprintf("-- %s\n",$input);
            $res .= sprintf("cfg.gridConf(%d)(%d).procConf.OpMuxS(%d) := %s;\n",
                            $r,$c,$inputNo,$tmp);
            
            if ($tmp eq 'I_REG_CTX_OTHER'){
                my $ctxNumber =  $cfg{'cell'}{$cellName}{'inputs'}{$input}{'regctx'};
                $res .= sprintf("cfg.gridConf(%d)(%d).procConf.OpCtxRegSelxS(%d) := i2ctx(%d);\n",
                                $r,$c,$inputNo,$ctxNumber);
            }
            
            ### input operand source driver ###
            my $inputSourceType = $cfg{'cell'}{$cellName}{'inputs'}{$input}{'srctype'} || '';
            my $inputSource = $cfg{'cell'}{$cellName}{'inputs'}{$input}{'src'} || '';
            if ($inputSourceType eq 'local'){
                $tmp = sprintf("LOCAL_%s",$inputSource);
                $res .= sprintf("cfg.gridConf(%d)(%d).routConf.i(%d).LocalxE(%s) := '1';\n",
                                $r,$c,$inputNo,$tmp);
            } elsif ($inputSourceType eq 'bus') {
                $inputSource =~ m/(.*)\.(\d+)\.(\d+)/;
                my ($bus,$ind,$sub) = ($1,$2,$3);
                my $busfmt;
                if ($bus eq "hbus_n") {
                    $busfmt = "HBusNxE(%d)";
                } elsif ($bus eq "hbus_s") {
                    $busfmt = "HBusSxE(%d)";
                } elsif ($bus eq "vbus_e") {
                    $busfmt = "VBusExE(%d)";
                } else {
                    die "bus type $bus is not supported!";
                }
                $tmp = sprintf($busfmt,$sub);
                $res .= sprintf("cfg.gridConf(%d)(%d).routConf.i(%d).%s := '1';\n",
                                $r,$c,$inputNo,$tmp);
            } elsif ($inputSourceType eq 'const') {
                $res .= sprintf("cfg.gridConf(%d)(%d).procConf.ConstOpxD := i2cfgconst(%d);\n",
                                $r,$c,$cfg{'cell'}{$cellName}{'const'});
            } else {
                die sprintf("input source type \'$inputSourceType\' not supported, " .
                            "cellName=%s input=%s abstract_config=%s",
                            $cellName,$input,Dumper(\%cfg));
            }
    
        } # for each input INP

        OUTP: foreach my $output (sort keys %{$cfg{'cell'}{$cellName}{'outputs'}}) {
            my $useReg = $cfg{'cell'}{$cellName}{'outputs'}{$output}{'reg'};
            next OUTP if ($useReg eq 'unused');
    
            ### output register/constant multiplexer #### 
            if ($useReg eq 'reg_ctxthis') {
                $tmp = 'O_REG_CTX_THIS';
            } elsif ($useReg eq 'reg_ctxother') {
                $tmp = 'O_REG_CTX_OTHER';
            } elsif ($useReg eq 'noreg') {
                $tmp = 'O_NOREG';
            } else {
                die "$useReg is an invalid specification of the output register multiplexer!";
            }
            $output  =~ m/^i\.(\d+)/;
            my $outputNo = $1;
            $res .= sprintf("-- %s\n",$output);
            $res .= sprintf("cfg.gridConf(%d)(%d).procConf.OutMuxS := %s;\n",
                            $r,$c,$tmp);
            
            if ($tmp eq 'O_REG_CTX_OTHER'){
                my $ctxNumber =  $cfg{'cell'}{$cellName}{'outputs'}{$output}{'regctx'};
                $res .= sprintf("cfg.gridConf(%d)(%d).procConf.OutCtxRegSelxS := i2ctx(%d);\n",
                                $r,$c,$ctxNumber);
            }                        
            
            DRV: foreach my $outputDriver (sort keys %{$cfg{'cell'}{$cellName}{'outputs'}{$output}{'drv'}}){
                next DRV if ($outputDriver eq 'local');

                $outputDriver =~ m/(.*)\.(\d+)\.(\d+)/;
                my ($bus,$ind,$sub) = ($1,$2,$3);
                my $busfmt;
                if ($bus eq "hbus_n") {
                    $busfmt = "HBusNxE(%d)";
                } elsif ($bus eq "hbus_s") {
                    $busfmt = "HBusSxE(%d)";
                } elsif ($bus eq "vbus_e") {
                    $busfmt = "VBusExE(%d)";
                } else {
                    die "bus type $bus is not supported!";
                }
                $tmp = sprintf($busfmt,$sub);
                $res .= sprintf("cfg.gridConf(%d)(%d).routConf.o.%s := '1';\n",
                                $r,$c,$tmp);
            }
        } # foreach output OUTP     
        $res .="\n\n";
        
    } # foreach cell

    ################################################################
    # generate input/output driver configuration
    ################################################################
    $res .="-- input drivers\n";
    foreach my $inputPortName (sort keys %{$cfg{'input'}}){
        $inputPortName =~ m/p_i\.(\d+)/;
        my $p = $1;

        DRV: foreach my $inputDriver (sort keys %{$cfg{'input'}{$inputPortName}}){
            $inputDriver =~ m/b_hn\.(\d+)\.(\d+)/;
            my ($hbusnInd,$hbusnSub) = ($1,$2);
            $res .= sprintf("cfg.inputDriverConf(%d)(%d)(%d) := '1';\n",
                            $p,$hbusnInd,$hbusnSub);
        }
    }

    $res .="\n-- output drivers\n";
    foreach my $outputPortName (sort keys %{$cfg{'output'}}){
        $outputPortName =~ m/p_o\.(\d+)/;
        my $p = $1;
        
        DRV: foreach my $outputDriver (sort keys %{$cfg{'output'}{$outputPortName}}){
            $outputDriver =~ m/b_hn\.(\d+)\.(\d+)/;
            my ($hbusnInd,$hbusnSub) = ($1,$2);
            $res .= sprintf("cfg.outputDriverConf(%d)(%d)(%d) := '1';\n",
                    $p,$hbusnInd,$hbusnSub);
        }
    }

    return $res;
}

sub getLocalSourceNameByWire {
    my $self = shift;
    my $wireName = shift;
    my $res;
    
    my $ROWS = $Zippy::Architecture::RoutingGraph::ROWS;
    my $COLS = $Zippy::Architecture::RoutingGraph::COLS;
    
    # input local:             w_c_o_1_1-c_i_2_1
    $wireName =~ m/^w_c_o_(\d+)_(\d+)-c_i_(\d+)_(\d+)$/;
    my ($neighRow,$neighCol,$thisRow,$thisCol) = ($1,$2,$3,$4);
    
    #print "thisRow=$thisRow thisCol=$thisCol  neighRow=$neighRow neighCol=$neighCol\n";
    
    if (      (($thisRow-1) % $ROWS == $neighRow) and (($thisCol-1) % $COLS == $neighCol)) {
        $res = "NW";
    } elsif ( (($thisRow+0) % $ROWS == $neighRow) and (($thisCol-1) % $COLS == $neighCol)) {
        $res = "W";
    } elsif ( (($thisRow+1) % $ROWS == $neighRow) and (($thisCol-1) % $COLS == $neighCol)) {
        $res = "SW";
    } elsif ( (($thisRow-1) % $ROWS == $neighRow) and (($thisCol+0) % $COLS == $neighCol)) {
        $res = "N";
    } elsif ( (($thisRow+0) % $ROWS == $neighRow) and (($thisCol+0) % $COLS == $neighCol)) {
        $res = "SELF";
    } elsif ( (($thisRow+1) % $ROWS == $neighRow) and (($thisCol+0) % $COLS == $neighCol)) {
        $res = "S";
    } elsif ( (($thisRow-1) % $ROWS == $neighRow) and (($thisCol+1) % $COLS == $neighCol)) {
        $res = "NE"
    } elsif ( (($thisRow+0) % $ROWS == $neighRow) and (($thisCol+1) % $COLS == $neighCol)) {
        $res = "E";
    } elsif ( (($thisRow+1) % $ROWS == $neighRow) and (($thisCol+1) % $COLS == $neighCol)) {
        $res = "SE";
    } else {
        die "problem, cannot determine which local interconnect was used for wire: $wireName";
    }
    return $res;
}

1;

__END__

# class documentation template, see Damian Conways Book, p97

=pod

=head1 NAME

Zippy::Netlist::ZippyConfiguration - Convert routed netlists to a configuration
 format suitable for the Zippy simulator. 

=head1 VERSION

This document refers to version N.NN of Zippy::Netlist::ZippyConfiguration, released 
March, 24, 2004

=head1 SYNOPSIS

# some short examples how to use the class

=head1 DESCRIPTION

=head2 Overview

=head2 Constructor and initialization

=head2 Class and object methods

=head2 Methods

=head2 Instance variables

=head1 BUGS

None, hopefully

=head1 TODOs



=head1 FILES

=head1 SEE ALSO

=head1 AUTHOR

Christian Plessl <plessl@tik.ee.ethz.ch>

=head1 COPYRIGHT

Copyright (c) 2004, Christian Plessl, Computer Engineering and Networks Lab
ETH Zurich, Switzerland.

All Rights Reserverd. This module is free software. It may be used, redistributed 
and/or modified under the same terms as Perl itself.

=cut
