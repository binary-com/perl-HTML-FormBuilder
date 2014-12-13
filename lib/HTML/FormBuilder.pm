package HTML::FormBuilder;

use strict;
use warnings;
use 5.008_005;
our $VERSION = '0.01';

use Carp;
use Template;

#####################################################################
# Usage      : Instantiate a Form object.
# Purpose    : Ensure Statement object is been instantiate with an id
# Returns    : Form object.
# Parameters : Hash reference with keys
#              'id'     => 'id_of_the_form',
#              'method' => 'post' #or get
# Comments   :
# See Also   :
#####################################################################
sub new {
    my $class = shift;
    my $_args = shift;
		my $options = shift;

		
    # fields & id must be given when instantiating a new object
    croak("Form must be given an id when instantiating a HTML::FormBuilder->new object in $0.") if !defined $_args->{'id'};

    my $self = $_args;
		$self->{method} ||= 'get';
    $self->{'method'} = ($self->{'method'} eq 'post') ? 'post' : 'get';
		$self->{localize} ||= sub {return @_};
		$self->{fieldset} ||= [];
    bless $self, $class;


    return $self;
}

#####################################################################
# Usage      : Add a new fieldset to the form
# Purpose    : Allow the form object to carry more than 1 fieldset
# Returns    :
# Parameters : Hash reference with keys in <fieldset> supported attributes
# Comments   : Fieldset works like a table, which allow one form to
#              have more than 1 fieldset. Each Fieldset has its own
#              input fields.
# See Also   :
#####################################################################
sub add_fieldset {
    my $self  = shift;
    my $_args = shift;

    #check if the Form object is created
    croak("Please instantiate the Form object first in $0.") if (!defined $self->{'id'});

    #check if the $args is a ref HASH
    croak("Parameters must in HASH reference in $0.") if (ref $_args ne 'HASH');

    $_args->{'fields'} = [];

    #get the last index of the ref array of fieldset by dereferrencing it
    my @fieldsets;

    push @fieldsets, $_args;
    $self->{'fieldset'} = \@fieldsets;

    #return fieldset id/index that was created
    return $#fieldsets;
}

