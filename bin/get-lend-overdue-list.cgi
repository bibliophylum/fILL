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

#  0    1    2     3     4    5     6     7      8
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $today = sprintf("%4d-%02d-%02d",($year+1900),($mon+1),$mday);

# sql to get items this library has loaned, which are overdue
my $SQL="select 
  g.group_id as gid,
  c.chain_id as cid,
  r.id, 
  g.title, 
  g.author, 
  o.symbol as borrower_symbol, 
  o.org_name as library, 
  ra.msg_to, 
  date_trunc('second',ra2.ts) as ts, 
  ra2.status,
  substring(ra.message from 'due (.*)') as due_date,
  o.email_address,
  o2.org_name as lending_library  
from requests_active ra
  left join request r on r.id=ra.request_id
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join org o on o.oid = ra.msg_to
  left join requests_active ra2 on ra2.request_id=ra.request_id 
  left join org o2 on o2.oid = ra.msg_from 
where 
  ra.msg_from=? 
  and ra.ts=(select ts from requests_active where request_id=ra.request_id and (status='Shipped' or status='Renew-Answer|Ok') order by ts desc limit 1) 
  and ra.request_id not in (select request_id from requests_active where msg_to=? and status='Returned') 
  and ra.request_id not in (select request_id from requests_active where msg_to=? and status='Renew' and request_id not in (select request_id from requests_active where msg_from=? and status='Renew-Answer|Ok'))
  and substring(ra.message from 'due (.*)') < ? 
  and ra2.ts = (select max(ts) from requests_active where request_id=ra.request_id) 
order by borrower_symbol, due_date
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

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $oid,$oid,$oid,$oid,$today );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { overdue => $aref } );
