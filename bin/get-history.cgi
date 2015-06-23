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
my $start = $query->param('start');
my $end = $query->param('end');

#print STDERR "get-history.cgi, start [" . $start . "]\n";
#print STDERR "get-history.cgi, end   [" . $end . "]\n";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

# sql to get this library's borrowing history
my $SQL="select 
  hg.group_id as gid,
  hc.chain_id as cid,
  hg.title, 
  hg.author, 
  date_trunc('second',rh.ts) as ts, 
  o1.symbol as from,
  o1.org_name as from_library,
  o2.symbol as to,
  o2.org_name as to_library,
  replace(rh.status,'|',' ') as status, 
  rh.message 
from requests_history rh
  left join request_closed rc on rc.id=rh.request_id
  left join history_chain hc on hc.chain_id = rc.chain_id
  left join history_group hg on hg.group_id = hc.group_id
  left join org o1 on o1.oid=rh.msg_from
  left join org o2 on o2.oid=rh.msg_to
where 
  rc.requester=?
  and rh.ts=(select max(ts) from requests_history rh2 left join request_closed r2 on r2.id=rh2.request_id left join history_chain hc2 on hc2.chain_id=r2.chain_id where r2.chain_id=hc.chain_id)
  and rh.ts >= ?
  and rh.ts < ?
group by gid, cid, hg.title, hg.author, hg.patron_barcode, ts, status, rh.message, o1.symbol, o1.org_name, o2.symbol, o2.org_name   
order by ts
";
my $aref_borr = $dbh->selectall_arrayref($SQL, { Slice => {} }, $oid, $start, $end );

# sql to get this library's lending history
$SQL="select 
  hc.chain_id as cid, 
  hg.title, 
  hg.author, 
  o.symbol as requested_by, 
  o.org_name as library,
  date_trunc('second',rh.ts) as ts, 
  replace(rh.status,'|',' ') as status, 
  rh.message 
from requests_history rh
  left join request_closed rc on rc.id=rh.request_id
  left join history_chain hc on hc.chain_id = rc.chain_id
  left join history_group hg on hg.group_id = hc.group_id
  left join org o on o.oid = rc.requester
where 
  rc.requester<>? 
  and rh.ts in (select max(ts) from requests_history where msg_from=? group by request_id) 
  and rh.ts >= ? 
  and rh.ts < ? 
order by ts
";
my $aref_lend = $dbh->selectall_arrayref($SQL, { Slice => {} }, $oid, $oid, $start, $end );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { history => { borrowing => $aref_borr, 
								    lending => $aref_lend 
						       }});
