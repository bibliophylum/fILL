#!/usr/bin/perl

use CGI;
use CGI::Session;
use DBI;
use JSON;

my $query = new CGI;
my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
if (($session->is_expired) || ($session->is_empty)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
    exit;
}
my $lid = $query->param('lid');
my $sdate = $query->param('sdate');
my $edate = $query->param('edate');
my $limit = $query->param('limit') || 3;

my $SQL="select
 r.title,
 r.callno,
 r.barcode,
 sum(s.circs) as total_circ 
from
 rotations r
 inner join rotations_stats s on s.barcode=r.barcode
where 
 s.ts_start::date >= ?
 and s.ts_end::date < ?
group by
 r.title,
 r.callno,
 r.barcode
having
 sum(s.circs) >= ? 
order by
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

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $sdate, $edate, $limit );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { rotations_item_highcirc => $aref } );
