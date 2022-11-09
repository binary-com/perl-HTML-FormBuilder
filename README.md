# NAME

HTML::FormBuilder - A Multi-part HTML form

# SYNOPSIS

    #define a form
    my $form = HTML::FormBuilder->new(
        data =>{id    => 'formid',
                class => 'formclass'},
        classes => {row => 'rowdev'})

    #create fieldset
    my $fieldset = $form->add_fieldset({id => 'fieldset1});

    #add field
    $fieldset->add_field({input => {name => 'name', type => 'text', value => 'Join'}});

    #set field value
    $form->set_field_value('name', 'Omid');

    #output the form
    print $form->build;

# DESCRIPTION

Object-oriented module for displaying an HTML form.

## Overview of Form's HTML structure

The root of the structure is the &lt;form> element and follow by multiple &lt;fieldset> elements.

In each &lt;fieldset>, you can create rows which contain label, different input types, error message and comment &lt;p> element.

Please refer to ["A full sample result"](#a-full-sample-result)

# Attributes

## data

The form attributes. It should be a hashref.

## classes

The form classes. It should be a hashref. You can customize the form's layout by the classes.
The class names used are:

      fieldset_group
      no_stack_field_parent
      row_padding
      fieldset_footer
      comment
      row
      extra_tooltip_container
      backbutton
      required_asterisk
      inputtrailing
      label_column
      input_column
      hide_mobile

## localize

The subroutine ref which can be called when translate something like 'Confirm'. The default value is no translating.

## fieldsets

The fieldsets the form have.

# Methods

## new

    my $form = HTML::FormBuilder->new(
        data =>{id    => 'formid',
                class => 'formclass'},
        classes => {row => 'rowdev'})

The id is required for the form.

## add\_fieldset

    my $fieldset = $form->add_fieldset({id => 'fieldset1});

the parameter is the fieldset attributes.
It will return the fielset object.

## add\_field

      $form->add_field(0, {input => {name => 'name', type => 'text', value => 'Join'}});

The parameter is the fieldset index to which you want to add the field and the field attributes.

## build

      print $form->build;

the data in the $form will be changed when build the form. So you cannot get the same result if you call build twice.

## BUILDARGS

## build\_confirmation\_button\_with\_all\_inputs\_hidden

## csrftoken

## get\_field\_error\_message

## get\_field\_value

## set\_field\_error\_message

## set\_field\_value

# Cookbook

## a full sample

    # Before create a form, create a classes hash for the form
    my $classes = {comment => 'comment', 'input_column' => 'column'};
    # And maybe you need a localize function to translate something
    my $localize = sub {i18n(shift)};

    # First, create the Form object. The keys in the HASH reference is the attributes of the form
    $form_attributes => {'id'     => 'id_of_the_form',
                         'name'   => 'name_of_the_form',
                         'method' => 'post', # or get
                         'action' => 'page_to_submit',
                         'header' => 'My Form',
                         'localize' => $localize,
                         'classes'  => $classes,
                         };   #header of the form
    my $form = HTML::FormBuilder->new(data => $form_attributes, classes => $classes, localize => $localize);

    #Then create fieldset, the form is allow to have more than 1 fieldset
    #The keys in the HASH reference is the attributes of the fieldset

    $fieldset_attributes => {'id'      => 'id_of_the_fieldset',
                             'name'    => 'name_of_the_fieldset',
                             'class'   => 'myclass',
                             'header'  => 'User details',      #header of the fieldset
                             'comment' => 'please fill in',    #message at the top of the fieldset
                             'footer'  => '* - required',};    #message at the bottom of the fieldset
    };
    my $fieldset = $form->add_fieldset($fieldset_attributes);

    ####################################
    #Create the input fields.
    ####################################
    #When creating an input fields, there are 4 supported keys.
    #The keys are label, input, error, comment
    #  Label define the title of the input field
    #  Input define and create the actual input type
    #     In input fields, you can defined a key 'heading', which create a text before the input is displayed,
    #     however, if the input type is radio the text is behind the radio box
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
        my @options;
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
    $fieldset->add_field($input_text);
    $fieldset->add_field($input_select);
    $fieldset->add_field($input_submit_button);

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

## A full sample result

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

## How to create a form with validation

Please refer to <HTML::FormBuilder::Validation>

## CROSS SITE REQUEST FORGERY PROTECTION

read <HTML::FormBuilder::Validation> for more details

# AUTHOR

Chylli [mailto:chylli@binary.com](mailto:chylli@binary.com)

# CONTRIBUTOR

Fayland Lam [mailto:fayland@binary.com](mailto:fayland@binary.com)

Tee Shuwn Yuan [mailto:shuwnyuan@binary.com](mailto:shuwnyuan@binary.com)

# COPYRIGHT AND LICENSE
