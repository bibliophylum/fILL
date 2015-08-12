#!/usr/bin/perl
use strict;
use warnings;

use CGI;
use CGI::Session;
use DBI;
use JSON;
use Data::Dumper;

my $query = new CGI;
my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
if (($session->is_expired) || ($session->is_empty)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
    exit;
}

my $oid = $query->param('oid');
my $barcode = $query->param('barcode');
my $pin = $query->param('pin');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

# Does it exist already?
my $href = $dbh->selectrow_hashref("select oid from library_test_patron where oid=?",undef,$oid);
my $retval;
if (defined $href) {
    $retval = $dbh->do( "update library_test_patron set barcode=?, pin=? where oid=?", 
			undef, $barcode, $pin, $oid );
} else {
    $retval = $dbh->do( "insert into library_test_patron (oid,barcode,pin) values (?,?,?)", 
			undef, $oid, $barcode, $pin );
}

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
