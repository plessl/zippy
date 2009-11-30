package Tools::Util;


$VERSION = 0.01;
use strict;
use warnings;
use Carp;

## return a random alement from a list.
##   argument is an array reference
##   return: $element
sub listChooseAny {
    my $aref = shift;
    die "argument must be array reference" if (ref($aref) ne "ARRAY");
    return $aref->[ int(rand( scalar(@{$aref})-1 )) ];
}

## remove a random element from a list
##   argument is an array reference
##   return:  ($element, $arrayref)
sub listRemoveAny {
    my $aref = shift;
    die "argument must be array reference" if (ref($aref) ne "ARRAY");

    my @a = @{$aref};
    my $elem = splice @a,int(rand(scalar(@a))-1),1;
    
    return ($elem, \@a);
}

## remove every element with value $elem form the array $aref (array reference)
## arg:     $elem
##          $aref
## return:  reference to array with element $elem removed
##
sub listRemoveElement {
    my $elem = shift;
    my $aref = shift;
    die "argument must be array reference" if (ref($aref) ne "ARRAY");

    my @a = grep { $_ ne $elem } @{$aref};
    return \@a;
}


## limit_low(arg,lower_bound)
## if arg < lower_bound return lower_bound, else return arg
sub limit_low ($$) {
	my $arg = shift;
	my $bound = shift;
	return  ($arg < $bound) ? $bound : $arg;  
}

## limit_high(arg,upper_bound)
## if arg > upper_bound return upper_bound, else return arg 
sub limit_high ($$) {
	my $arg;
	my $bound = shift;
	return ($arg > $bound) ? $bound : $arg;
}



1;

__END__

# class documentation template, see Damian Conways Book, p97

=pod

=head1 NAME

Tools::Util - misc utility function

=head1 VERSION

This document refers to version N.NN of Tools::Util, released 
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
