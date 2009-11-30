package Zippy::Netlist::Znf;

$VERSION = 0.01;
use strict;
use warnings;
use Carp;
use FileHandle;
use Data::Dumper;
use Tools::Attributable;

use Zippy::Architecture::Router;
use Zippy::Architecture::RoutingGraph;

use vars qw(@ISA);
@ISA = qw( Tools::Attributable );

###################
#  ZNF (Zippy Netlist Format) handling class
#



sub new {
	my $proto = shift;
    my $class = ref($proto) || $proto;
	my $self = {};
	bless $self, $class;
	
	my %param = @_;
	
	if ($param{'infile'}) {
		$self->{'infile'} = $param{'infile'};
		$self->readFile($self->{'infile'});
	}
	
    	
#	my %attr = @_;
#	foreach my $key (keys %attr){
#		$self->set_attribute($key,$attr{$key});
#	}
	
	return $self;
}


sub readFile {
	my $self = shift;
	my $filename = shift;
	my $fh = new FileHandle;
	my @nltext;
	
	if ($fh->open("$filename")){
		if (not defined $fh){
			croak("cannot open: $filename $!\n");
		}
		LINE: foreach my $line ($fh->getlines){
			$line =~ s/^(.*?)(\s+)#(.*)/$1/;  # remove comments
			chomp($line);
			next LINE if ($line =~ /^\s*$/); # whitespace only or empty
			$line =~ s/(\s+)/ /g;
			push @nltext,$line;
			#print "$line\n";
		}
	}
	$self->set_attribute('nltext',\@nltext);
	$self->delete_attribute('nl');
}

sub parsePlacementConstraint {
    my $placementText = shift;

    my %r;
    my @c = split(':',$placementText);
    
    if ( (scalar(@c) == 1) and ($c[0] eq '*') ) {
        $r{constraintType} = 'none';
        $r{constraint} = '';
    } elsif ( (scalar(@c) == 2) and ($c[1] eq 'f') ) {
        $r{constraintType} = 'fixed';
        $r{constraint} = $c[0];
    } elsif ( (scalar(@c) == 2) and ($c[1] eq 'i') ) {
        $r{constraintType} = 'initial';
        $r{constraint} = $c[0];
    } else {
        warn sprintf("invalid placement constraint: \'%s\'\n",$placementText);
        return undef;
    }
    return \%r;
}

sub defaultCellAttributes {
    my $r;
    $r->{'i.0'} = 'unused';
    $r->{'i.1'} = 'unused';
    $r->{'i.2'} = 'unused';
    $r->{'o.0'} = 'unused';
    $r->{'f'} = 'alu_nop';

    return $r;
}

sub parseCellAttributes {
    my $attributesText = shift;
    
    my $r = defaultCellAttributes();

    if (defined $attributesText) {
        my @attrs = split(',',$attributesText);
        foreach $a (@attrs){
            my ($k,$v) = split('=',$a);
            $r->{$k}=$v;
        }
    }
    return $r;
}

