#!/usr/bin/env perl

package Tools::CplexParser;

our ($VERSION, $SVN);

$VERSION = 0.01;
$SVN = '$Id: CplexParser.pm 328 2005-09-15 16:37:03Z plessl $';

use strict;
use Carp;
use warnings;
use FileHandle;
use Data::Dumper;

#use vars qw( @ISA );
#@ISA = qw( Tools::Attributable );

sub new {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  
  my $argHref = shift;

  my $self = {};
  bless $self, $class;

  # check constructor arguments
  die "no filename defined" unless defined $argHref->{'filename'};

  $self->filename($argHref->{'filename'});
  $self->parse;

  return $self;
}

sub filename {
  my $self = shift;
  if (@_) {
    my $file = shift;  
    #print "pwd is: " . `pwd` . "\n";
    if (! -f $file) {
      die "cannot read file $file: $!";
    }
    $self->{'filename'} = $file;
  }
  return $self->{'filename'};
}

sub parse {
  my $self = shift;
  my $fh = FileHandle->new($self->filename,"r") or die "$!";
  my (%variable, $problem_name, $line);

  while ( $line = $fh->getline ){
    if ( $line =~ m/NAME\s+(\w+)\s+/ ){
      $self->problemName($1);
    } elsif ( $line =~  m/\s+(\w+)\s+(\w+)\s*/o) {
      $variable{$1}=$2;
    }
  }
  ## TODO: clean syntax?
  %{$self->{'variables'}} = %variable;
  #print Dumper($self);die;
}

sub get_variable {
  my $self = shift;
  my $variable = shift;
  return $self->{'variables'}{$variable};
}

sub get_variable_names {
  my $self = shift;
  return keys %{$self->{'variables'}};
}

sub problemName {
  my $self = shift;
  if (@_) {
    $self->{'problemName'} = shift;
  }
  return $self->{'problemName'};
}

1;

__END__
