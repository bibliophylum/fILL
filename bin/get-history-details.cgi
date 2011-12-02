#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $reqid = $query->param('reqid');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

# sql to get this library's borrowing history
my $SQL = "select rh.ts, f.name as from, rh.msg_from, t.name as to, rh.msg_to, rh.status, rh.message from requests_history rh left join libraries f on rh.msg_from = f.lid left join libraries t on rh.msg_to = t.lid where request_id=? order by ts";
my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $reqid );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { request_history => $aref });
