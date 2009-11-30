package Zippy::Netlist::Netlist;

$VERSION = 0.01;
use strict;
use warnings;
use Carp;
use Data::Dumper;

use Graph::Directed;
use Graph::BFS;
use Zippy::Architecture::RoutingGraph;
use Tools::Attributable;
use Tools::GraphTools;

use vars qw(@ISA);
@ISA = qw( Graph::Directed Tools::Attributable );

###################
#  Netlist class:
#
#  A netlist consists of nodes and nets
#    %nodes hash of nodes
#    %nets  hash of nets connecting the nodes
#
#  node:
#  A node resource of the routing graph, typically the nodes in a netlist are 
#  restricted to primary inputs, primary outputs and logic elements
#
#  net:
#  A net is a directed connection, that connects a single source with one or multiple sinks.
#
#    getNets   -> return all nets of a netlist
#    getNodes  -> return all nodes used in a netlist
#
#  Net:
#    getBranches -> return a list of branches for this net
#
#  Branch:
#    

## Netlist format
#
# A netlist is an object of Graph::Directed
# The netlist consists of nodes (representing cells) and 
# edges (representing connections)
#
# attributes:
#
# nodes:
#    - name: unique name of node
#    - placement: placement of the node, e.g. c_2_0
#
# edges:
#    - name: unique identifier
#    - net: name of the net (which can be a multiterminal net)
#
#    - path: list of all resources that are used by this net 
#      only used for route nets
#


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

################################################################################
# lookup a cell in the netlist by its name
#  method uses caching, to speedup subsequent lookups
################################################################################
sub getCellByName {
    my $self = shift;
    my $name = shift;

    if (not defined $self->{'cellByName'}){
        foreach my $c (@{$self->getNodesOfType('cell')}) {
            $self->{'cellByName'}->{$c->name}=$c;
        }
    }
    return $self->{'cellByName'}->{$name};
}

sub netsTotal {
    my $self = shift;
    return scalar ($self->get_nets);
}

sub netsUnrouted {
    my $self = shift;
    my $unrouted = 0;
    foreach my $net ($self->get_nets){
        my $rt = $net->get_attribute('rt');
        $unrouted++ if (not defined $rt);
    }
    return $unrouted;
}

##### TODO ######
# convert this to an iterator later on?! if the netlist is large returning 
# the _whole_ netlist could result in an excessive amount of data to be
# passed back and forth

### FIXME, make get_nets return an arrayref instead of the array itself
sub get_nets {
	my $self = shift;
	return @{$self->{'nets'}};
}

sub add_net {
	my $self = shift;
	my $net = shift;
	push @{$self->{'nets'}},$net;
    undef $self->{'cellByName'};
}

sub pp {
	my $self = shift;
	my $res;
	foreach my $net ($self->get_nets()) {
		$res .= $net->pp();
    }
	return $res;
}


sub resetRouting {
    my $self = shift;
    
    foreach my $net ($self->get_nets){
        $net->set_attribute('routingstatus',$Zippy::Architecture::Router::ROUTER_UNROUTED);
        $net->delete_attribute('rt');
    }
}

sub getNodesOfType {
	my $self = shift;
	my $type = shift;
    
	my @res;
    my %cells;
    
	foreach my $net ($self->get_nets){
		my $source = $net->source;
        my $sourceType = $source->get_attribute('type');
        
        if ((defined $sourceType)  and ($sourceType eq $type)){
            $cells{$source->name} = $source;
        }
        
        foreach my $sink ($net->get_sinks) {
            my $sinkType = $sink->get_attribute('type');
            if ((defined $sinkType) and ($sinkType eq $type)){
                $cells{$sink->name} = $sink;
            }                  
        }
    }
    @res = values(%cells);
    return \@res;
}


#open(NL,"> /tmp/nl.dot");
#print NL Tools::GraphTools::dumpGraphAsDot($G);
#close NL;
#dot -Tps /tmp/nl.dot> /tmp/nl.ps; ps2pdf /tmp/nl.ps /tmp/nl.pdf; open /tmp/nl.pdf

