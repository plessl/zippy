package Tools::GraphTools;


$VERSION = 0.01;
use strict;
use warnings;
use Carp;

use Graph;


################################################################################
sub deep_copy 
################################################################################
# creates a deep_copy of a Graph object. By default, a  Graph object is not copied 
# if it is copied like this:
#
#  my $G = new Graph; $G_copy = $G;
#
# In this case, $G_copy is merely a new reference that references the same object
# as G does. Using $G_copy = Tools::GraphTools($G) creates a real deep-copy of the 
# graph object $G.
################################################################################
{
  require Data::Dumper;
  my $g = shift;
  my $d = Data::Dumper->new([$g]);
  use vars qw($VAR1);
  $d->Purity(1)->Terse(1)->Deepcopy(1);
  $d->Deparse(1) if $] >= 5.008;
  eval $d->Dump;
}



################################################################################
# dump the routing graph in the 'dot' file format.
#   the resulting 'dot' description can be visualized with the popular Graphviz
#   graph visualization software
################################################################################
sub dumpGraphAsDot {
#    my $self = shift;
    my $graph = shift;
    
    my $res = "digraph G {\n";
    #$res .= "size=\"8,11\";\n";
    #$res .= "page=\"8,9\";\n";
    #$res .= "fixed-size=true;";

    my $shape;
    foreach my $vertex ($graph->vertices){
        if ($graph->is_source_vertex($vertex)) {
            $shape = 'shape=house';
        } elsif ($graph->is_sink_vertex($vertex)) {
            $shape = 'shape=invhouse';
        } else {
            $shape = 'shape=circle';
        }
        $res .= sprintf("  %s [%s,label=\"%s\"];\n",_dotquote($vertex),$shape,$vertex);
    }

    my @edges = $graph->edges;
	for(my $i=0;$i<scalar(@edges);$i+=2){
		$res .= sprintf("  %s -> %s;\n",_dotquote($edges[$i]),_dotquote($edges[$i+1]));
	}

    $res .= "}\n";
	return $res;
}

################################################################################
# dot is a bit picky about the names of the nodes in the graph
#   replace all special characters with letters, the name for the node in the 
#   dot graph needs to be passed with a lable argument
################################################################################
sub _dotquote{
	my $arg = shift;
	$arg =~ s/_/X/g;
	$arg =~ s/\./Y/g;
	$arg =~ s/-/Z/g;
	return $arg; 
}


1;

__END__

# class documentation template, see Damian Conways Book, p97

=pod

=head1 NAME

Tools::GraphTools - no description yet

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
