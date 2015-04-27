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
my $prid = $query->param('prid');
my $lid = $query->param('lid');
my $reason = $query->param('reason');
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

my $SQL = "delete from patron_request_sources where prid=?";
my $rv = $dbh->do($SQL, undef, $prid );

$SQL = "insert into patron_requests_declined (prid, title, author, pid, lid, medium, reason, message) select prid, title, author, pid, lid, medium, ?, ? from patron_request where prid=? and lid=?";
my $rows = $dbh->do($SQL, undef, $reason, $message, $prid, $lid );

$SQL = "delete from patron_request where prid=? and lid=?";
$rows = $dbh->do($SQL, undef, $prid, $lid );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => ($rows == undef) ? 0 : 1 } );
