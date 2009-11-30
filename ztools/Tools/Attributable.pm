package Tools::Attributable;


$VERSION = 0.01;
use strict;
use warnings;
use Carp;

my $ATTRIBUTE_KEY = 'attr'; #### use this key for compatibility reasons

# FIXME
#$ATTRIBUTE_KEY = '_attr'; ## a nicer key, activate after conversion of all 
# classes to use the Tools::Attributable base class 

sub set_attribute {
	my $self = shift;
	my $attname = shift;
	my $att = shift;
	return $self->{$ATTRIBUTE_KEY}->{$attname} = $att; 
}

sub get_attribute {
	my $self = shift;
	my $attname = shift;
	return $self->{$ATTRIBUTE_KEY}->{$attname};
}

sub delete_attribute {
	my $self = shift;
	my $attname = shift;
	return (delete $self->{$ATTRIBUTE_KEY}->{$attname});
}

sub get_attributes {
	my $self = shift;
	return keys %{$self->{$ATTRIBUTE_KEY}};
}


1;

__END__

# class documentation template, see Damian Conways Book, p97

=pod

=head1 NAME

Tools::Attributable - Generic Attribute Handling Class for Hash Based Classes

=head1 VERSION

This document refers to version N.NN of Tools::Attributable, released 
April, 14, 2004

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
