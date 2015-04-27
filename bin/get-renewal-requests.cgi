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
my $lid = $query->param('lid');

# sql to get renewal requests to this library from borrowers
#my $SQL = "select r.id, r.title, r.author, date_trunc('second',ra.ts) as ts, l.name as from, l.library, ra.msg_from, s.call_number from request r left join requests_active ra on (r.id = ra.request_id) left join sources s on (s.request_id = ra.request_id and s.lid = ra.msg_to) left join libraries l on ra.msg_from = l.lid where ra.msg_to=? and ra.status='Renew' and ra.request_id not in (select request_id from requests_active where msg_from=? and status like 'Renew-Answer%') order by s.call_number, r.author, r.title";
my $SQL="select 
  g.group_id as gid,
  c.chain_id as cid,
  r.id, 
  g.title, 
  g.author, 
  date_trunc('second',ra.ts) as ts, 
  l.name as from, 
  l.library, 
  ra.msg_from, 
  s.call_number 
from requests_active ra
  left join request r on r.id=ra.request_id
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join sources s on (s.group_id = g.group_id and s.lid = ra.msg_to) 
  left join libraries l on l.lid = ra.msg_from
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

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid, $lid );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { renewRequests => $aref } );
