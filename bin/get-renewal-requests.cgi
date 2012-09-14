#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

# sql to get renewal requests to this library from borrowers
my $SQL = "select r.id, r.title, r.author, date_trunc('second',ra.ts) as ts, l.name as from, l.library, ra.msg_from, s.call_number from request r left join requests_active ra on (r.id = ra.request_id) left join sources s on (s.request_id = ra.request_id and s.lid = ra.msg_to) left join libraries l on ra.msg_from = l.lid where ra.msg_to=? and ra.status='Renew' and ra.request_id not in (select request_id from requests_active where msg_from=? and status like 'Renew-Answer%') order by s.call_number, r.author, r.title";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid, $lid );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { renewRequests => $aref } );
