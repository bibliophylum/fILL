#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

# sql to get this library's borrowing history
#my $SQL = "select rc.id, rc.title, rc.author, rc.patron_barcode, rh.ts from request_closed rc left join requests_history rh on rc.id=rh.request_id where rc.requester=? and rh.status='ILL-Request' order by ts desc";

my $SQL="select rc.id, rc.title, rc.author, rc.patron_barcode, rh.ts, rh.status, rh.message from request_closed rc left join requests_history rh on (rc.id=rh.request_id and rh.msg_from=?) where rc.requester=? and rh.ts in (select max(ts) from requests_history where msg_from=? group by request_id) order by ts";
my $aref_borr = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid, $lid, $lid );

# sql to get this library's lending history
#$SQL = "select rc.id, rc.title, rc.author, rc.requester, rh.ts from request_closed rc left join requests_history rh on rc.id=rh.request_id where rh.msg_from=? and rh.status like 'ILL-Answer%' order by rh.ts desc";

my $SQL="select rc.id, rc.title, rc.author, rc.requester, rh.ts, rh.status, rh.message from request_closed rc left join requests_history rh on (rc.id=rh.request_id and rh.msg_from=?) where rc.requester<>? and rh.ts in (select max(ts) from requests_history where msg_from=? group by request_id) order by ts";
my $aref_lend = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid, $lid, $lid );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { history => { borrowing => $aref_borr, 
								    lending => $aref_lend 
						       }});
