#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Biblio::Authentication::L4U' ) || print "Bail out!\n";
}

diag( "Testing Biblio::Authentication::L4U $Biblio::Authentication::L4U::VERSION, Perl $], $^X" );
