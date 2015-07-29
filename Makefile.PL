use 5.008005;
use strict;
use warnings;
use ExtUtils::MakeMaker;


my %WriteMakefileArgs = (
    NAME                  => "HTML::FormBuilder",
    VERSION_FROM          => "lib/HTML/FormBuilder.pm",
    ABSTRACT_FROM         => "lib/HTML/FormBuilder.pm",
    AUTHOR                => "Chylli L<chylli\@binary.com>",
    CONFIGURE_REQUIRES    => {
        "ExtUtils::MakeMaker" => 0
    },
    DISTNAME => "HTML-FormBuilder",
    EXE_FILES => [],
    LICENSE => "apache",
    MIN_PERL_VERSION => "5.008005",
    PREREQ_PM => {
        "Carp" => 0,
        "Class::Std::Utils" => 0,
        "Encode" => 0,
        "HTML::Entities" => 0,
        "Moo" => 0,
        "Scalar::Util" => 0,
        "URI::Escape" => 0,
        "namespace::clean" => 0
    },
    TEST_REQUIRES => {
        "Test::Exception" => 0,
        "Test::FailWarnings" => 0,
        "Test::More" => "0.96",
        "Test::Perl::Critic" => 0
    },
    test => {
        "TESTS" => "t/*.t t/formbuilder/*.t"
    }
);


my %FallbackPrereqs = (
    "Carp" => 0,
    "Class::Std::Utils" => 0,
    "Encode" => 0,
    "ExtUtils::MakeMaker" => 0,
    "HTML::Entities" => 0,
    "Moo" => 0,
    "Scalar::Util" => 0,
    "Test::Exception" => 0,
    "Test::FailWarnings" => 0,
    "Test::More" => "0.96",
    "Test::Perl::Critic" => 0,
    "URI::Escape" => 0,
    "namespace::clean" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
    delete $WriteMakefileArgs{TEST_REQUIRES};
    $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
    unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);

