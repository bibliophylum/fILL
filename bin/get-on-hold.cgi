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

# sql to get requests which this library has placed on hold in their ILS
my $SQL="select 
  g.group_id as gid,
  c.chain_id as cid,
  r.id, 
  g.title, 
  g.author, 
  date_trunc('second',ra.ts) as ts, 
  o.symbol as from, 
  o.org_name as library, 
  o.opt_in, 
  ra.msg_to,
  ra.message as date_expected, 
  (select count(request_id) from requests_active where request_id=r.id and status='Cancel') as cancel,
  n.note as lender_internal_note 
from requests_active ra
  left join request r on r.id=ra.request_id
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join org o on o.oid = ra.msg_to
  left join sources s on (s.group_id = g.group_id and s.oid = ra.msg_to) 
  left join internal_note n on (n.request_id=r.id and n.private_to=ra.msg_from) 
where 
  ra.msg_from=? 
  and ra.status like '%Hold-Placed%' 
  and ra.request_id not in (select request_id from requests_active where msg_from=? and status='Shipped') 
  and ra.request_id not in (select request_id from requests_active where msg_from=? and status like '%being-processed-for-supply%') 
order by s.call_number, g.author, g.title
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

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $oid, $oid, $oid );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { on_hold => $aref } );
