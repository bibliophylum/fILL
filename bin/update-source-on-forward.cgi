#!/usr/bin/perl

use CGI;
use CGI::Session;
use DBI;
use JSON;

my $query = new CGI;
my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
if (($session->is_expired) || ($session->is_empty)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
    exit;
}
my $reqid = $query->param('reqid');
my $hq = $query->param('hq');
my $branch = $query->param('branch');

# sql to change the source from hq to branch
my $SQL = "update sources set oid=? where request_id=? and oid=?";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $retval = $dbh->do( $SQL, undef, $branch, $reqid, $hq );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
