#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

my $SQL = "select 
 r.id,
 r.callno,
 r.title, 
 r.author,
 r.barcode,
 r.ts as timestamp,
 s.circs
from 
 rotations r
 left join rotations_stats s on (s.barcode=r.barcode and s.lid=r.current_library and s.ts_start=r.ts)
where 
  r.current_library=? 
";

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

print "Content-Type:application/json\n\n" . to_json( { rotation => $aref } );
