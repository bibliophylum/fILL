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

# sql to get requests where another library has answered this library with "Hold-Placed"

my $SQL = "select 
  g.group_id as gid,
  c.chain_id as cid,
  r.id, 
  g.title, 
  g.author, 
  g.patron_barcode, 
  date_trunc('second',ra.ts) as ts, 
  ra.msg_from, 
  o.symbol as from, 
  o.org_name as library, 
  o.opt_in, 
  replace(ra.status,'|',' ') as status, 
  ra.message, 
  (select count(*) from sources s where g.group_id=s.group_id and tried=true) as tried, 
  (select count(*) from sources s2 where g.group_id=s2.group_id) as sources, 
  n.note as borrower_internal_note 
from requests_active ra
  left join request r on r.id=ra.request_id
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join org o on o.oid = ra.msg_from
  left join internal_note_borrower n on (n.gid=g.group_id and n.private_to=ra.msg_from) 
where 
  ra.msg_to=?
  and ra.status like 'ILL-Answer|Hold-Placed%' 
  and r.id not in (select request_id from requests_active where status='Message' and message='Requester closed the request.') 
  and ra.ts = (select max(ts) from requests_active ra2 where ra2.request_id = ra.request_id) 
order by ra.ts
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

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $oid );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { holds => $aref } );
