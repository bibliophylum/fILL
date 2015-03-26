#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

# sql to get requests to this library, which this library has not responded to yet
my $SQL="select 
  g.group_id as gid,
  c.chain_id as cid,
  r.id, 
  g.title, 
  g.author, 
  g.note, 
  g.medium,
  date_trunc('second',ra.ts) as ts, 
  l.name as from, 
  l.library, 
  ra.msg_from, 
  s.call_number,
  g.place_on_hold,
  g.pubdate 
from requests_active ra
  left join request r on r.id=ra.request_id
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join sources s on (s.group_id = g.group_id and s.lid = ra.msg_to) 
  left join libraries l on l.lid = ra.msg_from
where 
  ra.msg_to=? 
  and ra.status='ILL-Request' 
  and ra.request_id not in (select request_id from requests_active where msg_from=?) 
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

$SQL = "select can_forward_to_children from libraries where lid=?";
my @flags = $dbh->selectrow_array($SQL, undef, $lid );
@flags[0] = 0 unless (@flags);

$SQL = "select ls.child_id as lid, l.name, l.library, l.city from library_systems ls left join libraries l on ls.child_id=l.lid where parent_id=? order by l.city";
my $retargets;
if (@flags[0]) {
    $retargets = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid );
}

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { unhandledRequests => $aref,
						       canForwardToChildren => @flags[0],
						       retargets => $retargets
						     } );
