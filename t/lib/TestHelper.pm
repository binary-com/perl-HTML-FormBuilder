package TestHelper;
use Exporter 'import';
our @EXPORT = qw(create_form create_validation_form $classes);

our $classes = {
        fieldset_group          => 'toggle-content',
        NoStackFieldParent      => 'grd-grid-12',
        RowPadding              => 'grd-row-padding',
        fieldset_footer         => 'row comment',
        comment                 => 'grd-grid-12',
        row                     => 'row',
        extra_tooltip_container => 'extra_tooltip_container',
        backbutton              => 'backbutton',
        required_asterisk       => 'required_asterisk',
        inputtrailing           => 'inputtrailing',
        label_column            => 'grd-grid-4',
				input_column            => 'grd-grid-8',
				hide_mobile             => 'grd-hide-mobile',
													};


sub _create_form_helper {
    my $form_class      = shift;
    my $form_attributes = shift;
    return $form_class->new(data => $form_attributes, classes => $classes);
}

sub create_form {
    my $class = 'HTML::FormBuilder';
    return _create_form_helper( $class, @_ );
}

sub create_validation_form {
    my $class = 'HTML::FormBuilder::Validation';
    return _create_form_helper( $class, @_ );
}
1;

