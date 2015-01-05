use Test::More;
use strict;
use warnings;

use Test::Exception;

BEGIN{
	use_ok('HTML::FormBuilder');
	use_ok('HTML::FormBuilder::FieldSet');
}

my $form = HTML::FormBuilder->new({id => 'testid'});
my $index = $form->add_fieldset({});
my $fieldset = $form->{fieldsets}[$index];
isa_ok($fieldset, 'HTML::FormBuilder::FieldSet');
lives_ok(sub{$fieldset->add_field( { input => { trailing => "This is trailling" } } );}, 'add field ok');
is($fieldset->{fields}[0]{input}[0]{trailing}, 'This is trailling');
done_testing;
