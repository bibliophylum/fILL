#!/usr/bin/perl

# Note: this gets a list of items currently borrowed that *can be* renewed, not a list of items that *have been* renewed!

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

my $SQL = "select
  g.group_id as gid,
  c.chain_id as cid,
  r.id,
  g.title,
  g.author,
  g.patron_barcode,
  ra.request_id,
  date_trunc('second',ra.ts) as ts,
  ra.msg_from,
  ra.msg_to,
  o.symbol as to,
  o.org_name as to_library, 
  o.opt_in as to_opt_in, 
  o2.symbol as from,
  o2.org_name as from_library, 
  o2.opt_in as from_opt_in, 
  replace(ra.status,'|',' ') as status, 
  ra.message, 
  n.note as borrower_internal_note 
from requests_active ra
  left join request r on r.id=ra.request_id
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join org o on o.oid = ra.msg_to
  left join org o2 on o2.oid = ra.msg_from
  left join internal_note_borrower n on (n.gid=g.group_id and n.private_to=ra.msg_to) 
where 
  ra.request_id in (select request_id
                    from requests_active
                    where msg_from=?
                      and status='Received'
                   )
  and ra.request_id not in (select request_id
                            from requests_active
                            where msg_from=?
                              and status='Returned'
                           )
  and
    ra.ts=(select max(ts) from requests_active ra2 where ra2.request_id = ra.request_id);
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

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $oid, $oid );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { renewals => $aref } );
