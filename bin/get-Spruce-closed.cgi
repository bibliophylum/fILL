#!/usr/bin/perl

use CGI;
use CGI::Session;
use DBI;
use JSON;


my $query = new CGI;
my $session;
if (($ENV{GATEWAY_INTERFACE}) && ($ENV{GATEWAY_INTERFACE} =~ /CGI/)) {  # only worry about session if we're a cgi

    $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
    if (($session->is_expired) || ($session->is_empty)) {
	print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
	exit;
    }
}
my $oid = $query->param('oid');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
                       "mapapp",
                       "maplin3db",
                       {AutoCommit => 1, 
                        RaiseError => 1, 
                        PrintError => 0,
                       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

#my $aref = $dbh->selectall_arrayref("select symbol from spruce_closed_list", { Slice => {} });
my $aref = $dbh->selectall_arrayref("select z3950_location from org o left join spruce_closed_list scl on o.symbol = scl.symbol", { Slice => {} });
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { closed => $aref } );
