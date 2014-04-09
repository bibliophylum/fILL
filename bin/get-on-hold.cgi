#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

# sql to get requests which this library has placed on hold in their ILS
my $SQL="select 
  g.group_id as gid,
  c.chain_id as cid,
  r.id, 
  g.title, 
  g.author, 
  date_trunc('second',ra.ts) as ts, 
  l.name as from, 
  l.library, 
  ra.msg_to,
  ra.message as date_expected, 
  (select count(request_id) from requests_active where request_id=r.id and status='Cancel') as cancel 
from requests_active ra
  left join request r on r.id=ra.request_id
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join libraries l on l.lid = ra.msg_to
  left join sources s on (s.group_id = g.group_id and s.lid = ra.msg_to) 
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

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid, $lid, $lid );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { on_hold => $aref } );
