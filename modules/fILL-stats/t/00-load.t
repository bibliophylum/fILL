#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'fILL::stats' ) || print "Bail out!\n";
}

diag( "Testing fILL::stats $fILL::stats::VERSION, Perl $], $^X" );
