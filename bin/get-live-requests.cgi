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

# sql to get this library's current borrowing
my $SQL="select r.id, r.title, r.author, r.patron_barcode, ra.ts, ra.status, ra.message from request r left join requests_active ra on (r.id=ra.request_id and ra.msg_from=?) where r.requester=? and ra.ts in (select max(ts) from requests_active where msg_from=? group by request_id) order by ts";
my $aref_borr = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid, $lid, $lid );

# sql to get this library's current lending
my $SQL="select r.id, r.title, r.author, r.requester, ra.ts, ra.status, ra.message from request r left join requests_active ra on (r.id=ra.request_id and ra.msg_from=?) where r.requester<>? and ra.ts in (select max(ts) from requests_active where msg_from=? group by request_id) order by ts";
my $aref_lend = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid, $lid, $lid );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { active => { borrowing => $aref_borr, 
								    lending => $aref_lend 
						       }});
