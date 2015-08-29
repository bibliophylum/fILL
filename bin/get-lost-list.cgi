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

# sql to get requests which have not yet been responded to
my $SQL = "select 
  g.group_id as gid,
  c.chain_id as cid,
  r.id, 
  g.title, 
  g.author, 
  date_trunc('second',ra.ts) as ts, 
  ra.msg_from, 
  o.symbol as from, 
  o.org_name as library, 
  o.mailing_address_line1,
  o.mailing_address_line2,
  o.mailing_address_line3,
  o.town,
  o.province,
  o.post_code,
  o.phone,
  ra.status,
  ra.message  
from requests_active ra
  left join request r on r.id=ra.request_id
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join org o on o.oid = ra.msg_from 
where 
  ra.msg_to=?
  and ra.status = 'Lost' 
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

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $oid );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { lostlist => $aref } );
