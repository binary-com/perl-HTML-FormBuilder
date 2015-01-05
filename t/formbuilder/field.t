use Test::More;
use strict;
use warnings;

use Test::Exception;

BEGIN{
	use_ok('HTML::FormBuilder');
	use_ok('HTML::FormBuilder::FieldSet');
	use_ok('HTML::FormBuilder::Field');
}

my $form = HTML::FormBuilder->new({id => 'testid'});
my $index = $form->add_fieldset({});
my $fieldset = $form->{fieldsets}[$index];
my $field;
lives_ok(sub{ $field = $fieldset->add_field( { input => { trailing => "This is trailling" } } );}, 'add field ok');
is($field->{data}{input}[0]{trailing}, 'This is trailling');
done_testing;
