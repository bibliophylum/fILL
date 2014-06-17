#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

my $SQL="select
 l.library,
 l.name,
 s.ts_start::date,
 s.ts_end::date,
 r.title,
 r.callno,
 r.barcode,
 s.circs 
from
 rotations r
 inner join rotations_stats s on s.barcode=r.barcode
 left join libraries l on l.lid=s.lid 
group by
 l.library,
 l.name,
 s.ts_start::date,
 s.ts_end::date,
 r.title,
 r.callno,
 r.barcode,
 s.circs 
order by
 l.library,
 l.name,
 s.ts_start::date,
 s.ts_end::date,
 r.title,
 r.barcode
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

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} } );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { rotations_item_circ_counts => $aref } );
