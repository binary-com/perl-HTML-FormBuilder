requires 'perl', '5.008005';

# requires 'Some::Module', 'VERSION';
requires 'Carp';
requires 'Template';
requires 'Moo';
requires 'Class::Std::Utils';
requires 'Text::Trim';
requires 'Encode';
requires 'URI::Escape';
requires 'HTML::Entities';

on test => sub {
    requires 'Test::More', '0.96';
		requires 'Test::FailWarnings';
		requires 'Test::Exception';
};
