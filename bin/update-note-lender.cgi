#!/usr/bin/perl

use CGI;
use CGI::Session;
use DBI;
use JSON;
use Data::Dumper;

my $query = new CGI;
#my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
#if (($session->is_expired) || ($session->is_empty)) {
#    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
#    exit;
#}

my $note = scalar $query->param('value');
my $reqid = scalar $query->param('reqid');
$reqid = substr( $reqid, 3 );  # lose the leading "req"
my $private_to = scalar $query->param('private_to');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $retval;
if ($note) {
    my $aref = $dbh->selectrow_arrayref("select count(*) from internal_note where request_id=? and private_to=?", undef, $reqid, $private_to);
    if ($aref && $aref->[0]) {
	$retval = $dbh->do( "update internal_note set note=? where request_id=? and private_to=?", undef, $note, $reqid, $private_to );
    } else {
	$retval = $dbh->do( "insert into internal_note (request_id, private_to, note) values (?,?,?)", undef, $reqid, $private_to, $note);
    }
} else {
    # passed an empty note, so delete if it exists
    $retval = $dbh->do( "delete from internal_note where request_id=? and private_to=?", undef, $reqid, $private_to );
}

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval, data => $note, reqid => $reqid } );
