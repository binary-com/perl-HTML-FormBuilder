#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::FailWarnings;
use Test::Exception;
use HTML::FormBuilder;
use HTML::FormBuilder::Select;

my $form_obj;

{
    $form_obj = create_form_object();

    # Test set_field_value and get_field_value
    $form_obj->set_field_value('amount', 100);
    Test::More::is($form_obj->get_field_value('amount'), 100, 'Test accessor of fields of form object. [set_field_value, get_field_value]');

    # Test set_field_value and get_field_value [before select]
    Test::More::is($form_obj->get_field_value('gender'),
        'male', 'Test accessor of fields of form object [Select - male]. [set_field_value, get_field_value]');

    # Test set_field_value and get_field_value
    $form_obj->set_field_value('gender', 'female');
    Test::More::is($form_obj->get_field_value('gender'),
        'female', 'Test accessor of fields of form object [Select - female]. [set_field_value, get_field_value]');

    # Test set_field_value and get_field_value
    $form_obj->set_field_value('select_text_curr', 'EUR');
    Test::More::is($form_obj->get_field_value('select_text_curr'),
        'EUR', 'Test accessor of array fields of form object [Select - EUR]. [set_field_value, get_field_value]');

    # Test set_field_value and get_field_value
    Test::More::is($form_obj->get_field_value('select_text_amount'),
        20, 'Test accessor of array fields of form object [text - 20(default value)]. [set_field_value, get_field_value]');
    # Test set_field_value and get_field_value
    $form_obj->set_field_value('select_text_amount', 50);
    Test::More::is($form_obj->get_field_value('select_text_amount'),
        50, 'Test accessor of array fields of form object [text - 50]. [set_field_value, get_field_value]');

    # Test set_field_value and get_field_value
    Test::More::is(
        $form_obj->get_field_value('Textarea'),
        'This is default value of textarea',
        'Test accessor of fields of form object [textarea - \'This is default value of textarea\'(default value)]. [set_field_value, get_field_value]'
    );
    # Test set_field_value and get_field_value
    $form_obj->set_field_value('Textarea', 'It should be changed now...');
    Test::More::is(
        $form_obj->get_field_value('Textarea'),
        'It should be changed now...',
        'Test accessor of fields of form object [text - \'It should be changed now...\']. [set_field_value, get_field_value]'
    );

    # Test set_field_value and get_field_value
    Test::More::is($form_obj->get_field_value('Password'),
        'pa$$w0rd', 'Test accessor of fields of form object [password - pa$$w0rd(default value)]. [set_field_value, get_field_value]');
    # Test set_field_value and get_field_value
    $form_obj->set_field_value('Password', 'Baghali');
    Test::More::is($form_obj->get_field_value('Password'),
        'Baghali', 'Test accessor of fields of form object [password - Baghali]. [set_field_value, get_field_value]');

    # Test set_field_value and get_field_value
    Test::More::is($form_obj->get_field_value('single_checkbox'),
        undef, 'Test accessor of fields of form object [single_checkbox - (Not checked)]. [set_field_value, get_field_value]');
    # Test set_field_value and get_field_value
    $form_obj->set_field_value('single_checkbox', 'SGLBOX');
    Test::More::is($form_obj->get_field_value('single_checkbox'),
        'SGLBOX', 'Test accessor of fields of form object [single_checkbox - SGLBOX]. [set_field_value, get_field_value]');

    # Test set_field_value and get_field_value
    Test::More::is($form_obj->get_field_value('checkbox1'),
        undef, 'Test accessor of fields of form object [checkbox1 - (Not checked)]. [set_field_value, get_field_value]');
    Test::More::is($form_obj->get_field_value('checkbox2'),
        undef, 'Test accessor of fields of form object [checkbox2 - (Not checked)]. [set_field_value, get_field_value]');
    # Test set_field_value and get_field_value
    $form_obj->set_field_value('checkbox1', 'BOX1');
    $form_obj->set_field_value('checkbox2', 'BOX2');
    Test::More::is($form_obj->get_field_value('checkbox1'),
        'BOX1', 'Test accessor of fields of form object [checkbox1 - BOX1]. [set_field_value, get_field_value]');
    Test::More::is($form_obj->get_field_value('checkbox2'),
        'BOX2', 'Test accessor of fields of form object [checkbox2 - BOX2]. [set_field_value, get_field_value]');

    # Test set_field_error_message
    $form_obj->set_field_error_message('amount', 'It is not good');
    Test::More::is(
        $form_obj->get_field_error_message('amount'),
        'It is not good',
        'Test accessor of fields of form object. [set_field_error_message, get_field_error_message]'
    );

    # Test set_field_error_message
    $form_obj->set_field_error_message('error_general', 'There is a general error.');
    Test::More::is(
        $form_obj->get_field_error_message('error_general'),
        'There is a general error.',
        'Test accessor of general error of form object . [set_field_error_message, get_field_error_message]'
    );

}

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
    Test::Exception::lives_ok { $form_obj = HTML::FormBuilder->new($form_attributes); } 'Create Form';

    # Test object type
    Test::More::isa_ok($form_obj, 'HTML::FormBuilder');

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

sub check_existance_on_builded_html {
    my $arg_ref = shift;

    my $form_object = $arg_ref->{'form_obj'};
    my $reg_exp     = $arg_ref->{'reg_exp'};

    return $form_object->build() =~ /$reg_exp/;

}

done_testing;
