use strict;
use warnings;

use 5.008;

use ExtUtils::MakeMaker;
WriteMakefile
    (
     NAME => 'Biblio::SIP2::Client',
     VERSION_FROM => 'lib/Biblio/SIP2/Client.pm',
     PREREQ_PM => {
	 'IO::Socket' => '0',
	 'Carp' => '0',
	 'Scalar::Util' => '0',
     },
     BUILD_REQUIRES => {
	 'Test::More' => '0.47'
     },
    );
