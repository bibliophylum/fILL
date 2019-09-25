#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 8;

BEGIN {
    use_ok( 'Biblio::Authentication::Dummy' ) || print "Bail out!\n";
    use_ok( 'Biblio::Authentication::SIP2' ) || print "Bail out!\n";
    use_ok( 'Biblio::Authentication::Biblionet' ) || print "Bail out!\n";
    use_ok( 'Biblio::Authentication::FollettDestiny' ) || print "Bail out!\n";
    use_ok( 'Biblio::Authentication::L4U' ) || print "Bail out!\n";
    use_ok( 'Biblio::Authentication::L4U_5_3' ) || print "Bail out!\n";
    use_ok( 'Biblio::Authentication::L4U_API' ) || print "Bail out!\n";
    use_ok( 'Biblio::Authentication::TLC' ) || print "Bail out!\n";
}

diag( "Testing Biblio::Authentication::Dummy $Biblio::Authentication::SIP2::VERSION, Perl $], $^X" );
diag( "Testing Biblio::Authentication::SIP2 $Biblio::Authentication::SIP2::VERSION, Perl $], $^X" );
diag( "Testing Biblio::Authentication::Biblionet $Biblio::Authentication::Biblionet::VERSION, Perl $], $^X" );
diag( "Testing Biblio::Authentication::FollettDestingy $Biblio::Authentication::FollettDestiny::VERSION, Perl $], $^X" );
diag( "Testing Biblio::Authentication::L4U $Biblio::Authentication::L4U::VERSION, Perl $], $^X" );
diag( "Testing Biblio::Authentication::L4U $Biblio::Authentication::L4U_5_3::VERSION, Perl $], $^X" );
diag( "Testing Biblio::Authentication::L4U_API $Biblio::Authentication::L4U_API::VERSION, Perl $], $^X" );
diag( "Testing Biblio::Authentication::TLC $Biblio::Authentication::TLC::VERSION, Perl $], $^X" );
