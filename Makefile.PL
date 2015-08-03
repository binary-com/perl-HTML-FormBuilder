use 5.014;
use strict;
use warnings;
use ExtUtils::MakeMaker;


WriteMakefile(
    NAME                => "HTML::FormBuilder",
    AUTHOR              => "Chylli L<chylli\@binary.com>",
    VERSION_FROM        => "lib/HTML/FormBuilder.pm",
    ABSTRACT_FROM       => "lib/HTML/FormBuilder.pm",
    LICENSE             => "apache_2",
    MIN_PERL_VERSION    => "5.014",
    CONFIGURE_REQUIRES  => {
        "ExtUtils::MakeMaker" => 0
    },
    BUILD_REQUIRES => {
        "Test::Exception" => 0,
        "Test::FailWarnings" => 0,
        "Test::More" => "0.96",
        "Test::Perl::Critic" => 0
    },
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
    dist    => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
    clean   => { FILES => 'HTML-FormBuilder-*' },
    test    => {
        "TESTS" => "t/*.t t/formbuilder/*.t"
    }
);

