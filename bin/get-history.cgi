#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');
my $start = $query->param('start');
my $end = $query->param('end');

#print STDERR "get-history.cgi, start [" . $start . "]\n";
#print STDERR "get-history.cgi, end   [" . $end . "]\n";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

# sql to get this library's borrowing history
my $SQL="select rc.id, rc.title, rc.author, rc.patron_barcode, date_trunc('second',rh.ts) as ts, rh.status, rh.message from request_closed rc left join requests_history rh on (rc.id=rh.request_id and rh.msg_from=?) where rc.requester=? and rh.ts in (select max(ts) from requests_history where msg_from=? group by request_id) and rh.ts >= ? and rh.ts < ? order by ts";
my $aref_borr = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid, $lid, $lid, $start, $end );

# sql to get this library's lending history
my $SQL="select rc.id, rc.title, rc.author, l.name as requested_by, date_trunc('second',rh.ts) as ts, rh.status, rh.message from request_closed rc left join requests_history rh on (rc.id=rh.request_id and rh.msg_from=?) left join libraries l on rc.requester = l.lid where rc.requester<>? and rh.ts in (select max(ts) from requests_history where msg_from=? group by request_id) and rh.ts >= ? and rh.ts < ? order by ts";
my $aref_lend = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid, $lid, $lid, $start, $end );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { history => { borrowing => $aref_borr, 
								    lending => $aref_lend 
						       }});
