use strict;
use warnings;
     
use Test::More tests => 2;
     
use_ok 'Biblio::SIP2::Comm';
     
#is Math::Calc::add(19, 23), 42, 'good answer';

my $obj = Biblio::SIP2::Comm->new;
isa_ok( $obj, 'Biblio::SIP2::Comm' );
