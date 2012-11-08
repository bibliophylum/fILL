#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

# sql to get requests which this library has said they will supply, but have not yet shipped
#my $SQL = "select r.id, r.title, r.author, l.library || '<br/>' || mailing_address_line1 || '<br/>' || mailing_address_line2 || '<br/>' || mailing_address_line3 as mailing_address, date_trunc('second',ra.ts) as ts, l.name as from, l.library, ra.msg_to from request r left join requests_active ra on (r.id = ra.request_id) left join sources s on (s.request_id = ra.request_id and s.lid = ra.msg_to) left join libraries l on ra.msg_to = l.lid where ra.msg_from=? and ra.status like '%Will-Supply%' and ra.request_id not in (select request_id from requests_active where msg_from=? and status='Shipped') order by s.call_number, r.author, r.title";
my $SQL="select 
  r.id, 
  g.title, 
  g.author, 
  l.library || '<br/>' || l.mailing_address_line1 || '<br/>' || l.mailing_address_line2 || '<br/>' || l.mailing_address_line3 as mailing_address, 
  date_trunc('second',ra.ts) as ts, 
  l.name as from, 
  l.library, 
  ra.msg_to 
from requests_active ra
  left join request r on r.id=ra.request_id
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join libraries l on l.lid = ra.msg_to
  left join sources s on (s.group_id = g.group_id and s.lid = ra.msg_to) 
where 
  ra.msg_from=? 
  and ra.status like '%Will-Supply%' 
  and ra.request_id not in (select request_id from requests_active where msg_from=? and status='Shipped') 
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

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid, $lid );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { shipping => $aref } );
