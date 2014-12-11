use strict;
use warnings;

use HTML::FormBuilder;
use HTML::FormBuilder::Select;

my $obj = create_form_object();
my $html = $obj->build();
print $html;


sub create_form_object {
    my $form_obj;

    # Form attributes require to create new form object
    my $form_attributes = {
        'name'   => 'name_test_form',
        'id'     => 'id_test_form',
        'method' => 'post',
        'action' => 'http://localhost/some/where/test.cgi',
        'class'  => 'formObject',
    };

    # Create new form object
    $form_obj = HTML::FormBuilder->new($form_attributes);

    my $fieldset_index = $form_obj->add_fieldset({});

    my $input_field_amount = {
        'label' => {
            'text'     => 'Amount',
            'for'      => 'amount',
            'optional' => '0',
        },
        'input' => {
            'type'      => 'text',
            'id'        => 'amount',
            'name'      => 'amount',
            'maxlength' => 40,
            'value'     => '',
        },
        'error' => {
            'text'  => '',
            'id'    => 'error_amount',
            'class' => 'errorfield',
        },
        'validation' => [{
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
                'type'     => 'custom',
                'function' => 'custom_amount_validation()',
                'err_msg'  => 'It is not good',
            }
        ],
    };

    my $input_field_gender = {
        'label' => {
            'text'     => 'gender',
            'for'      => 'gender',
            'optional' => '0',
        },
        'input' => HTML::FormBuilder::Select->new(
            'id'      => 'gender',
            'name'    => 'gender',
            'options' => [{value => 'male'}, {value => 'female'}],
            'values'  => ['male'],
        ),
        'error' => {
            'text'  => '',
            'id'    => 'error_gender',
            'class' => 'errorfield',
        },
    };

    my $select_curr = HTML::FormBuilder::Select->new(
        'id'      => 'select_text_curr',
        'name'    => 'select_text_curr',
        'options' => [{value => 'USD'}, {value => "EUR"}],
    );
    my $input_amount = {
        'id'    => 'select_text_amount',
        'name'  => 'select_text_amount',
        'type'  => 'text',
        'value' => '20'
    };
    my $input_field_select_text = {
        'label' => {
            'text'     => 'select_text',
            'for'      => 'select_text',
            'optional' => '0',
        },
        'input' => [$select_curr, $input_amount],
        'error' => {
            'text'  => '',
            'id'    => 'error_select_text',
            'class' => 'errorfield',
        },
    };

    my $input_field_textarea = {
        'label' => {
            'text'     => 'Textarea',
            'for'      => 'Textarea',
            'optional' => '0',
        },
        'input' => {
            'type'  => 'textarea',
            'id'    => 'Textarea',
            'name'  => 'Textarea',
            'value' => 'This is default value of textarea',
        },
        'error' => {
            'text'  => '',
            'id'    => 'error_Textarea',
            'class' => 'errorfield',
        },
    };

    my $input_field_password = {
        'label' => {
            'text'     => 'Password',
            'for'      => 'Password',
            'optional' => '0',
        },
        'input' => {
            'type'  => 'password',
            'id'    => 'Password',
            'name'  => 'Password',
            'value' => 'pa$$w0rd',
        },
        'error' => {
            'text'  => '',
            'id'    => 'error_Password',
            'class' => 'errorfield',
        },
    };

    my $input_field_single_checkbox = {
        'label' => {
            'text'     => 'Single Checkbox',
            'for'      => 'single_checkbox',
            'optional' => '0',
        },
        'input' => {
            'type'  => 'checkbox',
            'id'    => 'single_checkbox',
            'name'  => 'single_checkbox',
            'value' => 'SGLBOX',
        },
    };

    my $input_field_array_checkbox = {
        'label' => {
            'text'     => 'Single Checkbox',
            'for'      => 'single_checkbox',
            'optional' => '0',
        },
        'input' => [{
                'type'  => 'checkbox',
                'id'    => 'checkbox1',
                'name'  => 'checkbox1',
                'value' => 'BOX1',
            },
            {
                'type'  => 'checkbox',
                'id'    => 'checkbox2',
                'name'  => 'checkbox2',
                'value' => 'BOX2',
            },
        ],
    };

    my $general_error_message_field = {
        'error' => {
            'text'  => '',
            'id'    => 'error_general',
            'class' => 'errorfield',
        },
    };

    $form_obj->add_field($fieldset_index, $input_field_amount);
    $form_obj->add_field($fieldset_index, $input_field_gender);
    $form_obj->add_field($fieldset_index, $input_field_select_text);
    $form_obj->add_field($fieldset_index, $input_field_textarea);
    $form_obj->add_field($fieldset_index, $input_field_password);
    $form_obj->add_field($fieldset_index, $input_field_single_checkbox);
    $form_obj->add_field($fieldset_index, $input_field_array_checkbox);
    $form_obj->add_field($fieldset_index, $general_error_message_field);

    return $form_obj;
}
