package Zippy::Netlist::Node;

$VERSION = 0.01;
use strict;
use warnings;
use Carp;


use Tools::Attributable;
use vars qw( @ISA );
@ISA = qw( Tools::Attributable );


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

# constructors
# Zippy::Netlist::Node->new($name)
# Zippy::Netlist::Node->new($name, attr1 => $a1, attr2 => $a2, ..)


# constructor can be called with arbitrary number of attributes passed
# as hash parameter in initializer

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
	return $self;
}

sub name {
	my $self = shift;
	if (@_) {  # set new name
		$self->{'name'} = shift;
	}
	return $self->{'name'};
}

sub pp {
	my $self = shift;
	my $ret;
	$ret = sprintf("Node: name=%s\n",$self->name);
	foreach my $key ($self->get_attributes()){
		$ret .= sprintf("\t%s => %s\n",$key,$self->get_attribute($key));
	}
	return $ret;
}

1;

__END__

# class documentation template, see Damian Conways Book, p97

=pod

=head1 NAME

Zippy::Netlist - Netlist handling for Zippy Applications

=head1 VERSION

This document refers to version N.NN of Zippy::Netlist::Node, released 
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
