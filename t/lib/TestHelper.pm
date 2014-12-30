package TestHelper;
use Exporter 'import';
our @EXPORT = qw(create_form create_validation_form);

sub _create_form_helper{
	my $form_class = shift;
	my $form_attributes = shift;
	my $form_classes = {
									 fieldset_group => 'toggle-content',
									 NoStackFieldParent => 'grd-grid-12',
									 RowPadding => 'grd-row-padding',
									 fieldset_footer => 'row comment',
									 comment => 'grd-grid-12',
									 row => 'row',
									 extra_tooltip_container => 'extra_tooltip_container',
									 backbutton => 'backbutton',
									 required_asterisk => 'required_asterisk',
									 inputtrailing => 'inputtrailing',
										 };
	$form_attributes->{classes} = $form_classes;
	return $form_class->new($form_attributes);
}

sub create_form{
	my $class = 'HTML::FormBuilder';
	return _create_form_helper($class, @_);
}

sub create_validation_form{
	my $class = 'HTML::FormBuilder::Validation';
	return _create_form_helper($class, @_);
}
1;


1;
