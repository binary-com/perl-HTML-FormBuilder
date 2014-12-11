
=head1 NAME

BOM::View::Form::Select - Select Element Handling for BOM Forms

=cut

package BOM::View::Form::Select;

use Moose;
use namespace::autoclean;
use Carp;

=head1 Synopsis

 my $select = BOM::View::Form::Select->new(
     id => 'my-select',
     name => 'my_select',
     options => [{value => 'foo', text => 'Foo'}, {value => 'bar', text => 'Bar'}],
     values => qw(foo),
 };
 $select->values('bar'); # set only 'bar'
 $select->values('foo', 'bar'); # set only 'foo'
 my $html = $select->widget_html;
 my $hidden_input_html = $select->hidden_html;

=head1 PROPERTIES

=head2 id - id property of form element

=cut

has id => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_id'
);

sub _build_id {
    my $self = shift;
    return $self->name;
}

=head2 name - name property of form element

=cut

has name => (
    is       => 'ro',
    isa      => 'Str',
    required => '1'
);

=head2 options - option arrayref to generate options

=cut

has options => (
    is  => 'rw',
    isa => 'ArrayRef[HashRef[Any]]'
);

=head2 values - values (by value) selected

=cut

has values => (
    is      => 'rw',
    isa     => 'ArrayRef[Any]',
    default => sub { [] },
);

=head2 value 

Actually just a method that grabs the first value from values

=cut

sub value {
    my $self   = shift;
    my $val    = shift;
    my $values = $self->values;
    return $values->[0] if defined $values and not defined $val;
    return $self->values([$val]) if defined $val;
    return;
}

=head1 METHODS

=head2 widget_html

=cut

sub widget_html {
    my $self = shift;
    my $html = '<select id="' . $self->id . '" name="' . $self->name . '">';
    $html .= $self->_option_html($_) for @{$self->options};
    $html .= "</select>";
    return $html;
}

sub _option_html {
    my ($self, $optionhash) = @_;
    my $value    = $optionhash->{value};
    my $text     = $optionhash->{text} // $value;
    my $selected = '';
    $optionhash->{disabled} //= '';
    $selected = ' SELECTED' if grep { $_ eq $value } @{$self->values};
    return qq|<option value="$value"$selected $optionhash->{disabled}>$text</option>|;
}

=head2 hidden_html

=cut

sub hidden_html {
    my $self = shift;
    return '<input type="hidden" id="' . $self->id . '" name="' . $self->name . '" value="' . ($self->value // '') . '" />';
}

__PACKAGE__->meta->make_immutable;
1;
