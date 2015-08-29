use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Biblio::Authentication',
    AUTHOR           => q{David Christensen <David.A.Christensen@gmail.com>},
    VERSION_FROM     => 'lib/Biblio/Authentication.pm',
    ABSTRACT_FROM    => 'lib/Biblio/Authentication.pm',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
	'Biblio::SIP2::Client' => 0.01,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Biblio-Authentication-*' },
);
