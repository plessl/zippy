package Zippy::Netlist::Wire;

$VERSION = 0.01;

use strict;
use Carp;
use warnings;

use Tools::Attributable;
use vars qw( @ISA );
@ISA = qw( Tools::Attributable );


####################
# Wire Class:
#
#   attributes of a wire:
#
#   $source:   reference to the source node of this wire
#   $sink:     reference to the sink node of this wire
#   %attr:     application defined attributes that have no interpretation on the
#              netlist level, e.g. the router would add a @path property to hold the
#              route that was determined for this net

sub new {
	my $proto = shift;
    my $class = ref($proto) || $proto;
	my $source = shift;
	my $sink = shift;
	
	if (! $source->isa("Zippy::Netlist::Node")) {
		croak("source must be of type Zippy::Netlist::Node\n");
	}
	if (! $sink->isa("Zippy::Netlist::Node")) {
		croak("sink must be of type Zippy::Netlist::Node\n");
	}
	
	my $self = {};
	bless $self, $class;
    
	$self->source($source);
	$self->sink($sink);
	$self->{'attr'} = {};	
	return $self;
}

sub source {
	my $self = shift;
	if (@_) {
		$self->{'source'} = shift;
	}
	return $self->{'source'};
}

sub sink {
	my $self = shift;
	if (@_) {
		$self->{'sink'} = shift;
	}
	return $self->{'sink'};
}

1;

__END__

# class documentation template, see Damian Conways Book, p97

=pod

=head1 NAME

Zippy::Netlist::Wire - Netlist handling for Zippy Applications

=head1 VERSION

This document refers to version N.NN of Zippy::Netlist::Wire, released 
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
