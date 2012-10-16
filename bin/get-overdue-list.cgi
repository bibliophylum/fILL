#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

#  0    1    2     3     4    5     6     7      8
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $today = sprintf("%4d-%02d-%02d",($year+1900),($mon+1),$mday);

# sql to get items this library has borrowed, which are overdue
my $SQL = "select r.id, r.title, r.author, l.name as from, l.library, ra.msg_from, date_trunc('second',ra.ts) as ts, substring(message from 'due (.*)') as due_date, r.patron_barcode from request r left join requests_active ra on (r.id = ra.request_id) left join libraries l on ra.msg_from = l.lid where ra.msg_to=? and ra.status='Shipped' and ra.request_id not in (select request_id from requests_active where msg_from=? and status='Returned') and ra.request_id not in (select request_id from requests_active where msg_to=? and status='Renew-Answer|Ok') and substring(message from 'due (.*)') < ? order by r.patron_barcode, r.title";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid, $lid, $lid, $today );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { overdue => $aref } );
