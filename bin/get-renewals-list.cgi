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
my $lid = $query->param('lid');

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
  l.name as to,
  l.library as to_library,
  l2.name as from,
  l2.library as from_library,
  replace(ra.status,'|',' ') as status, 
  ra.message
from requests_active ra
  left join request r on r.id=ra.request_id
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join libraries l on l.lid = ra.msg_to
  left join libraries l2 on l2.lid = ra.msg_from
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

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid, $lid );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { renewals => $aref } );
