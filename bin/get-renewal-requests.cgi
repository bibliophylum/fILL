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

# sql to get renewal requests to this library from borrowers
my $SQL="select 
  g.group_id as gid,
  c.chain_id as cid,
  r.id, 
  g.title, 
  g.author, 
  date_trunc('second',ra.ts) as ts, 
  o.symbol as from, 
  o.org_name as library, 
  ra.msg_from, 
  s.call_number,
  x.message as original_due_date 
from requests_active ra
  left join request r on r.id=ra.request_id
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join sources s on (s.group_id = g.group_id and s.oid = ra.msg_to) 
  left join org o on o.oid = ra.msg_from
  left join requests_active x on (x.request_id = r.id and x.status = 'Shipped') 
where 
  ra.msg_to=? 
  and ra.status='Renew' 
  and ra.request_id not in (select request_id from requests_active where msg_from=? and status like 'Renew-Answer%') 
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

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $oid, $oid );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { renewRequests => $aref } );
