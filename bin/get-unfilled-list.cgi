#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

# sql to get requests where another library has answered this library with "Unfilled"
my $SQL = "select r.id, r.title, r.author, r.patron_barcode, date_trunc('second',ra.ts) as ts, ra.msg_from, l.name as from, l.library, ra.status, ra.message, (select count(*) from sources s where r.group_id=s.group_id and tried=true) as tried, (select count(*) from sources s2 where r.group_id=s2.group_id) as sources from request r left join requests_active ra on (r.id = ra.request_id) left join libraries l on ra.msg_from = l.lid where ra.msg_to=? and ra.status like 'ILL-Answer|Unfilled%' and r.id not in (select request_id from requests_active where status='Message' and message='Requester closed the request.') and ra.ts = (select max(ts) from requests_active ra2 where ra2.request_id = ra.request_id) order by ra.ts";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
                       "mapapp",
                       "maplin3db",
                       {AutoCommit => 1, 
                        RaiseError => 1, 
                        PrintError => 0,
                       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { unfilled => $aref } );