sub getGraph {
    my $self = shift;
    my $G = Graph->new;
    
    foreach my $net ($self->get_nets){
        foreach my $wire ($net->get_wires){
            $G->add_edge($wire->source->name,$wire->sink->name);
        }
    }
    return $G;
}

# cell operation
# constant operator
# foreach input
#    mux configuration    REG/NOREG
#    source configuration Local, Bus
# output
#    mux configuration    REG/NOREG
#    driver configuration Buses
#
# input and output bus drivers
#

### FIXME: To simplify the handling of routing only cells, implement a function 
###  that converts the netlist to an equivalent netlist, that explicitly uses
###  routing cells, split up these nets, and configure the cell with a alu_pass0
###  function.
###
### Or maybe even better, write an updated ZNF file with fixed placement that 
###  uses explicit routing cells

# cell with pass through routing looks like this:
#     w_c_i_6_5_c_o_6_5,


#sub convertFeedthroughRouthingToCells {
#    my $self = shift;
#}

sub createFeedthroughCell {
    my $self = shift;
    my $hrConfig = shift;
    my $cellName = shift;
    my $feedWire = shift;
    my $driveWire = shift;

    
    $hrConfig->{'cell'}{$cellName}{'nlname'} = "feedthrough_$cellName";
    $hrConfig->{'cell'}{$cellName}{'alu_func'} = 'alu_pass0';

    ##########################################################
    # routing cell input configuration
    ##########################################################
    # processing node inputs (input multiplexers)
    #  input local:             w_c_o_1_1-c_i_2_1
    #  input from hbus_n:       w_b_hn.1.0-c_i_1_3
    #  input from hbus_s:       w_b_hs.4.1-c_i_4_5
    #  input from vbus_e:       w_b_ve.5.0-c_i_4_6
    
    my ($srctype,$src);
    if ($feedWire =~ m/^w_b_hn\.(\d+)\.(\d+)(.*)/ ){
        $srctype = "bus";
        $src = sprintf("hbus_n.%d.%d",$1,$2);
    } elsif ($feedWire =~ m/^w_b_hs\.(\d+)\.(\d+)(.*)/ ){ 
        $srctype = "bus";
        $src = sprintf("hbus_s.%d.%d",$1,$2);                        
    } elsif ($feedWire =~ m/^w_b_ve\.(\d+)\.(\d+)(.*)/ ){ 
        $srctype = "bus";
        $src = sprintf("vbus_e.%d.%d",$1,$2);
    } else {
        $srctype = "local";
        $src = $self->getLocalSourceNameByWire($feedWire);
    }

    $hrConfig->{'cell'}{$cellName}{'inputs'}{'i.0'}{'reg'} = 'noreg';
    $hrConfig->{'cell'}{$cellName}{'inputs'}{'i.0'}{'srctype'}=$srctype;
    $hrConfig->{'cell'}{$cellName}{'inputs'}{'i.0'}{'src'}=$src;
    
    ##########################################################
    # routing cell input configuration
    ##########################################################
    # processing node outputs (driver to buses)
    #  output to hbus_s  s_w_c_o_4_3-c_i_5_3-b_hs.4.1, 
    #  output to hbus_n  s_w_c_o_2_0-c_i_3_0-b_hn.3.0
    #  output to vbus_e  s_w_c_o_6_5-c_i_6_6-b_ve.5.0

    my $drv;
    if ($driveWire =~ m/^(.*)-b_hs\.(\d+)\.(\d+)/ ){
        $drv = sprintf("hbus_s.%d.%d",$2,$3);
    } elsif ($driveWire =~ m/^(.*)-b_hn\.(\d+)\.(\d+)/ ){
        $drv = sprintf("hbus_n.%d.%d",$2,$3);
    } elsif ($driveWire =~ m/^(.*)-b_ve\.(\d+)\.(\d+)/ ){
        $drv = sprintf("vbus_e.%d.%d",$2,$3);
    } elsif ($driveWire =~m/c_i_(\d+)_(\d+)/ ) {
        $drv = "local";  # drive local output
    } else {
        croak "unknown driveWire type, dirveWire=" . $driveWire;
    }
    
    $hrConfig->{'cell'}{$cellName}{'outputs'}{'o.0'}{'drv'}{$drv}=1;
    $hrConfig->{'cell'}{$cellName}{'outputs'}{'o.0'}{'reg'} = 'noreg';
}



