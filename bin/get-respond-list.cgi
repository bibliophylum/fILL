#!/usr/bin/perl

use CGI;
use CGI::Session;
use DBI;
use JSON;

my $query = new CGI;
my $session;
if (($ENV{GATEWAY_INTERFACE}) && ($ENV{GATEWAY_INTERFACE} =~ /CGI/)) {  # only worry about session if we're a cgi
    $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
    if (($session->is_expired) || ($session->is_empty)) {
        print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
        exit;
    }
}
my $oid = $query->param('oid');

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
  o.symbol as from, 
  o.org_name as library, 
  ra.msg_from, 
  s.call_number,
  g.place_on_hold,
  g.pubdate,
  n.note as lender_internal_note 
from requests_active ra
  left join request r on r.id=ra.request_id
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join sources s on (s.group_id = g.group_id and s.oid = ra.msg_to) 
  left join org o on o.oid = ra.msg_from
  left join internal_note n on (n.request_id=r.id and n.private_to=ra.msg_to) 
where 
  ra.msg_to=? 
  and ra.status='ILL-Request' 
  and ra.request_id not in (select request_id from requests_active where msg_from=?) 
  and ra.request_id not in (select request_id from requests_active where msg_to=? and message='Trying next source') 
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

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $oid, $oid, $oid );

$SQL = "select can_forward_to_siblings from org where oid=?";
my @flags = $dbh->selectrow_array($SQL, undef, $oid );
@flags[0] = 0 unless (@flags);

$SQL = "select o.oid, o.symbol, o.org_name, o.city from org_members om left join org o on o.oid=om.member_id where om.oid in (select oid from org_members where member_id=?) and o.oid<>? order by o.city";
my $retargets;
if (@flags[0]) {
    $retargets = $dbh->selectall_arrayref($SQL, { Slice => {} }, $oid, $oid );
}

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { unhandledRequests => $aref,
						       canForwardToSiblings => @flags[0],
						       retargets => $retargets
						     } );
