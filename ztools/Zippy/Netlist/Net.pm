package Zippy::Netlist::Net;

## 

$VERSION = 0.01;
use strict;
use warnings;
use Carp;

use Data::Dumper;
use Tools::Attributable;

use vars qw( @ISA );
@ISA = qw( Tools::Attributable );



## TODO
#    open questions:
#    should source and sink be a string or a reference to the respective node

####################
# Net Class:
#   $name:   unique identifier of this net
#   @wires:  wires that are part of this net
#       
#   attributes of a wire:
#		$source: name of source node
#       $sink:   name of sink node
#       %prop:   application defined properties that have no interpretation on the
#                netlist level, e.g. the router would add a @path property to hold the
#                route that was determined for this net

sub new {
	my $proto = shift;
    my $class = ref($proto) || $proto;
	my $name = shift;
	
	my $self = {};
	bless $self, $class;
    
	$self->name($name);
	$self->{'wires'} = ();
	
	return $self;
}

sub name {
	my $self = shift;
	if (@_) {
		$self->{'name'} = shift;
	}
	return $self->{'name'};
}

sub add_wire {
	my $self = shift;
	my $w = shift;
	push @{$self->{'wires'}},$w; 
}

sub get_wires {
    my $self = shift;
    return @{$self->{'wires'}};
}

sub source {
	my $self = shift;
	my @wires = $self->get_wires;
	return $wires[0]->source; 
}

sub get_sinks {
	my $self = shift;
	my @sinks;
	foreach my $wire ($self->get_wires()){
		push @sinks,$wire->sink;
	}
	return @sinks;
}

sub pp {
	my $self = shift;
	my $res;
	my $i = 0;
	$res .= sprintf("net: %s\n",$self->name());
    my $rs = $self->get_attribute('routingstatus');
        
    if (not defined $rs){
        $res .= sprintf("\trouting status: unknown\n");
    } elsif ($rs == $Zippy::Architecture::Router::ROUTER_UNROUTED){
        $res .= sprintf("\trouting status: unrouted\n");
    } elsif ($rs == $Zippy::Architecture::Router::ROUTER_ROUTED){
        $res .= sprintf("\trouting status: routed\n");
    } elsif ($rs == $Zippy::Architecture::Router::ROUTER_UNROUTABLE){
        $res .= sprintf("\trouting status: unroutable\n");
    } else {
        $res .= sprintf("\trouting status: unknown\n");
    }

	foreach my $wire ($self->get_wires()) {
		my $sourcepl = defined $wire->source->get_attribute('placement') ?
			 $wire->source->get_attribute('placement') : '-';
        my $sourceplConstr = $wire->source->get_attribute('placementconstr');

		my $sinkpl = defined $wire->sink->get_attribute('placement') ?
			 $wire->sink->get_attribute('placement') : '-';
        my $sinkplConstr = $wire->sink->get_attribute('placementconstr');	 

		$res .= sprintf("\twire %d:\n\t\tfrom:%s [%s constr:%s]\tto:%s [%s constr:%s]\n",
			$i++,$wire->source->name,$sourcepl,$sourceplConstr,
            $wire->sink->name,$sinkpl,$sinkplConstr); 
        $res .= sprintf("\t\tsourcePort: %s\n",$wire->get_attribute('sourcePort'));
        $res .= sprintf("\t\tsinkPort: %s\n",$wire->get_attribute('sinkPort'));
                        
        my $path = $wire->get_attribute('path');
		if (defined $path) {
			$res .= sprintf("\t\tpath: \n\t\t\t[%s\n\t\t\t]\n",join(",\n\t\t\t",@{$path}));
		} else {
			$res .= sprintf("\t\tpath [unknown]\n");
		}
		my $cost = $wire->get_attribute('pathcost');
		if (defined $cost) {
			$res .= sprintf("\t\tpathcost: %d\n",$cost);
		} else {
			$res .= sprintf("\t\tpathcost: unknown\n");
		}
	}
	return $res;
}

1;

__END__

# class documentation template, see Damian Conways Book, p97

=pod

=head1 NAME

Zippy::Architecture::RoutingGraph - Routing Architecture of the Zippy array

=head1 VERSION

This document refers to version N.NN of Zippy::Architecture::RoutingGraph, released 
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
