#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

# sql to get items shipped to this library, which this library has not yet marked as received
my $SQL = "select r.id, r.title, r.author, r.patron_barcode, ra.ts, l.name as from, l.library, ra.msg_from, ra.message from request r left join requests_active ra on (r.id = ra.request_id) left join libraries l on ra.msg_from = l.lid where ra.msg_to=? and ra.status='Shipped' and ra.request_id not in (select request_id from requests_active where msg_from=? and status='Received') order by r.author, r.title";

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

print "Content-Type:application/json\n\n" . to_json( { receiving => $aref } );
