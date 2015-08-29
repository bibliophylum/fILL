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
my $msg_from = $query->param('oid');
my $reqid = $query->param('reqid');
my $msg_to = $query->param('msg_to');
my $status = $query->param('status');
my $message = $query->param('message');

# sql to add to the request conversation
my $SQL = "insert into requests_active (request_id, msg_from, msg_to, status, message) values (?,?,?,?,?)";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $retval = $dbh->do( $SQL, undef, $reqid, $msg_from, $msg_to, $status, $message );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
