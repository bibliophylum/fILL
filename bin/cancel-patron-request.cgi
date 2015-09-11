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
my $prid = $q->param('prid');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

# check if this request still exists in the patron_request table
# (it won't if the librarian has handled it already)
my $matching = $dbh->selectall_arrayref(
    "select prid from patron_request where prid=?",
    undef,
    $prid
    ); 
unless (@$matching) {
    $dbh->disconnect;
    print "Content-Type:application/json\n\n" . to_json( { success => 0 } );
    exit;
}

$dbh->do("delete from patron_request_sources where prid=?", undef, $prid );
$dbh->do("delete from patron_request where prid=?", undef, $prid );

$dbh->disconnect;
print "Content-Type:application/json\n\n" . to_json( { success => 1 } );