#####################################################################
# Usage      : Add a new input fields to the fieldset
# Purpose    : Check is the fieldset is created, and if is created
#              add the input field into the fieldset
# Returns    :
# Parameters : Hash reference with keys
#              'label'   => $ref_hash
#              'input'   => $ref_hash
#              'error'   => $ref_hash
#              'comment' => $ref_hash
# Comments   : check pod below to understand how to create different input fields
# See Also   :
# TODO here should be changed
#####################################################################
sub add_field {
    my $self           = shift;
    my $fieldset_index = shift;
    my $_args          = shift;

    #check if the fieldset_index is number
		croak("The fieldset_index should be a number") unless ($fieldset_index =~ /^\d+$/);

		#check if the fieldset array is already created
    croak("The fieldset does not exist in $0. form_id[$self->{'id'}]") if ( $fieldset_index > $#{$self->{fieldset}} );

		push @{$self->{'fieldset'}[$fieldset_index]{'fields'}}, $_args;

    return 1;
}

#####################################################################
# Usage      : generate the form
# Purpose    : check and parse the parameters and generate the form
#              properly
# Returns    : form HTML
# Parameters : Fieldset index that would like to print, null to print all
# Comments   :
# See Also   :
#####################################################################
sub build {
    my $self                 = shift;
    my $print_fieldset_index = shift;

    my $html = $self->_build_element_and_attributes('form', $self);

    # build the fieldset, if $print_fieldset_index is specifed then
    # we only generate that praticular fieldset with that index
    my @fieldsets;
    if (defined $print_fieldset_index) {
        push @fieldsets, $self->{'fieldset'}->[$print_fieldset_index];
    } else {
        @fieldsets = @{$self->{'fieldset'}};
    }

    my %grouped_fieldset;
    # build the form fieldset
    foreach my $fieldset (@fieldsets) {
        my $fieldset_group = $fieldset->{'group'};
        my $stacked        = defined $fieldset->{'stacked'} ? $fieldset->{'stacked'} : 1;
        my $div_span       = "div";
        my $label_column   = "grd-grid-4";
        my $input_column   = "grd-grid-8";

        if ($stacked == 0) {

            $div_span     = "span";
            $label_column = "";
            $input_column = "";

        }

        if (not $fieldset_group) {
            $fieldset_group = 'no-group';
        }

        # fieldset legend
        my $legend = '';
        if (defined $fieldset->{'legend'}) {
            $legend = '<legend>' . $fieldset->{'legend'} . '</legend>';
            undef $fieldset->{'legend'};
        }

        # header at the top of the fieldset
        my $header = '';
        if (defined $fieldset->{'header'}) {
            $header = '<h2>' . $fieldset->{'header'} . '</h2>';
            undef $fieldset->{'header'};
        }

        # message at the top of the fieldset
        my $comment = '';
        if (defined $fieldset->{'comment'}) {
            $comment = '<div class="grd-grid-12"><p>' . $fieldset->{'comment'} . '</p></div>';
            undef $fieldset->{'comment'};
        }

        # message at the bottom of the fieldset
        my $footer = '';
        if (defined $fieldset->{'footer'}) {
            $footer = $fieldset->{'footer'};
            undef $fieldset->{'footer'};
        }

        my $fieldset_html = '';

        $fieldset_html .= $self->_build_element_and_attributes('fieldset', $fieldset);
        $fieldset_html .= $legend;
        $fieldset_html .= $header;
        $fieldset_html .= $comment;

        my $input_fields_html = '';

        if ($stacked == 0) {
            $input_fields_html .= '<div class="grd-grid-12">';
        }

        foreach my $input_field (@{$fieldset->{'fields'}}) {

            if ($stacked == 1) {

                if ($input_field->{'type'} and $input_field->{'type'} eq 'hidden') {
                    my $c = $input_field->{'class'} || '';
                    $input_fields_html .= '<div class="' . $c . '">';
                } elsif ($input_field->{'class'}) {
                    $input_fields_html .= '<div class="grd-row-padding row clear ' . $input_field->{'class'} . '">';
                } else {
                    $input_fields_html .= '<div class="grd-row-padding row clear">';
                }
            }

            #create the field label
            if (defined $input_field->{'label'}) {
                my $label_text = $input_field->{'label'}->{'text'} || '';
                undef $input_field->{'label'}->{'text'};

                # default is optional = false (mandatory)
                my $is_optional;
                if (defined $input_field->{'label'}->{'optional'}) {
                    $is_optional = $input_field->{'label'}->{'optional'};
                    undef $input_field->{'label'}->{'optional'};
                }
                # default is call_customer_support = false
                my $call_customer_support;
                if (defined $input_field->{'label'}->{'call_customer_support'}) {
                    $call_customer_support = $input_field->{'label'}->{'call_customer_support'};
                    undef $input_field->{'label'}->{'call_customer_support'};
                }

                # add a tooltip explanation if given
                if ($input_field->{'label'}->{'tooltip'}) {
                    $input_fields_html .= '<div class="extra_tooltip_container">'
                        . $self->_build_element_and_attributes(
                        'label',
                        $input_field->{'label'},
                        {
                            'is_optional'           => $is_optional,
                            'call_customer_support' => $call_customer_support
                        })
                        . $label_text
                        . '</label>'
												# img_url is the url of question mark picture
                        . _tooltip($input_field->{'label'}{'tooltip'}{'desc'}, $input_field->{'label'}{tooltip}{img_url})
                        . '</div>';
                } else {

                    my $hide_mobile = "";
                    if (length($label_text) == 0) {
                        $hide_mobile .= "grd-hide-mobile";
                    }

                    $input_fields_html .=
                          '<'
                        . $div_span
                        . ' class="'
                        . $label_column . ' '
                        . $hide_mobile
                        . ' form_label">'
                        . $self->_build_element_and_attributes(
                        'label',
                        $input_field->{'label'},
                        {
                            'is_optional'           => $is_optional,
                            'call_customer_support' => $call_customer_support
                        })
                        . $label_text
                        . '</label></'
                        . $div_span . '>';
                }
            }

            # create the input field
            if (defined $input_field->{'input'}) {

                #if there are more than 1 input field in a single row then we generate 1 by 1
                if (ref($input_field->{'input'}) eq 'ARRAY') {
                    $input_fields_html .= '<' . $div_span . ' class="' . $input_column . '">';
                    foreach my $input (@{$input_field->{'input'}}) {
                        $input_fields_html .= $self->_build_input_field($input);
                    }
                } else {
                    $input_fields_html .= '<' . $div_span . ' class="' . $input_column . '">' . $self->_build_input_field($input_field->{'input'});
                }
            }

            if (defined $input_field->{'comment'}) {
                $input_field->{'comment'}->{'class'} = $input_field->{'comment'}->{'class'} ? $input_field->{'comment'}->{'class'} : '';
                $input_fields_html .=
                    '<br>' . $self->_build_element_and_attributes('p', $input_field->{'comment'}) . $input_field->{'comment'}->{'text'} . '</p>';
            }

            if (defined $input_field->{'error'}) {
                if (ref $input_field->{'error'} eq 'ARRAY') {
                    foreach my $error_box (@{$input_field->{'error'}}) {
                        $input_fields_html .= $self->_build_element_and_attributes('p', $error_box) . $error_box->{'text'} . '</p>';
                    }
                } else {
                    my $attribs = $self->_build_element_and_attributes('p', $input_field->{'error'}) || '';
                    my $err = $input_field->{'error'}->{'text'} || '';
                    $input_fields_html .= $attribs . $err . '</p>';
                }
            }

            $input_fields_html .= '</' . $div_span . '>';

            if ($stacked == 1) {
                $input_fields_html .= '</div>';
            }
        }

        if ($stacked == 0) {
            $input_fields_html .= '</div>';
        }

        $fieldset_html .= $input_fields_html;

        if ($footer) {
            $fieldset_html .= '<div class="row comment">' . $footer . '</div>';
        }

        $fieldset_html .= '</fieldset>';

        if ((
                not $fieldset->{'id'}
                or $fieldset->{'id'} ne 'formlayout'
            )
            and (not $fieldset->{'class'} or $fieldset->{'class'} !~ /no-wrap|invisible/))
        {
            my $wrapped_fieldset = $self->_wrap_fieldset($fieldset_html);

            push @{$grouped_fieldset{$fieldset_group}}, $wrapped_fieldset;
        } else {
            push @{$grouped_fieldset{$fieldset_group}}, $fieldset_html;
        }
    }

    my $fieldsets_html = '';
    foreach my $fieldset_group (sort keys %grouped_fieldset) {
        if ($fieldset_group ne 'no-group') {
            $fieldsets_html .= '<div id="' . $fieldset_group . '" class="toggle-content">';
        }

        foreach my $fieldset_html (@{$grouped_fieldset{$fieldset_group}}) {
            $fieldsets_html .= $fieldset_html;
        }

        if ($fieldset_group ne 'no-group') {
            $fieldsets_html .= '</div>';
        }
    }

    $html .= $fieldsets_html . '</form>';

    if (not $self->{'hide_required_text'}) {
        $html .= '<p class="required"><em class="required_asterisk">*</em> - ' . $self->_localize('Required') . '</p>'
            if ($self->{'has_required_field'});
        $html .=
              '<p class="required"><em class="required_asterisk">**</em> - '
            . $self->_localize('To change your name, date of birth, or country of residence, please contact Customer Support.')
            . '</p>'
            if ($self->{'has_call_customer_support_field'});
    }

    return $html;
}

#
# This builds a bare-bone version of the form with all inputs hidden and only
# displays a confirmation button. It can be used for when we'd like to ask
# the Client to confirm what has been entered before processing.
#
# This output currently only outputs text or hidden fields, and ignores the
# rest. Extra functionality would need to be added to handle any type of form.
#
sub build_confirmation_button_with_all_inputs_hidden {
    my $self = shift;
    my @inputs;

    # get all inputs that are to be output as hidden
    foreach my $fieldset (@{$self->{'fieldset'}}) {
        INPUT:
        foreach my $input_field (@{$fieldset->{'fields'}}) {
            next INPUT if (not defined $input_field->{'input'});

            if (ref $input_field->{'input'} eq 'ARRAY') {
                push @inputs, @{$input_field->{'input'}};
            } else {
                push @inputs, $input_field->{'input'};
            }
        }
    }

    my $html = $self->_build_element_and_attributes('form', $self);

    foreach my $input (@inputs) {
        next if ($input->{'type'} and $input->{'type'} eq 'submit');
        my $n = $input->{'name'} || '';
        my $val = $self->get_field_value($input->{'id'}) || '';
        $html .= '<input type="hidden" name="' . $n . '" value="' . $val . '"/>';
    }

    $html .= '<input type="hidden" name="process" value="1"/>';
    $html .= _link_button({
        value => $self->_localize('Back'),
        class => 'backbutton',
        href  => 'javascript:history.go(-1)',
    });
    $html .=
        ' <span class="button"><button id="submit" class="button" type="submit">' . $self->_localize('Confirm') . '</button></span>';
    $html .= '</form>';

    return $html;
}

################################################################################
# Usage      : $form_obj->set_field_value('input_element_id', 'foo');
# Purpose    : Set input value based on input element id
# Returns    : none
# Parameters : $field_id: Input element ID
#              $field_value: Value (text)
# Comments   : Public
# See Also   : get_field_value
################################################################################
sub set_field_value {
    my $self        = shift;
    my $field_id    = shift;
    my $field_value = shift;

    my $input_field = $self->_get_input_field($field_id);

    if ($input_field) {
        if (ref ${$input_field}->{'input'} eq 'ARRAY') {
            # $_ is the alias of the reference of $input_field
            grep {
                if ($_->{'id'} and $field_id and $_->{'id'} eq $field_id) {
                    if (eval { $_->can('value') }) {
                        $_->value($field_value);
                    } elsif ($_->{'type'} =~ /(?:text|hidden|file)/i) {
                        $_->{'value'} = $field_value;
                    } elsif ($_->{'type'} eq 'checkbox') {
                        if ($field_value eq $_->{'value'}) {
                            $_->{'checked'} = 'checked';
                        }
                    }
                }
            } @{${$input_field}->{'input'}};
        } else {
            if (eval { ${$input_field}->{'input'}->can('value') }) {
                ${$input_field}->{'input'}->value($field_value);
            } elsif (${$input_field}->{'input'}->{'type'} =~ /(?:text|textarea|password|hidden|file)/i) {
                ${$input_field}->{'input'}{'value'} = $field_value;
            } elsif (${$input_field}->{'input'}->{'type'} eq 'checkbox' and $field_value eq ${$input_field}->{'input'}->{'value'}) {
                ${$input_field}->{'input'}->{'checked'} = 'checked';
            }
        }
    }
    return;
}

################################################################################
# Usage      : $form_obj->get_field_value('input_element_id');
# Purpose    : Get input value based on input element id
# Returns    : text (Input value) / undef
# Parameters : $field_id: Input element ID
# Comments   : Public
# See Also   : set_field_value
################################################################################
sub get_field_value {
    my $self     = shift;
    my $field_id = shift;

    my $input_field = $self->_get_input_field($field_id);

    if ($input_field) {
        if (ref ${$input_field}->{'input'} eq 'ARRAY') {

            foreach my $input (@{${$input_field}->{'input'}}) {
                if ($input->{'id'} and $input->{'id'} eq $field_id) {
                    if (eval { $input->can('value') }) {
                        return $input->value;
                    } elsif ($input->{'type'} =~ /(?:text|hidden|file)/i) {
                        return $input->{'value'};
                    } elsif ($input->{'type'} and $input->{'type'} eq 'checkbox' and $input->{'checked'} and $input->{'checked'} eq 'checked') {
                        return $input->{'value'};
                    }
                }
            }
        } else {
            if (eval { ${$input_field}->{'input'}->can('value') }) {
                return ${$input_field}->{'input'}->value;
            } elsif (${$input_field}->{'input'}->{'type'} =~ /(?:text|textarea|password|hidden|file)/i) {
                return ${$input_field}->{'input'}->{'value'};
            } elsif (${$input_field}->{'input'}->{'type'}
                and ${$input_field}->{'input'}->{'type'} eq 'checkbox'
                and ${$input_field}->{'input'}->{'checked'}
                and ${$input_field}->{'input'}->{'checked'} eq 'checked')
            {
                return ${$input_field}->{'input'}->{'value'};
            }
        }
    }

    return;
}

################################################################################
# Usage      : 1. $form_obj->set_field_error_message('input_element_id', 'some error');
#              2. $form_obj->set_field_error_message('error_element_id', 'some error');
# Purpose    : Set error message based on input element id or error element id
# Returns    : none
# Parameters : $field_id: Field ID (input or error)
#              $error_msg: Error message text
# Comments   : Public
# See Also   : get_field_error_message
################################################################################
sub set_field_error_message {
    my $self      = shift;
    my $field_id  = shift;
    my $error_msg = shift;

    my $input_field = $self->_get_input_field($field_id);

    if ($input_field) {
        ${$input_field}->{'error'}{'text'} = $error_msg;
    } else {
        my $error_field = $self->_get_error_field($field_id);
        if ($error_field) {
            ${$error_field}->{'error'}{'text'} = $error_msg;
        }
    }
    return;
}

################################################################################
# Usage      : 1. $form_obj->get_field_error_message('input_element_id');
#              2. $form_obj->get_field_error_message('error_element_id');
# Purpose    : Get error message based on input element id or error element id
# Returns    : text (Error message)
# Parameters : $field_id: Field ID (input or error)
# Comments   : Public
# See Also   : set_field_error_message
################################################################################
sub get_field_error_message {
    my $self     = shift;
    my $field_id = shift;

    my $input_field = $self->_get_input_field($field_id);

    if ($input_field) {
        return ${$input_field}->{'error'}{'text'};
    } else {
        my $error_field = $self->_get_error_field($field_id);
        if ($error_field) {
            return ${$error_field}->{'error'}{'text'};
        }
    }

    return;
}

#####################################################################
# Usage      : $self->_get_input_field('amount');
# Purpose    : Get the element based on input field id
# Returns    : Element contains input field
# Parameters : $field_id: Field ID
# Comments   : Private
# See Also   :
#####################################################################
sub _get_input_field {
    my $self     = shift;
    my $field_id = shift;

    #build the form fieldset
    my $fieldset_index = 0;
    foreach my $fieldset (@{$self->{'fieldset'}}) {
        my $input_field_index = 0;
        foreach my $input_field (@{$fieldset->{'fields'}}) {
            if (ref $input_field->{'input'} eq 'ARRAY') {
                foreach my $sub_input_field (@{$input_field->{'input'}}) {
                    if ($sub_input_field->{'id'} and $field_id and $sub_input_field->{'id'} eq $field_id) {
                        return \$self->{'fieldset'}[$fieldset_index]->{'fields'}[$input_field_index];
                    }
                }
            } else {
                if ($field_id and $input_field->{'input'}->{'id'} and $input_field->{'input'}->{'id'} eq $field_id) {
                    return \$self->{'fieldset'}[$fieldset_index]->{'fields'}[$input_field_index];
                }
            }
            $input_field_index++;
        }
        $fieldset_index++;
    }

    return;
}

#####################################################################
# Usage      : $self->_get_error_field('error_amount');
# Purpose    : Get the element based on error field id
# Returns    : Element contains error field
# Parameters : $error_id: Error ID
# Comments   : Private
# See Also   :
#####################################################################
sub _get_error_field {
    my $self     = shift;
    my $error_id = shift;

    #build the form fieldset
    my $fieldset_index = 0;
    foreach my $fieldset (@{$self->{'fieldset'}}) {
        my $input_field_index = 0;
        foreach my $input_field (@{$fieldset->{'fields'}}) {
            if ($input_field->{'error'}->{'id'} and $error_id and $input_field->{'error'}->{'id'} eq $error_id) {
                return \$self->{'fieldset'}[$fieldset_index]->{'fields'}[$input_field_index];
            }
            $input_field_index++;
        }
        $fieldset_index++;
    }

    return;
}

#####################################################################
# Usage      : build the html element and its own attributes
# Purpose    : perform checking and drop unnecessary attributes
# Returns    : element with its attributes in string
# Parameters : $element_tag such as p, input, label and etc
#              $attributes in HASH ref for example
#              $attributes = {'id' => 'test', 'name' => 'test', 'class' => 'myclass'}
# Comments   :
# See Also   :
#####################################################################
sub _build_element_and_attributes {
    my $self        = shift;
    my $element_tag = shift;
    my $attributes  = shift;
    my $options     = shift;

    #check if the elemen tag is empty
    return if ($element_tag eq '');

    my $html;
    $html = '<' . $element_tag;
    foreach my $key (sort keys %{$attributes}) {
        next if (ref($attributes->{$key}) eq 'HASH' or ref($attributes->{$key}) eq 'ARRAY');
        next if ($key ne 'value' and $attributes->{$key} and $attributes->{$key} eq '');

        # skip attributes that are not intended for HTML
        next if ($key =~ /^(?:option|text|hide_required_text|localize)/i);
        if ($attributes->{$key}) {
            $html .= ' ' . $key . '="' . $attributes->{$key} . '"';
        }
    }
    if ($element_tag eq 'button') {
        $html .= '>' . $attributes->{'value'} . '</' . $element_tag . '>';
    } else {
        $html .= '>';
    }

    # we actually pass this option as a string, not an integer
    if ($options and $options->{'is_optional'} and $options->{'is_optional'} eq '0') {
        $self->{'has_required_field'} = 1;
        if (not $self->{'hide_required_text'}) {
            $html .= '<em class="required_asterisk">*</em> ';
        }
    }

    # we actually pass this option as a string, not an integer
    if ($options and $options->{'call_customer_support'} and $options->{'call_customer_support'} eq '1') {
        $self->{'has_call_customer_support_field'} = 1;
        if (not $self->{'hide_required_text'}) {
            $html .= '<em class="required_asterisk">**</em> ';
        }
    }

    return $html;
}

#####################################################################
# Usage      : build the input field its own attributes
# Purpose    : perform checking build the input field according to its own
#              characteristics
# Returns    : input field with its attributes in string
# Parameters : $input_field in HASH ref for example
#              $attributes = {'id' => 'test', 'name' => 'test', 'class' => 'myclass'}
# Comments   : check pod below to understand how to create different input fields
# See Also   :
#####################################################################
sub _build_input_field {
    my $self        = shift;
    my $input_field = shift;

    my $html     = '';
    my $heading  = $input_field->{'heading'};
    my $trailing = $input_field->{'trailing'};

    # undefine this so that it doesn't carry on to the next field
    undef $input_field->{'heading'};
    undef $input_field->{'trailing'};

    #construct the required verification from the input
    if (defined $input_field->{'verification'}) {
        my @verifications;
        if (ref $input_field->{'verification'} eq 'ARRAY') {
            @verifications = @{$input_field->{'verification'}};
        } else {
            push @verifications, $input_field->{'verification'};
        }
        undef $input_field->{'verification'};
        $self->{'verify'}->{$input_field->{'id'}} = \@verifications;
    }

    #create the filed input
    if (eval { $input_field->can('widget_html') }) {
        $html = $input_field->widget_html;
    } elsif ($input_field->{'type'} and $input_field->{'type'} eq 'textarea') {
        undef $input_field->{'type'};
        my $textarea_value = $input_field->{'value'} || '';
        undef $input_field->{'value'};
        $html = $self->_build_element_and_attributes('textarea', $input_field);
        $html .= $textarea_value;
        $html .= '</textarea>';
    } else {
        if ($input_field->{'type'} and $input_field->{'type'} =~ /^(?:text|password)$/i) {
            $input_field->{'class'} .= ' text';
        } elsif ($input_field->{'type'} and $input_field->{'type'} eq 'button') {
            $input_field->{'class'} .= ' button';
        } elsif ($input_field->{'type'} and $input_field->{'type'} eq 'submit') {
            $input_field->{'class'} .= ' button';
        }
        # Only build input attribute if there is type defined.
        if ($input_field->{'type'} and $input_field->{'type'} =~ /button|submit/) {
            $html = $self->_build_element_and_attributes('button', $input_field) || '';
        } elsif ($input_field->{'type'}) {
            $html = $self->_build_element_and_attributes('input', $input_field) || '';
        }

        if ($input_field->{'type'} and ($input_field->{'type'} eq 'button' or $input_field->{'type'} eq 'submit')) {
            $html = '<span class="' . $input_field->{'class'} . '">' . $html . '</span>';
        }
    }

    if ($heading) {
        if (($input_field->{'type'} and lc $input_field->{'type'} eq 'radio') or ($input_field->{'type'} and lc $input_field->{'type'} eq 'checkbox'))
        {
            $html .= '<span id="inputheading">' . $heading . '</span><br />';
        } else {
            $html = '<span id="inputheading">' . $heading . '</span>' . $html;
        }
    }

    if ($trailing) {
        $html = $html . '<span class="inputtrailing">' . $trailing . '</span>';
    }

    return $html;
}

sub _localize{
	my $self = shift;
	$self->{localize}->(@_);
}

sub _link_button {
    my $args = shift;

    my $myclass = $args->{'class'} ? 'button ' . $args->{'class'} : 'button';

    my $myid     = $args->{'id'} ? 'id="' . $args->{'id'} . '"'      : '';
    my $myspanid = $args->{'id'} ? 'id="span_' . $args->{'id'} . '"' : '';

    return
          '<a class="'
        . $myclass
        . '" href="'
        . $args->{'href'} . '" '
        . $myid . '>'
        . '<span class="'
        . $myclass . '" '
        . $myspanid . '>'
        . $args->{'value'}
        . '</span>' . '</a>';
}


sub _tooltip {
	my $content = shift;
	my $url = shift;
    $content =~ s/\'/&apos;/g;    # Escape for quoting below

    return " <a href='#' title='" . $content . "' rel='tooltip'><img src=\"" . $url . "\" /></a>";
}

sub _template{
	return Template->new(
            ENCODING     => 'utf8',
            INTERPOLATE  => 1,
            PRE_CHOMP    => $Template::CHOMP_GREEDY,
            POST_CHOMP   => $Template::CHOMP_GREEDY,
            TRIM         => 1,
											);
}


sub _wrap_fieldset{
	my ($self, $fieldset_html)= @_;
	my $output = '';
	my $fieldset_template = <<EOF;
<div[% IF id %] id="[% id %]"[% END %] class="[% IF extra_class %]rbox [% extra_class %][% ELSE %]rbox[% END %][% IF expandable %] expandable[% END %][% IF collapsible %] collapsible[% END %]">
    <div class="rbox-wrap">
        [% IF heading %]
            <div class="rbox-heading">
                <h4 class="[% IF class %][% class %][% END %]">[% heading %]</h4>
            </div>
        [% END %]
        [% content %]
        <span class="tl">&nbsp;</span><span class="tr">&nbsp;</span><span class="bl">&nbsp;</span><span class="br">&nbsp;</span>
        [% IF expandable OR collapsible %]
            <div class="arrow-expand-collapse">
                <div class="arrow-expand-collapse-text">
                    <span class="show-all[% IF collapsible %] invisible[% END%]">show all</span>
                    <span class="hide-all[% IF expandable %] invisible[% END%]">hide bets</span>
                </div>
            </div>
        [% END %]
        [% IF close_button %]<div class="close_button"></div>[% END %]
    </div>
</div>

EOF

	$self->_template->process(
														\$fieldset_template,
														{
														 content => $fieldset_html,
														 extra_class => 'form'
														},
														\$output
													 );
	return $output;
}


1;

=head1 NAME

Form - A Multi-part HTML form

=head1 SYNOPSIS

  # First, create the Form object. The keys in the HASH reference is the attributes of the form
  $form_attributes => {'id'     => 'id_of_the_form',
                       'name'   => 'name_of_the_form',
                       'method' => 'post', # or get
                       'action' => 'page_to_submit',
					   'header' => 'My Form'};	#header of the form
  my $form = HTML::FormBuilder->new($form_attributes);

  #Then create fieldset, the form is allow to have more than 1 fieldset
  #The keys in the HASH reference is the attributes of the fieldset

  $fieldset_attributes => {'id'      => 'id_of_the_fieldset',
                           'name'    => 'name_of_the_fieldset',
                           'class'   => 'myclass',
                           'header'  => 'User details',      #header of the fieldset
                           'comment' => 'please fill in',    #message at the top of the fieldset
                           'footer'  => '* - required',};    #message at the bottom of the fieldset
  };
  $form->add_fieldset($fieldset_attributes);

  ####################################
  #Create the input fields.
  ####################################
  #When creating an input fields, there are 4 supported keys.
  #The keys are label, input, error, comment
  #  Label define the title of the input field
  #  Input define and create the actual input type
  #		In input fields, you can defined a key 'heading', which create a text before the input is displayed,
  #		however, if the input type is radio the text is behind the radio box
  #  Error message that go together with the input field when fail in validation
  #  Comment is the message added to explain the input field.

  ####################################
  ###Creating a input text
  ####################################

  my $input_text = {'label'   => {'text' => 'Register Name', for => 'name'},
                    'input'   => {'type' => 'text', 'value' => 'John', 'id' => 'name', 'name' => 'name', 'maxlength' => '22'},
					'error'   => { 'id' => 'error_name' ,'text' => 'Name must be in alphanumeric', 'class' => 'errorfield hidden'},
					'comment' => {'text' => 'Please tell us your name'}};

  ####################################
  ###Creating a select option
  ####################################
      my @options
	  push @options, {'value' => 'Mr', 'text' => 'Mr'};
	  push @options, {'value' => 'Mrs', 'text' => 'Mrs'};

      my $input_select = {'label' => {'text' => 'Title', for => 'mrms'},
                          'input' => {'type' => 'select', 'id' => 'mrms', 'name' => 'mrms', 'options' => \@options},
					      'error' => {'text' => 'Please select a title', 'class' => 'errorfield hidden'}};


  ####################################
  ###Creating a hidden value
  ####################################
  my $input_hidden = {'input' => {'type' => 'hidden', 'value' => 'John', 'id' => 'name', 'name' => 'name'}};

  ####################################
  ###Creating a submit button
  ####################################
  my $input_submit_button = {'input' => {'type' => 'submit', 'value' => 'Submit Form', 'id' => 'submit', 'name' => 'submit'}};

  ###NOTES###
  Basically, you just need to change the type to the input type that you want and generate parameters with the input type's attributes

  ###########################################################
  ###Having more than 1 input field in a single row
  ###########################################################
  my $input_select_dobdd = {'type' => 'select', 'id' => 'dobdd', 'name' => 'dobdd', 'options' => \@ddoptions};
  my $input_select_dobmm = {'type' => 'select', 'id' => 'dobmm', 'name' => 'dobmm', 'options' => \@mmoptions};
  my $input_select_dobyy = {'type' => 'select', 'id' => 'dobyy', 'name' => 'dobyy', 'options' => \@yyoptions};
  my $input_select = {'label' => {'text' => 'Birthday', for => 'dobdd'},
                      'input' => [$input_select_dobdd, $input_select_dobmm, $input_select_dobyy],
			          'error' => {'text' => 'Invalid date.'}};

  #Then we add the input field into the Fieldset
  #You can add using index of the fieldset
  $form->add_field(0, $input_text);
  $form->add_field(0, $input_select);
  $form->add_field(0, $input_submit_button);

  ###########################################################
  ### Field value accessors
  ###########################################################
  $form->set_field_value('name', 'Omid');
  $form->get_field_value('name'); # Returns 'Omid'

  ###########################################################
  ### Error message accessors
  ###########################################################
  $form->set_field_error_message('name',       'Your name is not good :)');
  # or
  $form->set_field_error_message('error_name', 'Your name is not good :)');

  $form->get_field_error_message('name');       # Return 'Your name is not good :)'
  # or
  $form->get_field_error_message('error_name'); # Return 'Your name is not good :)'

  #Finally, we output the form
  print $form->build();

