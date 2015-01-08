package HTML::FormBuilder::FieldSet;
use strict;
use warnings;
use 5.008_005;
our $VERSION = '0.01';


use HTML::FormBuilder::Field;
use Carp;
use Scalar::Util qw(weaken blessed);

use parent qw(HTML::FormBuilder::Base);

sub new{
	my $class = shift;
	my $self = {@_};

#	croak("parent form must be given when create a new fieldset")
#		unless ($self->{parent} && blessed($self->{parent}) && $self->{parent}->isa('HTML::FormBuilder'));
#	weaken($self->{parent});
	$self->{fields} ||= [];
	bless $self, $class;
	return $self;
}

sub add_field{
	my $self = shift;
	my $_args = shift;

	my $field = HTML::FormBuilder::Field->new(data => $_args, classes => $self->{classes});
	push @{ $self->{'fields'} }, $field;

	return $field;
}


#####################################################################
# Usage      : generate the form content for a fieldset
# Purpose    : check and parse the parameters and generate the form
#              properly
# Returns    : a piece of form HTML for a fieldset
# Parameters : fieldset
# Comments   :
# See Also   :
#####################################################################
sub build {
    my $self     = shift;

		my $data = $self->{data};
    #FIXME this attribute should be deleted, or it will emit to the html code
    my $fieldset_group = $data->{'group'};
    my $stacked = defined $data->{'stacked'} ? $data->{'stacked'} : 1;

    if ( not $fieldset_group ) {
        $fieldset_group = 'no-group';
    }

    my $fieldset_html = $self->_build_fieldset_foreword();

    my $input_fields_html = '';

    foreach my $input_field ( @{ $self->{'fields'} } ) {
			$input_fields_html .= $input_field->build({stacked => $stacked, classes => $self->{classes}});
    }

    if ( $stacked == 0 ) {
        $input_fields_html =
          $self->_build_element_and_attributes( 'div',
            { class => $self->{classes}{'NoStackFieldParent'} },
            $input_fields_html );
    }

    $fieldset_html .= $input_fields_html;

    # message at the bottom of the fieldset
    if ( defined $data->{'footer'} ) {
        my $footer = delete $data->{'footer'};
        $fieldset_html .=
          qq{<div class="$self->{classes}{fieldset_footer}">$footer</div>};
    }

    $fieldset_html =
      $self->_build_element_and_attributes( 'fieldset', $data,
        $fieldset_html );

    if (
        (
            not $data->{'id'}
            or $data->{'id'} ne 'formlayout'
        )
        and ( not $data->{'class'}
            or $data->{'class'} !~ /no-wrap|invisible/ )
      )
    {
        $fieldset_html = $self->_wrap_fieldset($fieldset_html);

    }
    return ( $fieldset_group, $fieldset_html );
}

#####################################################################
# Usage      : generate the form content for a fieldset foreword thing
# Purpose    : check and parse the parameters and generate the form
#              properly
# Returns    : a piece of form HTML code for a fieldset foreword
# Parameters : input_field, stacked
# Comments   :
# See Also   :
#####################################################################
sub _build_fieldset_foreword {
    my $self     = shift;
		my $data = $self->{data};
		
    # fieldset legend
    my $legend = '';
    if ( defined $data->{'legend'} ) {
        $legend = qq{<legend>$data->{legend}</legend>};
        undef $data->{'legend'};
    }

    # header at the top of the fieldset
    my $header = '';
    if ( defined $data->{'header'} ) {
        $header = qq{<h2>$data->{header}</h2>};
        undef $data->{'header'};
    }

    # message at the top of the fieldset
    my $comment = '';
    if ( defined $data->{'comment'} ) {
        $comment =
qq{<div class="$self->{classes}{comment}"><p>$data->{comment}</p></div>};
        undef $data->{'comment'};
    }

    return $legend . $header . $comment;
}

#####################################################################
# Usage      : $self->_wrap_fieldset($fieldset_html)
# Purpose    : wrap fieldset html by template
# Returns    : HTML
# Comments   :
# See Also   :
#####################################################################
sub _wrap_fieldset {
    my ( $self, $fieldset_html ) = @_;
    my $output            = '';
    my $fieldset_template = <<EOF;
<div class="rbox form">
    <div class="rbox-wrap">
        $fieldset_html
        <span class="tl">&nbsp;</span><span class="tr">&nbsp;</span><span class="bl">&nbsp;</span><span class="br">&nbsp;</span>
    </div>
</div>
EOF

    return $fieldset_template;

}
