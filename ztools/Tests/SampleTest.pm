#!/usr/bin/env perl

package SampleTest;
use base qw(Test::Unit::TestCase);

sub new {
    my $self = shift()->SUPER::new(@_);
    # your state for fixture here
    return $self;
}

sub set_up {
    # provide fixture
    $foo = 'hello';
    $bar = 'Hello';
    $foobar = 'hello';
}

sub tear_down {
    # clean up after test
}

#sub test_foo {
#    my $self = shift;
#    my $obj = ClassUnderTest->new(...);
#    $self->assert_not_null($obj);
#    $self->assert_equals('expected result', $obj->foo);
#    $self->assert(qr/pattern/, $obj->foobar);
#}

sub test_fooisnotbar {
    $self = shift;
    $self->assert_str_not_equals($foo,$bar);
}

sub test_fooisfoobar {
    $self = shift;
    $self->assert_str_equals($foo,$foobar);
}

#ok ( $foo neq $bar );
#ok ( $foo eq $foobar );

1;
