#!/usr/bin/perl

use CGI;
use CGI::Session;
use DBI;
use JSON;
use Data::Dumper;

my $query = new CGI;
my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
if (($session->is_expired) || ($session->is_empty)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
    exit;
}
#my $reqid = $query->param('reqid');
my $chain_id = $query->param('cid');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

# sql to get a live (active) request
my $SQL = "select 
  ra.request_id,  
  date_trunc('second',ra.ts) as ts, 
  f.symbol as from, 
  ra.msg_from, 
  t.symbol as to, 
  ra.msg_to, 
  ra.status, 
  ra.message 
from 
  requests_active ra 
  left join request r on r.id = ra.request_id
  left join org f on ra.msg_from = f.oid 
  left join org t on ra.msg_to = t.oid 
where 
  r.chain_id=?
order by ts
";
my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $chain_id );

my $rid = $aref->[ $#aref ]{"request_id"};
$SQL = "select oid, rid, tracking from shipping_tracking_number where rid=?";
# get the request_id of the last element of the array:
my $tracking = $dbh->selectall_arrayref($SQL, { Slice => {} }, $rid);

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { request_details => $aref,
						       tracking => $tracking });
