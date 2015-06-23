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

# number of rotation titles received at each participating library
# in the last two months.
my $SQL="select
 o.org_name as now_at,
 o.symbol,
 count(r.id) 
from
 rotations_participants p
 left join org o on o.oid=p.oid
 left join rotations r on r.current_library = o.oid
where 
 r.ts >= now() - interval '2 months'
group by
 o.org_name,
 o.symbol  
order by
 o.org_name,
 o.symbol
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
