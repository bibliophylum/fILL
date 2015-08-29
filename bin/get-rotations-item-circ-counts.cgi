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
my $oid = $query->param('oid');

my $SQL="select
 o.org_name as library,
 o.symbol,
 s.ts_start::date,
 s.ts_end::date,
 r.title,
 r.callno,
 r.barcode,
 s.circs 
from
 rotations r
 inner join rotations_stats s on s.barcode=r.barcode
 left join org o on o.oid=s.oid 
group by
 o.org_name,
 o.symbol,
 s.ts_start::date,
 s.ts_end::date,
 r.title,
 r.callno,
 r.barcode,
 s.circs 
order by
 o.org_name,
 o.symbol,
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
