#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');
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
  l1.name as from,
  l1.library as from_library,
  l2.name as to,
  l2.library as to_library,
  replace(rh.status,'|',' ') as status, 
  rh.message 
from requests_history rh
  left join request_closed rc on rc.id=rh.request_id
  left join history_chain hc on hc.chain_id = rc.chain_id
  left join history_group hg on hg.group_id = hc.group_id
  left join libraries l1 on l1.lid=rh.msg_from
  left join libraries l2 on l2.lid=rh.msg_to
where 
  rc.requester=?
  and rh.ts=(select max(ts) from requests_history rh2 left join request_closed r2 on r2.id=rh2.request_id left join history_chain hc2 on hc2.chain_id=r2.chain_id where r2.chain_id=hc.chain_id)
  and rh.ts >= ?
  and rh.ts < ?
group by gid, cid, hg.title, hg.author, hg.patron_barcode, ts, status, rh.message, l1.name, l1.library, l2.name, l2.library   
order by ts
";
my $aref_borr = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid, $start, $end );

# sql to get this library's lending history
$SQL="select 
  hc.chain_id as cid, 
  hg.title, 
  hg.author, 
  l.name as requested_by, 
  l.library,
  date_trunc('second',rh.ts) as ts, 
  replace(rh.status,'|',' ') as status, 
  rh.message 
from requests_history rh
  left join request_closed rc on rc.id=rh.request_id
  left join history_chain hc on hc.chain_id = rc.chain_id
  left join history_group hg on hg.group_id = hc.group_id
  left join libraries l on l.lid = rc.requester
where 
  rc.requester<>? 
  and rh.ts in (select max(ts) from requests_history where msg_from=? group by request_id) 
  and rh.ts >= ? 
  and rh.ts < ? 
order by ts
";
my $aref_lend = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid, $lid, $start, $end );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { history => { borrowing => $aref_borr, 
								    lending => $aref_lend 
						       }});
