package HTML::FormBuilder::Validation;
use strict;
use warnings;
use base 'HTML::FormBuilder';

use strict;
use Carp;
use Class::Std::Utils;
use Text::Trim;

use Encode;
use URI::Escape;
use HTML::Entities;
	
my %has_error_of;
my %custom_server_side_check_of;

########################################################################
# Usage      : HTML::FormBuilder::Validation->new($arg_ref);
# Purpose    : Form validation object constructor
# Returns    : HTML::FormBuilder::Validation object
# Parameters : Same as Form
# Comments   : Public
# See Also   : POD
########################################################################
sub new {
    my $class = shift;
    my $_arg  = shift;
    my $self  = $class->SUPER::new($_arg);

    bless($self, $class);
    $has_error_of{ident $self} = 0;

    return $self;
}

########################################################################
# Usage      : $form_validation_obj->set_input_fields(\%input);
# Purpose    : Set input fields value based on last submit form.
# Returns    : none
# Parameters : \%input: HASH ref to %input
# Comments   : Public
#              NOTE: This subroutine can use only if fields have same
#              name and id.
#              (i.e. <input id="name" name="name" type="text" />)
# See Also   : n / a
########################################################################
sub set_input_fields {
    my $self  = shift;
    my $input = shift;

    for my $element_id (keys %{$input}) {
        $self->set_field_value($element_id, $input->{$element_id});
    }
    return;
}

sub build {
    my $self                 = shift;
    my $print_fieldset_index = shift;

    my $html;
    my $javascript_validation = '';

    #build the fieldset, if $print_fieldset_index is specifed then we only generate that praticular fieldset with that index
    my @fieldsets;
    if (defined $print_fieldset_index) {
        push @fieldsets, $self->{data}{'fieldset'}->[$print_fieldset_index];
    } else {
        @fieldsets = @{$self->{data}{'fieldset'}};
    }

    #build the form fieldset
    foreach my $fieldset (@fieldsets) {
        foreach my $input_field (@{$fieldset->{'fields'}}) {
            # build inputs javascript validation
            my $valition = $self->_build_javascript_validation({'input_field' => $input_field}) || '';
            $javascript_validation .= $valition;
        }
    }

    $self->{data}{'onsubmit'} = "function v() { var bResult = true; $javascript_validation; return bResult; }; return v();";

    return $self->SUPER::build();
}

########################################################################
# Usage      : $form_validation_obj->validate();
# Purpose    : Validate form input
# Returns    : true (No ERROR) / false
# Parameters : none
# Comments   : Public
# See Also   : n / a
########################################################################
sub validate {
    my $self      = shift;
    my @fieldsets = @{$self->{data}{'fieldset'}};

    foreach my $fieldset (@fieldsets) {
        INPUT_FIELD:
        foreach my $input_field (@{$fieldset->{'fields'}}) {
            if ($input_field->{'input'} and $input_field->{'error'}->{'id'}) {
                    foreach my $input_element (@{$input_field->{'input'}}) {
                        if (eval { $input_element->{'input'}->can('value') }
                            and (not defined $self->get_field_value($input_element->{'id'})))
                        {
                            $self->set_field_error_message($input_element->{'id'}, $self->_localize('Invalid amount'));
                            next INPUT_FIELD;
                        }
                    }
            }

            # Validate each field
            if (    defined $input_field->{'validation'}
                and $input_field->{'input'}
                and $input_field->{'error'}->{'id'})
            {
                $self->_validate_field({
                    'validation'    => $input_field->{'validation'},
                    'input_element' => $input_field->{'input'},
                });
            }
        }
    }

    if ($custom_server_side_check_of{ident $self}) {
        &{$custom_server_side_check_of{ident $self}}();

    }

    return ($self->get_has_error) ? 0 : 1;
}

sub is_error_found_in {
    my $self             = shift;
    my $input_element_id = shift;

    return $self->get_field_error_message($input_element_id);
}

########################################################################
# Usage      : $self->_set_has_error();
# Purpose    : Set has error to indicate form has error and should be
#              rebuild again.
# Returns    : none
# Parameters : none
# Comments   : Private
# See Also   : n / a
########################################################################
sub _set_has_error {
    my $self = shift;

    $has_error_of{ident $self} = 1;
    return;
}

########################################################################
# Usage      : $form_validation_obj->get_has_error();
# Purpose    : Check if form has error
# Returns    : 0 / 1
# Parameters : none
# Comments   : Public
# See Also   : n / a
########################################################################
sub get_has_error {
    my $self = shift;

    return $has_error_of{ident $self};
}

sub set_field_error_message {
    my $self          = shift;
    my $element_id    = shift;
    my $error_message = shift;

    $self->SUPER::set_field_error_message($element_id, $error_message);
    if ($error_message) {
        $self->_set_has_error();
    }
    return;
}

