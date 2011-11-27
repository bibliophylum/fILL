#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

# sql to get this library's borrowing history
my $SQL = "select rc.id, rc.title, rc.author, rc.patron_barcode, rh.ts from request_closed rc left join requests_history rh on rc.id=rh.request_id where rc.requester=? and rh.status='ILL-Request' order by ts desc";

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

print "Content-Type:application/json\n\n" . to_json( { history => $aref } );