sub getAbstractConfiguration {
    
    ## check netlist for routing cells and issues a warning that manual intervention
    ## is required, until a netlist normalizer has been implemented.
    
    my $self = shift;
    my %config;
    
    foreach my $net ($self->get_nets){
        foreach my $wire ($net->get_wires){
            foreach my $node ($wire->source, $wire->sink){
                my $cellName = $node->get_attribute('placement');
                
                ## process (normal) array cell
                if ( $cellName =~ m/c_(.*)/ ){
                    
                    # cell operation
                    $config{'cell'}{$cellName}{'nlname'} = $node->name;
                    $config{'cell'}{$cellName}{'alu_func'} = $node->get_attribute('f');
                    
                    # input selection
                    for my $inp ('i.0','i.1','i.2'){
                        my $reg = $node->get_attribute($inp); 
                        $config{'cell'}{$cellName}{'inputs'}{$inp}{'reg'} = $reg;
                        
                        if ($reg =~ m/reg\[(.*)\]/){
                            my $ctxNumber = $1;
                            $config{'cell'}{$cellName}{'inputs'}{$inp}{'reg'} = 'reg_ctxother';
                            $config{'cell'}{$cellName}{'inputs'}{$inp}{'regctx'} = $ctxNumber;
                        } elsif ($reg eq 'reg') {
                            $config{'cell'}{$cellName}{'inputs'}{$inp}{'reg'} = 'reg_ctxthis';                        
                        }
                        
                        if ($reg eq 'const'){
                            $config{'cell'}{$cellName}{'inputs'}{$inp}{'srctype'} = 'const';
                        }
						if ($reg eq 'unused'){
                            $config{'cell'}{$cellName}{'inputs'}{$inp}{'srctype'} = 'unused';							
						}
                    }
                    if (defined $node->get_attribute('const')){
                        $config{'cell'}{$cellName}{'const'} = $node->get_attribute('const');
                    }

                    # output selection
                    $config{'cell'}{$cellName}{'outputs'}{'o.0'}{'reg'} = $node->get_attribute('o.0');
                    my $reg = $node->get_attribute('o.0');
                    if ($reg =~ m/reg\[(.*)\]/){
                        my $ctxNumber = $1;
                        $config{'cell'}{$cellName}{'outputs'}{'o.0'}{'reg'} = 'reg_ctxother';
                        $config{'cell'}{$cellName}{'outputs'}{'o.0'}{'regctx'} = $ctxNumber;
                    } elsif ($reg eq 'reg') {
                        $config{'cell'}{$cellName}{'inputs'}{'o.0'}{'reg'} = 'reg_ctxthis';                        
                    }
                    
                    my @path = @{$wire->get_attribute('path')};

                    if ($node == $wire->source){
                        #processing node outputs (driver to buses)
                        # output to hbus_s  s_w_c_o_4_3-c_i_5_3-b_hs.4.1, 
                        # output to hbus_n  s_w_c_o_2_0-c_i_3_0-b_hn.3.0
                        # output to vbus_e  s_w_c_o_6_5-c_i_6_6-b_ve.5.0
                        my $drv;
                        if ($path[2] =~ m/^(.*)-b_hs\.(\d+)\.(\d+)/ ){
                            $drv = sprintf("hbus_s.%d.%d",$2,$3);
                        } elsif ($path[2] =~ m/^(.*)-b_hn\.(\d+)\.(\d+)/ ){
                            $drv = sprintf("hbus_n.%d.%d",$2,$3);
                        } elsif ($path[2] =~ m/^(.*)-b_ve\.(\d+)\.(\d+)/ ){
                            $drv = sprintf("vbus_e.%d.%d",$2,$3);
                        } elsif ($path[2] =~m/c_i_(\d+)_(\d+)/ ) {
                            $drv = "local";  # drive local output
                        } else {
                            croak "unknown source type, path[2]=" . $path[2];
                        }
                        my $port = $wire->get_attribute("sourcePort");
                        $port =~s/^(.*)\.(.*\..*)/$2/;
                        $config{'cell'}{$cellName}{'outputs'}{$port}{'drv'}{$drv}=1;
                        
                    } elsif ($node = $wire->sink) {
                        #processing node inputs (input multiplexers)
                        # input local:             w_c_o_1_1-c_i_2_1
                        # input from hbus_n:       w_b_hn.1.0-c_i_1_3
                        # input from hbus_s:       w_b_hs.4.1-c_i_4_5
                        # input from vbus_e:       w_b_ve.5.0-c_i_4_6
                            
                        my ($srctype,$src);
                        if ($path[-2] =~ m/^w_b_hn\.(\d+)\.(\d+)(.*)/ ){
                            $srctype = "bus";
                            $src = sprintf("hbus_n.%d.%d",$1,$2);
                        } elsif ($path[-2] =~ m/^w_b_hs\.(\d+)\.(\d+)(.*)/ ){ 
                            $srctype = "bus";
                            $src = sprintf("hbus_s.%d.%d",$1,$2);                        
                        } elsif ($path[-2] =~ m/^w_b_ve\.(\d+)\.(\d+)(.*)/ ){ 
                            $srctype = "bus";
                            $src = sprintf("vbus_e.%d.%d",$1,$2);
                        } else {
                            $srctype = "local";
                            $src = $self->getLocalSourceNameByWire($path[-2]);
                        }
                        my $port = $wire->get_attribute("sinkPort");
                        $port =~s/^(.*)\.(.*\..*)/$2/;
                        $config{'cell'}{$cellName}{'inputs'}{$port}{'srctype'}=$srctype;
                        $config{'cell'}{$cellName}{'inputs'}{$port}{'src'}=$src;
                    } else {
                        die "node $node is neither source nor sink of the wire!"
                    }
                } elsif ( $cellName =~ m/p_i(.*)/ ){
#               print "processing primary input $cellName\n";
                    my @path = @{$wire->get_attribute('path')};
                    my @inputDriverBuses = grep { /^b_hn(.*)/ } @path;
                    foreach my $inputDriverBus (@inputDriverBuses){
                    $config{'input'}{$cellName}{$inputDriverBus} = 1;
                }
                    
                } elsif ( $cellName =~m/p_o(.*)/ ){
#               print "processing primary output $cellName\n";

                    my @path = @{$wire->get_attribute('path')};
                    my @outputDriverBuses = grep { /^b_hn(.*)/ } @path;
                    foreach my $outputDriverBus (@outputDriverBuses){
                        $config{'output'}{$cellName}{$outputDriverBus} = 1;
                    }   
                } else {
                    die "no processing for cell $cellName has been implemented yet!";
                }
            }
        } # foreach $wire
    } # foreach $net
     
    ## insert routing cells since they are not covered by above code.    
    ##   a feedthrough cell look like this:  w_c_i_6_5_c_o_6_5

    foreach my $net ($self->get_nets){
        foreach my $wire ($net->get_wires){
            my @path = @{$wire->get_attribute('path')};
            for(my $i=0; $i<scalar(@path); $i++){
                if ($path[$i] =~ m/w_c_i_(\d+)_(\d+)_c_o_(\d+)_(\d+)/ 
                    and ($1 == $3) and ($2 == $4)) {
                    my $cell = sprintf("c_%d_%d",$1,$2);
                    my $feedWire = $path[$i-2];
                    my $driveWire = $path[$i+3];
                    print sprintf("insert feedtrough cell at %s with feedWire:%s driveWire:%s\n",
                            $cell, $feedWire, $driveWire);
                    $self->createFeedthroughCell(\%config,$cell,$feedWire,$driveWire);
                }
            }
        }
    }
    return \%config;
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

Zippy::Netlist::Netlist - Netlist handling for Zippy Applications

=head1 VERSION

This document refers to version N.NN of Zippy::Netlist::Netlist, released 
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
