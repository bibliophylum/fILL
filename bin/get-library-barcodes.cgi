#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

my $SQL = "select 
  lb.lid, 
  lb.borrower, 
  l.name, 
  l.library, 
  lb.barcode 
from 
  library_barcodes lb 
  left join libraries l on l.lid=lb.borrower 
where lb.lid=? 
order by l.library
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

print "Content-Type:application/json\n\n" . to_json( { barcodes => $aref } );
