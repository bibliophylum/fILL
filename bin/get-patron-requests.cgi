#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $pid = $query->param('pid');
my $lid = $query->param('lid');
my $library = $query->param('library');
my $is_enabled = $query->param('is_enabled');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

# sql to get this patron's current borrowing
my $SQL="select 
  g.title, 
  g.author, 
  (case when (ra.msg_to=?) then l1.library else l2.library end) as lender, 
  date_trunc('second',ra.ts) as ts, 
  ra.status, 
  ra.message,
  count(s.request_id) as currently_trying,
  max(s.sequence_number) as libraries
from requests_active ra
  left join request r on r.id=ra.request_id
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join libraries l1 on (l1.lid=ra.msg_from) 
  left join libraries l2 on (l2.lid=ra.msg_to) 
  left join patrons p on (p.home_library_id=g.requester)
  left join sources s on (s.group_id=g.group_id)
where 
  g.patron_barcode=(select card from patrons where pid=?)
  and g.requester=?
  and ra.ts=(select max(ts) from requests_active ra2 left join request r2 on r2.id=ra2.request_id left join request_chain rc2 on rc2.chain_id=r2.chain_id where r2.chain_id=c.chain_id)
group by g.title, g.author, ts, lender, ra.status, ra.message
order by ra.ts
";
# There will be one row per request in the chain
my $aref_borr = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid, $pid, $lid );


$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { active => $aref_borr } );
