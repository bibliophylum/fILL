#!/usr/bin/perl

# Note: this gets a list of items currently borrowed that *can be* renewed, not a list of items that *have been* renewed!

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

# sql to get items shipped to this library which have not yet been returned
#my $SQL = "select r.id, r.title, r.author, r.patron_barcode, ra.request_id, date_trunc('second',ra.ts) as ts, ra.msg_from, ra.msg_to, l.name as to, l.library, ra.status, ra.message from request r left join requests_active ra on (r.id = ra.request_id) left join libraries l on ra.msg_to = l.lid where ra.ts=(select max(ts) from requests_active ra2 where ra.request_id = ra2.request_id) and ra.request_id in (select request_id from requests_active where msg_from=? and status='Received' and request_id not in (select request_id from requests_active where status='Returned'))";

my $SQL = "select
  r.id,
  g.title,
  g.author,
  g.patron_barcode,
  ra.request_id,
  date_trunc('second',ra.ts) as ts,
  ra.msg_from,
  ra.msg_to,
  l.name as to,
  l.library,
  ra.status,
  ra.message
from requests_active ra
  left join request r on r.id=ra.request_id
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join libraries l on l.lid = ra.msg_to
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
