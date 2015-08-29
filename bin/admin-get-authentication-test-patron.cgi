#!/usr/bin/perl

use CGI;
use CGI::Session;
use DBI;
use JSON;
#use Data::Dumper;

my $q = new CGI;
my $session = CGI::Session->load(undef, $q, {Directory=>"/tmp"});
if (($session->is_expired) || ($session->is_empty)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
    exit;
}

my $oid = $q->param('oid');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $SQL = "select o.oid, o.org_name, o.patron_authentication_method, tp.barcode, tp.pin, tp.last_tested, tp.test_result from library_test_patron tp left join org o on o.oid=tp.oid where tp.oid=?";

my $href = $dbh->selectrow_hashref($SQL,{},$oid);

$dbh->disconnect;
    
print "Content-Type:application/json\n\n" . to_json( { tp => $href });
