package HTML::FormBuilder::FieldSet;
use strict;
use warnings;
use 5.008_005;
our $VERSION = '0.01';

use Carp;
use Scalar::Util qw(weaken blessed);

sub new{
	my $class = shift;
	my $self = {@_};

	croak("parent form must be given when create a new fieldset")
		unless ($self->{parent} && blessed($self->{parent}) && $self->{parent}->isa('HTML::FormBuilder'));
	weaken($self->{parent});
	$self->{fields} ||= [];
	bless $self, $class;
	return $self;
}

sub add_field{
	my $self = shift;
	my $_args = shift;

	# normalize: if 'input' is not an array, then make it as an array, so that
	# we can process the array directly
	if ( $_args->{input} && ref( $_args->{input} ) ne 'ARRAY' ) {
		$_args->{input} = [ $_args->{input} ];
	}
	push @{ $self->{'fields'} }, $_args;

	return 1;
}
