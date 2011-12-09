#!/usr/bin/perl

# Note: this gets a list of items currently borrowed that *can be* renewed, not a list of items that *have been* renewed!

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

# sql to get items shipped to this library which have not yet been returned
#my $SQL = "select r.id, r.title, r.author, ra.ts, l.name as to, ra.msg_to from request r left join requests_active ra on (r.id = ra.request_id) left join libraries l on ra.msg_to = l.lid where ra.msg_from=? and ra.status='Received' and ra.request_id not in (select request_id from requests_active where msg_from=? and status='Returned') order by r.author, r.title";

my $SQL = "select r.id, r.title, r.author, r.patron_barcode, ra.request_id, ra.ts, ra.msg_from, ra.msg_to, l.name as to, ra.status, ra.message from request r left join requests_active ra on (r.id = ra.request_id) left join libraries l on ra.msg_to = l.lid where ra.ts=(select max(ts) from requests_active ra2 where ra.request_id = ra2.request_id) and ra.request_id in (select request_id from requests_active where msg_from=? and status='Received' and request_id not in (select request_id from requests_active where status='Returned'))";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { renewals => $aref } );
