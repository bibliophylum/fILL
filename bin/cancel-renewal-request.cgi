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
my $msg_from = $query->param('lid');
my $reqid = $query->param('reqid');
my $msg_to = $query->param('msg_to');
my $status = $query->param('status');
my $message = $query->param('message');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $retval = 0;
my $SQL = "select msg_from, msg_to, status from requests_active where request_id=? order by ts desc limit 1";
my ($from,$to,$status) = $dbh->selectrow_array($SQL,undef,$reqid);
if (($from == $msg_from) && ($to == $msg_to) && ($status eq 'Renew')) {
    $retval = $dbh->do("delete from requests_active where request_id=? and status='Renew'",undef,$reqid);
}

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