sub getNetlist {
	my $self = shift;
	
	# cache netlist
	if (defined $self->get_attribute('nl')) {
		return $self->get_attribute('nl');
	}
	
	my $arNetlist = $self->get_attribute('nltext');
	my @nlText = @{$arNetlist};
	
	my @netlist = grep ( /^znf(.*)/, @nlText);
	my @inputs  = grep ( /^i(.*)/, @nlText);
	my @outputs = grep ( /^o(.*)/, @nlText);
	my @cells   = grep ( /^c(.*)/, @nlText);
	my @nets    = grep ( /^n(.*)/, @nlText);

	my $nl;
	my %nodes;
	
	### create netlist
	print "netlist:\n\t" . join("\n\t",@netlist) . "\n\n";
	if (scalar (@netlist) == 0) { 
		croak "znf delaration missing in ZNF file!\n";
	} elsif (scalar (@netlist) > 1) {
		croak "only one znf delaration allowed in a ZNF file!\n";
	} else {
		    $netlist[0] =~ m/(.*)\s+(.*)\s+(.*)/;
			my ($znf,$version,$name)  = ($1,$2,$3);
			print sprintf("znf:%s version:%f name:%s\n",$znf,$version,$name);
			$nl = Zippy::Netlist::Netlist->new($name);	
	}
	
	
	### create inputs
	print "inputs: \n\t" . join("\n\t",@inputs) . "\n\n";
	foreach my $line (@inputs){
		$line =~ m/^(.*)\s+(.*)\s+(.*)$/;
		my ($inp,$name,$placement)  = ($1,$2,$3);
        #my $placementConstraint = ($placement ne "*") ? 'fixed' : 'none';
        my $hrPlacement = parsePlacementConstraint($placement);
#		print sprintf("create inp:%s name:%s placement:%s\n",$inp,$name,$placement);
        die "invalid placement!" unless defined $hrPlacement;
        my $node = Zippy::Netlist::Node->new(
            $name, 
            type => 'in',
            placement => $hrPlacement->{constraint},
            placementconstr => $hrPlacement->{constraintType}
        );
        $nodes{$name} = $node;
	}
	
	### create outputs
	print "outputs:\n\t" . join("\n\t",@outputs) . "\n\n";
	foreach my $line (@outputs){
		$line =~ m/^(.*)\s+(.*)\s+(.*)$/;
		my ($outp,$name,$placement)  = ($1,$2,$3);
        my $hrPlacement = parsePlacementConstraint($placement);
#		print sprintf("create outp:%s name:%s placement:%s\n",$outp,$name,$placement);
        die "invalid placement!" unless defined $hrPlacement;
        #my $placementConstraint = ($placement ne "*") ? 'fixed' : 'none';
        my $node = Zippy::Netlist::Node->new(
            $name,
            type => 'out',
            placement => $hrPlacement->{constraint},
            placementconstr => $hrPlacement->{constraintType}
        );
        $nodes{$name} = $node;
	}
	
	### create cells
	print "cells:\n\t" . join("\n\t",@cells) . "\n\n";
	foreach my $line (@cells){
		$line =~ m/^(.*)\s+(.*)\s+(.*)\s+(.*)\s+(.*)$/;
        print "$line\n";
		my ($cell,$name,$type,$placement,$attributes)  = ($1,$2,$3,$4,$5);
#        print "cell:$cell name:$name type:$type plc:$placement attr:$attributes\n";
        my $hrPlacement = parsePlacementConstraint($placement);
        my $hrAttributes = parseCellAttributes($attributes);
        print sprintf("create cell:%s name:%s placement:%s type:%s attr:%s\n",
                      $cell,$name,$placement,$type,$attributes||'no_attributes');
        #print Dumper($hrAttributes);
        # create cell
        #my $placementConstraint = ($placement ne "*") ? 'fixed' : 'none';
        die "invalid placement for cell $cell" unless defined $hrPlacement;
        my $node = Zippy::Netlist::Node->new(
            $name,
            type => 'cell',
            subtype => 'std',
            placement => $hrPlacement->{constraint},
            placementconstr => $hrPlacement->{constraintType}
        );
        foreach my $key (keys %$hrAttributes){
            $node->set_attribute($key,$hrAttributes->{$key});
        }
		$nodes{$name} = $node;
	}

	### create nets
	print "nets:\n\t" . join("\n\t",@nets) . "\n\n";
	foreach my $line (@nets){
		$line =~ m/^(.*)\s+(.*)\s+(.*)\s+(.*)$/;
		my ($n,$name,$sourcePort,$sinkString)  = ($1,$2,$3,$4);
        my $source = $sourcePort;
        $source =~ s/(.*)\.(.*)\.(.*)/$1/;
		my @sinksPort = split( /,/ ,$sinkString);
        my @sinks = @sinksPort;
        
        # foearch loop aliases sinkname to element of sinksPort
        foreach my $sinkname (@sinks){
            $sinkname =~ s/(.*)\.(.*)\.(.*)/$1/;
        }

#       print "sinksPort: " . Dumper(\@sinksPort) ."\n";
#       print "sinks: " . Dumper(\@sinks) ."\n";

#		 print sprintf("create net:%s name:%s source:%s sinks:[%s]\n",$n,$name,$source,join(":",@sinks));

		my $net = Zippy::Netlist::Net->new($name);
		croak sprintf("error when adding net \'%s\': source \'%s\' was not defined!",
			$name,$source) unless defined $nodes{$source};

        for (my $i=0; $i<scalar(@sinks); $i++){
			croak sprintf("error while adding net \'%s\': source \'%s\' was not defined!",
				$name,$source) unless defined $nodes{$sinks[$i]};
			my $wire = Zippy::Netlist::Wire->new($nodes{$source},$nodes{$sinks[$i]});
            $wire->set_attribute('sourcePort',$sourcePort);
            $wire->set_attribute('sinkPort',$sinksPort[$i]);
			$net->add_wire($wire);
		}
        $net->set_attribute('routingstatus',$ZIPPY::Architecture::Router::ROUTER_UNROUTED);
		$nl->add_net($net);
	}
	$self->set_attribute('nl',$nl);
#    print Dumper($nl);
   return $nl;
}

