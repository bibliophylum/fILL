#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 2;

BEGIN {
    use_ok( 'Biblio::Authentication::Biblionet' ) || print "Bail out!\n";
    use_ok( 'Biblio::Authentication::L4U' ) || print "Bail out!\n";
}

diag( "Testing Biblio::Authentication::Biblionet $Biblio::Authentication::Biblionet::VERSION, Perl $], $^X" );
diag( "Testing Biblio::Authentication::L4U $Biblio::Authentication::L4U::VERSION, Perl $], $^X" );
