#!/usr/bin/env perl

package GeneratorTest;
use base qw(Test::Unit::TestCase);

use warnings;
use strict;

use Data::Dumper;
use lib "../";

sub new {
    my $self = shift()->SUPER::new(@_);
    # state for fixture here
    return $self;
}

sub set_up {
  my $self = shift;

  use Virtualizer::Generator;
  use Virtualizer::Analyzer;

  use Tools::CplexParser;
}

sub tear_down {
  my $self = shift;
  # clean up after test
}


# test nodes_without predecessor function
sub test_nodes_without_predecessor {

  my $self = shift;

  my $nl =<<END
in1  0.0 op1 0
in2  0.0 op1 0
op1  1.0 out
out  0.0
END
;

  my $G = Generator::initGraph('netlist' => $nl);
  my @expected = ('in1','in2');
  my @res = sort(Generator::nodes_without_predecessors($G));
  $self->assert_deep_equals(\@expected,\@res);
}



1;
