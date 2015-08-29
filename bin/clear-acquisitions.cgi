#!/usr/bin/perl

use CGI;
use CGI::Session;
use DBI;
use JSON;

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

$dbh->do("delete from acquisitions where oid=?", undef, $oid );

$dbh->disconnect;
print "Content-Type:application/json\n\n" . to_json( { success => 1 } );
