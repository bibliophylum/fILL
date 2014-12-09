#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

# sql to get requests which have not yet been responded to
my $SQL = "select 
  g.group_id as gid,
  c.chain_id as cid,
  r.id, 
  g.title, 
  g.author, 
  g.patron_barcode, 
  date_trunc('second',ra.ts) as ts, 
  ra.msg_to, 
  l.name as to, 
  l.library, 
  ra.status, 
  (select count(*) from sources s where g.group_id=s.group_id and tried=true) as tried, 
  (select count(*) from sources s2 where g.group_id=s2.group_id) as sources,
  current_date - date(ra.ts) as age
from requests_active ra
  left join request r on r.id=ra.request_id
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join libraries l on l.lid = ra.msg_to
where 
  ra.msg_from=?
  and ra.status = 'ILL-Request' 
  and r.id not in (select request_id from requests_active where status like 'ILL-Answer%') 
  and ra.ts = (select max(ts) from requests_active ra2 where ra2.request_id = ra.request_id) 
order by ra.ts;
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

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { noresponse => $aref } );