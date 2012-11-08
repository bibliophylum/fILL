#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
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
  f.name as from, 
  ra.msg_from, 
  t.name as to, 
  ra.msg_to, 
  ra.status, 
  ra.message 
from 
  requests_active ra 
  left join request r on r.id = ra.request_id
  left join libraries f on ra.msg_from = f.lid 
  left join libraries t on ra.msg_to = t.lid 
where 
  r.chain_id=?
order by ts
";
my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $chain_id );

$dbh->do("SET TIMEZONE='America/Winnipeg'");

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { request_details => $aref });
