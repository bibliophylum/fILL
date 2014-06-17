#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

# number of rotation titles received at each participating library
# in the last two months.
my $SQL="select
 l1.library as now_at,
 l1.name as symbol,
 count(r.id) 
from
 rotations_participants p
 left join libraries l1 on l1.lid=p.lid
 left join rotations r on r.current_library = l1.lid
where 
 r.ts >= now() - interval '2 months'
group by
 l1.library,
 l1.name 
order by
 l1.library,
 l1.name
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

print "Content-Type:application/json\n\n" . to_json( { rotations_received => $aref } );
