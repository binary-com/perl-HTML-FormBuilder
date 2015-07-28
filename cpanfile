requires 'perl', '5.008005';

# requires 'Some::Module', 'VERSION';
requires 'Carp';
requires 'Moo';
requires 'namespace::clean';
requires 'Scalar::Util';
requires 'Class::Std::Utils';
requires 'Encode';
requires 'URI::Escape';
requires 'HTML::Entities';

on test => sub {
    requires 'Test::More', '0.96';
    requires 'Test::Exception';
    requires 'Test::FailWarnings';
    requires 'Test::Perl::Critic';
};