sub netlist2Znf {
	my $self = shift;
	my $nl = shift;
	
	my $res;
	my (%inputs,%outputs,%cells,%nets);
	
	$res .= sprintf("znf 0.1 %s\n",$nl->name); 
	
	## the netlist class does not provide an easy way to access the various
	## node types. Hence, this loop iterates over all sources and sinks of 
	## any net, and collects data, about whate nodes are present in the current
	## netlist.
	##
	## FIXME: Make the netlist and node class aware of nodetype, or add a method 
	## to the netlist class, that returns all nodes of a certain type. What is 
	## basically what this method does.
	foreach my $net ($nl->get_nets){
		my $source = $net->source;
		my $sourceName = $source->name;
		my $sourceType = $source->get_attribute('type');
		if ($sourceType eq 'in') {
			if (!defined $inputs{$sourceName}) {
				$inputs{$sourceName} = $source;
			}
		} elsif ($sourceType eq 'cell') {
			if (!defined $cells{$sourceName}) {
				$cells{$sourceName} = $source;
			}
		} else {
			croak sprintf("netlist2Znf: a source of a net can only be of type 'in' or 'cell'!\n".
				" but this one is of type %s ",$sourceType);
		} 
		
		foreach my $sink ($net->get_sinks){
			my $sinkType = $sink->get_attribute('type');
			my $sinkName = $sink->name;
			if ($sinkType eq 'cell') {
				if (!defined $cells{$sinkName}) {
					$cells{$sinkName} = $sink;
				}
			} elsif ($sinkType eq 'out') {
				if (!defined $cells{$sinkName}) {
					$outputs{$sinkName} = $sink;
				}
			} else {
				croak sprintf("netlist2Znf: a sink of a net can only be of type 'out' or 'cell'!\n".
				" but this one is of type %s ",$sinkType);
			}
		}
	}

	foreach my $input (keys %inputs) {
		my $t = $inputs{$input};
		$res .= sprintf("i %s %s\n",$t->name,$t->get_attribute('placement'));
	}
	
	foreach my $output (keys %outputs) {
		my $t = $outputs{$output};
		$res .= sprintf("o %s %s\n",$t->name,$t->get_attribute('placement'));
	}
	
	foreach my $cell (keys %cells) {
		my $t = $cells{$cell};
		$res .= sprintf("c %s %s %s\n",$t->name,$t->get_attribute('subtype'),
			$t->get_attribute('placement'));
	}
	
	foreach my $net ($nl->get_nets){
		my @allWires = $net->get_wires;
		my (@sinkNames,@sinkRoutes);
		foreach my $wire (@allWires) {
			push @sinkNames,$wire->sink->name;
			#print "wire->sink->name " . $wire->sink->name . " Dumper: " . Dumper($wire->sink) ."\n";
			if (defined $wire->get_attribute('path')) {
				my @route = @{$wire->get_attribute('path')};
				my $routeStr = "[" . join(",",@route) . "]";
				push @sinkRoutes,$routeStr;
			}
		}
		my $sinkRouteStr;
		if (scalar(@sinkRoutes)) {
			$sinkRouteStr = join(",",@sinkRoutes)
		} else {
			$sinkRouteStr = "";
		}
		$res .= sprintf("n %s %s %s %s\n",$net->name, $net->source->name, 
		join(",",@sinkNames), $sinkRouteStr);
	}

	return $res;
	
}


1;

__END__
# class documentation template, see Damian Conways Book, p97

=pod

=head1 NAME

Zippy::Netlist::Znf - Zippy Netlist Format handling class

=head1 VERSION

This document refers to version N.NN of Zippy::Netlist::Znf, released 
March, 24, 2004

=head1 SYNOPSIS

# some short examples how to use the class

=head1 DESCRIPTION

=head2 Overview

=head3 ZNF (Zippy Netlist Format) Specification

Example Netlist (placed)

  znf 0.1 mynetlist     # netlist names mynetlist
  i in1 p_i.0:          # primary input "in1" placed at "p_i.0"
  i in2 p_i.1:          # primary input "in2" placed at "p_i.1"
  o out1 p_o.0          # primary output "out1" placed at "p_o.0"
  c op1 std c_2_3:f     # cell "op1" of type "std" fixed placement at "c_2_3"
  c op2 std c_3_3:i     # cell "op1" of type "std" initial placement at "c_3_3"
  c op3 std *           # cell "op1" of type "std" free placement
  n net1 in1 op1,op2    # net "net1" source "in1" sinks "op1" and "op2"     
  n net2 in2 op1        # net "net1" source "in1" sinks "op1" and "op2"
  n net3 op1 op3        # net "net1" source "in1" sinks "op1" and "op2"
  n net4 op2 op3        # net "net1" source "in1" sinks "op1" and "op2"
  n net5 op3 out1       # net "net1" source "in1" sinks "op1" and "op2"

The hash sign is used to introduce a comment, whitespace lines are ignored 

=head3 Placement specifiers for cells

B<fixed placement>
A fixed placement is specified with the name of the site, followed by a b<:f>
specifier. Fixed placement means, that the cell must be placed to the specified
location and cannot be moved

  c op1 std  c_0_2:f    # cell op1 is fixed placed to site c_0_2

B<initial placement>
An initial placement constraint specifies which site the placer shall use for 
the initial placement. This kind of constraint can be used to start an interative
place and route procedure from a given placement (placement hint). The initial
placement constraint is specified with the name of the site followed by a b<:i>.

  c op1 std  c_0_2:i   # cell op1 is initially placed to site c_0_2

B<free placement>
If the placer is allowed to freely chose a placement for a cell, the placement is
specificed with the wildcard specifier b<*>.
  
  c op1 std  *         # cell "op1" of type "std" can be placed to any site



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