########################################################################
# Usage      : $self->_build_javascript_validation
#              ({
#                 'validation'       => $input_field->{'validation'},
#                 'input_element'    => $input_field->{'input'},
#                 'error_element_id' => $input_field->{'error'}->{'id'},
#              });
# Purpose    : Create javascript validation code.
# Returns    : text (Javascript code)
# Parameters : $arg_ref:
#              {
#                'validation': ARRAY ref to $input_field->{'validation'}
#                'input_element': HASH ref to input element
#                'error_element_id': error element id
#              }
# Comments   : Private
# See Also   : build()
########################################################################
sub _build_javascript_validation {
    my $self    = shift;
    my $arg_ref = shift;
    my $javascript;

    my $input_field = $arg_ref->{'input_field'};

    if (    defined $input_field->{'validation'}
        and $input_field->{'input'}
        and $input_field->{'error'}->{'id'})
    {

        my @validations      = @{$input_field->{'validation'}};
        my $input_element    = $input_field->{'input'};
        my $error_element_id = $input_field->{'error'}->{'id'};

        my $input_element_id;
        my $input_element_conditions;

				foreach my $input_field (@{$input_element}) {
					if (defined $input_field->{'id'}) {
						$input_element_id = $input_field->{'id'};
						$javascript               .= "var input_element_$input_element_id = document.getElementById('$input_element_id');";
						$input_element_conditions .= "input_element_$input_element_id && ";
					}
				}
        

        $javascript .=
              "var error_element_$error_element_id = clearInputErrorField('$error_element_id');"
            . "if ($input_element_conditions error_element_$error_element_id)" . '{'
            . 'var regexp;'
            . 'bInputResult = true;';

        foreach my $validation (@validations) {
            if ($validation->{'type'} =~ /(?:regexp|min_amount|max_amount|custom)/) {
                # if the id define in the validation hash, meaing input has more than 1 fields, the validation is validated against the id
                if ($validation->{'id'} and length $validation->{'id'} > 0) {
                    $input_element_id = $validation->{'id'};
                }

                if ($validation->{'type'} and $validation->{'type'} eq 'regexp') {
                    my $regexp = $validation->{'regexp'};
                    $regexp =~ s/(\\|')/\\$1/g;
                    $javascript .= ($validation->{'case_insensitive'}) ? "regexp = new RegExp('$regexp', 'i');" : "regexp = new RegExp('$regexp');";

                    if ($validation->{'error_if_true'}) {
                        $javascript .= 'if (bInputResult && regexp.test(input_element_' . $input_element_id . '.value))';
                    } else {
                        $javascript .= 'if (bInputResult && !regexp.test(input_element_' . $input_element_id . '.value))';
                    }

                    $javascript .= '{'
                        . 'error_element_'
                        . $error_element_id
                        . '.innerHTML = decodeURIComponent(\''
                        . _encode_text($validation->{'err_msg'}) . '\');'
                        . 'bInputResult = false;' . '}';
                }
                # Min amount checking
                elsif ($validation->{'type'} and $validation->{'type'} eq 'min_amount') {
                    $javascript .=
                          'if (bInputResult && input_element_'
                        . $input_element_id
                        . '.value < '
                        . $validation->{'amount'} . ')' . '{'
                        . 'error_element_'
                        . $error_element_id
                        . '.innerHTML = decodeURIComponent(\''
                        . _encode_text($validation->{'err_msg'}) . '\');'
                        . 'bInputResult = false;' . '}';
                }
                # Max amount checking
                elsif ($validation->{'type'} and $validation->{'type'} eq 'max_amount') {
                    $javascript .=
                          'if (bInputResult && input_element_'
                        . $input_element_id
                        . '.value > '
                        . $validation->{'amount'} . ')' . '{'
                        . 'error_element_'
                        . $error_element_id
                        . '.innerHTML = decodeURIComponent(\''
                        . _encode_text($validation->{'err_msg'}) . '\');'
                        . 'bInputResult = false;' . '}';
                }
                # Custom checking
                elsif ($validation->{'type'} and $validation->{'type'} eq 'custom') {
                    if ($validation->{'error_if_true'}) {
                        $javascript .=
                              'if (bInputResult && '
                            . $validation->{'function'} . ')' . '{'
                            . 'error_element_'
                            . $error_element_id
                            . '.innerHTML = decodeURIComponent(\''
                            . _encode_text($validation->{'err_msg'}) . '\');'
                            . 'bInputResult = false;' . '}';
                    } else {
                        $javascript .=
                              'if (bInputResult && !'
                            . $validation->{'function'} . ')' . '{'
                            . 'error_element_'
                            . $error_element_id
                            . '.innerHTML = decodeURIComponent(\''
                            . _encode_text($validation->{'err_msg'}) . '\');'
                            . 'bInputResult = false;' . '}';
                    }
                }
            }
        }

        $javascript .= 'if (!bInputResult)' . '{' . 'bResult = bInputResult;' . '}' . '}';

    }
    # get the general error field (contain only error message without input)
    elsif (defined $input_field->{'error'} and defined $input_field->{'error'}->{'id'}) {
        my $error_id = $input_field->{'error'}->{'id'};
        # Clear the error message
        $javascript = "var error_element_$error_id = clearInputErrorField('$error_id');";
    }

    return $javascript;
}

########################################################################
# Usage      : $form_validation_obj->set_server_side_checks($custom_server_side_sub_ref);
# Purpose    : Set custom server side validation
# Returns    : none
# Parameters : $server_side_check_sub_ref: sub ref
# Comments   : Public
# See Also   : n / a
########################################################################
sub set_server_side_checks {
    my $self                      = shift;
    my $server_side_check_sub_ref = shift;
    $custom_server_side_check_of{ident $self} = $server_side_check_sub_ref;
    return;
}

########################################################################
# Usage      : $self->_validate_field({
#                'validation'    => $input_field->{'validation'},
#                'input_element' => $input_field->{'input'},
#              });
# Purpose    : Server side validation base on type of validation
# Returns    : none
# Parameters : $arg_ref:
#              {
#                'validation': ARRAY ref to $input_field->{'validation'}
#                'input_element': HASH ref to input element
#              }
# Comments   : Private
# See Also   : validate()
########################################################################
sub _validate_field {
    my $self    = shift;
    my $arg_ref = shift;

    my @validations   = @{$arg_ref->{'validation'}};
    my $input_element = $arg_ref->{'input_element'};
    my $input_element_id;
    my $field_value;

    foreach my $validation (@validations) {
        if ($validation->{'type'} and $validation->{'type'} =~ /(?:regexp|min_amount|max_amount)/) {

					# The input_element must be an array. so if validation no 'id', then we use the first element's id
					# because the array should be just one element.
						$input_element_id = $validation->{id} || $input_element->[0]{id};

            # Check with whitespace trimmed from both ends to make sure that it's reasonable.
            $field_value = trim($self->get_field_value($input_element_id));

            if ($validation->{'type'} and $validation->{'type'} eq 'regexp') {
                my $regexp = ($validation->{'case_insensitive'}) ? qr{$validation->{'regexp'}}i : qr{$validation->{'regexp'}};
                if ($validation->{'error_if_true'}) {
                    if ($field_value =~ $regexp) {
                        $self->set_field_error_message($input_element_id, $validation->{'err_msg'});
                        return 0;
                    }
                } else {
                    if ($field_value !~ $regexp) {
                        $self->set_field_error_message($input_element_id, $validation->{'err_msg'});
                        return 0;
                    }
                }
            }
            # Min amount checking
            elsif ($validation->{'type'} and $validation->{'type'} eq 'min_amount') {
                if ($field_value < $validation->{'amount'}) {
                    $self->set_field_error_message($input_element_id, $validation->{'err_msg'});
                    return 0;
                }
            }
            # Max amount checking
            elsif ($validation->{'type'} and $validation->{'type'} eq 'max_amount') {
                if ($field_value > $validation->{'amount'}) {
                    $self->set_field_error_message($input_element_id, $validation->{'err_msg'});
                    return 0;
                }
            }
        }
    }
    return 1;
}


sub _encode_text{

    my $text = shift;

    return unless ($text);

    # javascript cant load html entities
    $text = Encode::encode("UTF-8", HTML::Entities::decode_entities($text));
    $text = URI::Escape::uri_escape($text);
    $text =~ s/(['"\\])/\\$1/g;

    return $text;
}


1;



=head1 NAME

HTML::FormBuilder::Validation - An extention of the Form object, to allow for javascript-side validation of inputs
and also server-side validation after the form is POSTed

=head1 SYNOPSIS

First, create the Form object. The keys in the HASH reference is the attributes
of the form.

 	# Form attributes require to create new form object
	my $form_attributes =
	{
		'name'     => 'name_test_form',
		'id'       => 'id_test_form',
		'method'   => 'post',
		'action'   => "http://www.domain.com/contact.cgi",
		'class'    => 'formObject',
	};
	my $form_obj = new HTML::FormBuilder::Validation($form_attributes);

	my $fieldset_index = $form_obj->add_fieldset({});


=head2 Create the input fields with validation

This is quite similar to creating input field in Form object. Likewise you can
add validation to HASH reference as the attribute of input field.

Below you can see the sample included four types of validation:

1. regexp: Just write the reqular expression that should be apply to the value

2. min_amount: Needs both type=min_amount and also minimum amount that declared
in amount

3. max_amount: Just like min_amount

4. custom: Just the javascript function call with parameters should be given to.
It only specifies client side validation.

  	my $input_field_amount =
	{
		'label' =>
		{
			'text'     => 'Amount',
			'for'      => 'amount',
			'optional' => '0',
		},
		'input' =>
		{
			'type'      => 'text',
			'id'        => 'amount',
			'name'      => 'amount',
			'maxlength' => 40,
			'value'     => '',
		},
		'error' =>
		{
			'text' => '',
			'id'    => 'error_amount',
			'class' => 'errorfield',
		},
		'validation' =>
		[
			{
				'type'    => 'regexp',
				'regexp'  => '\w+',
				'err_msg' => 'Not empty',
			},
			{
				'type'    => 'regexp',
				'regexp'  => '\d+',
				'err_msg' => 'Must be digit',
			},
			{
				'type'    => 'min_amount',
				'amount'  => 50,
				'err_msg' => 'Too little',
			},
			{
				'type'    => 'max_amount',
				'amount'  => 500,
				'err_msg' => 'Too much',
			},
 			{
 				'type' => 'custom',
 				'function' => 'custom_amount_validation()',
 				'err_msg' => 'It is not good',
 			},
		],
	};

Below is another example with two different fields. In this matter we need to
indicate the id of each field in validation attributes.

	my $select_curr =
	{
		'id'      => 'select_text_curr',
		'name'    => 'select_text_curr',
		'type'    => 'select',
		'options' => '<option value=""></option><option value="USD">USD</option><option value="EUR">EUR</option>',
	};
	my $input_amount =
	{
		'id'    => 'select_text_amount',
		'name'  => 'select_text_amount',
		'type'  => 'text',
		'value' => ''
	};
	my $input_field_select_text =
	{
		'label' =>
		{
			'text'     => 'select_text',
			'for'      => 'select_text',
		},
		'input' => [ $select_curr, $input_amount ],
		'error' =>
		{
			'text'  => '',
			'id'    => 'error_select_text',
			'class' => 'errorfield',
		},
		'validation' =>
		[
			{
				'type' => 'regexp',
				'id'   => 'select_text_curr',
				'regexp'  => '\w+',
				'err_msg' => 'Must be select',
			},
			{
				'type' => 'regexp',
				'id'   => 'select_text_amount',
				'regexp'  => '\d+',
				'err_msg' => 'Must be digits',
			},
			{
				'type' => 'min_amount',
				'id'   => 'select_text_amount',
				'amount'  => 50,
				'err_msg' => 'Too little',
			},
		],
	};

	my $general_error_field =
	{
		'error' =>
		{
			'text' => '',
			'id' => 'error_general',
			'class' => 'errorfield'
		},
	};

=head2 Adding input fields to form object

Here is just add fields to the form object like before.

	$form_obj->add_field($fieldset_index, $general_error_field);
	$form_obj->add_field($fieldset_index, $input_field_amount);
	$form_obj->add_field($fieldset_index, $input_field_select_text);

=head2 Custom javascript validation

Custom javascript validation should be defined and assigned to the form object.
Note that, the name and parameters should be the same as the way you indicate
function call in validation attributes.

You can see a sample below:

	my $custom_javascript = qq~
		function custom_amount_validation()
		{
			var input_amount = document.getElementById('amount');
			if (input_amount.value == 100)
			{
				return false;
			}
			return true;
		}~;

=head2 Custom server side validation

The custom server side validation is quite similar to javascript. A reference to
a subrotine should be pass to form object.

	my $custom_server_side_sub_ref = sub {
		if ($form_obj->get_field_value('name') eq 'felix')
		{
			$form_obj->set_field_error_message('name', 'felix is not allow to use this page');
			$form_obj->set_field_error_message('error_general', 'There is an error !!!');
		}
	};

	$form_obj->set_server_side_checks($custom_server_side_sub_ref);

=head2 Use form object in cgi files

Somewhere in cgi files you can just print the result of build().

	print $form_obj->build();

In submit you need to fill form values, use set_input_fields(\%input) and pass
%input HASH and then show what ever you want in result of validation. Just like
Below:

	if (not $form_obj->validate())
	{
		print '<h1>Test Form</h1>';
		print $form_obj->build();
	}
	else
	{
		print '<h1>Success !!!</h1>';
	}

	code_exit();

=head1 AUTHOR

Felix Tan, E<lt>felix@regentmarkets.com<gt>

Omid Houshyar, E<lt>omid@regentmarkets.com<gt>

=head1 COPYRIGHT AND LICENSE

=cut