=head1 DESCRIPTION

Object-oriented module for displaying an HTML form.

=head2 Overview of Form's HTML structure

The root of the structure is the <form> element and follow by multiple <fieldset> elements.

In each <fieldset>, you can create rows which contain label, different input types, error message and comment <p> element.

=head3 Full sample based on form definition given in SYNOPSIS

    <form id="onlineIDForm" method="post" action="">
       <fieldset id="fieldset_one" name="fieldset_one" class="formclass">
           <div>
		   	    <label for="name">Register Name</label>
				<em>:</em>
				<input type="text" value="John" id="name" name="name">
				<p id = "error_name" class="errorfield hidden">Name must be in alphanumeric</p>
				<p>Please tell us your name</p>
		   </div>
		   <div>
		   	    <label for="mrms">Title</label>
				<em>:</em>
				<select id="mrms" name="mrms">
					<option value="Mr">Mr</option>
					<option value="Mrs">Mrs</option>
				</select>
				<p class="errorfield hidden">Please select a title</p>
		   </div>
		   <div>
		   	    <label for="dob">Birthday</label>
				<em>:</em>
				<select id="dobdd" name="dobdd">
					<option value="1">1</option>
					<option value="2">2</option>
				</select>
				<select id="dobmm" name="dobmm">
					<option value="1">Jan</option>
					<option value="2">Feb</option>
				</select>
				<select id="dobyy" name="dobyy">
					<option value="1980">1980</option>
					<option value="1981">1981</option>
				</select>
				<p class="errorfield hidden">Invalid date</p>
		   </div>
		   <div>
		   		<input type="submit" value="Submit Form" id="submit" name="submit">
		   </div>
       </fieldset>
	</form>

=head1 AUTHOR

Bond Lim, E<lt>kheyeng@my.regentmarkets.com<gt>

=head1 COPYRIGHT AND LICENSE

=cut

###################################################################################################

=encoding utf-8

=head1 NAME

HTML::FormBuilder - Blah blah blah

=head1 SYNOPSIS

  use HTML::FormBuilder;

=head1 DESCRIPTION

HTML::FormBuilder is

=head1 AUTHOR

Chylli E<lt>chylli@binary.comE<gt>

=head1 COPYRIGHT

Copyright 2014- Chylli

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut

__DATA__
