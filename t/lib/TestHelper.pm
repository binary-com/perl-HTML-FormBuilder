package TestHelper;
use Exporter 'import';
our @EXPORT = qw($classes);

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

1;

