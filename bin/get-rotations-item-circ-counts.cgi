#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

my $SQL="select
 r.title,
 r.callno,
 r.barcode,
 l.library,
 l.name,
 s.circs 
from
 rotations r
 inner join rotations_stats s on s.barcode=r.barcode
 left join libraries l on l.lid=s.lid 
group by
 r.title,
 r.callno,
 r.barcode,
 l.library,
 l.name,
 s.circs 
order by
 r.title,
 r.barcode,
 l.library,
 l.name";

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
