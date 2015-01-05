package HTML::FormBuilder::Field;
use strict;
use warnings;
use 5.008_005;
our $VERSION = '0.01';

use Carp;
use Scalar::Util qw(weaken blessed);

sub new{
	my $class = shift;
	my $self = {@_};

	# normalize: if 'input' is not an array, then make it as an array, so that
	# we can process the array directly
	if($self->{data}{input} && ref($self->{data}{input}) ne 'ARRAY'){
		$self->{data}{input} = [$self->{data}{input}];
	}
	bless $self, $class;
	return $self;
}
