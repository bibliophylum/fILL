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

# sql to get new (not yet handled) patron requests
my $SQL = "select 
  pr.prid, 
  date_trunc('second',pr.ts) as ts, 
  p.name, 
  p.card, 
  pr.title, 
  pr.author,
  pr.medium,
  pr.pubdate,
  pr.isbn,
  p.is_verified,
  (select
    count(*)  
  from
    patron_request_sources prs
    left join org_members om on om.member_id = prs.oid 
  where
    prid=pr.prid
    and om.oid=(select oid from org where symbol='SPRUCE')
  ) as spruce_sources 
from 
  patron_request pr 
  left join patrons p on p.pid = pr.pid 
where 
  pr.oid = ? 
order by 
  name, ts";

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

# any of them local?
my $localcopy_href = $dbh->selectall_hashref("select prid from patron_request_sources where oid=?", 'prid', undef, $oid);

foreach my $href (@$aref) {
    if (exists $localcopy_href->{ $href->{prid} }) {
	$href->{"has_local_copy"} = 1;
    } else {
	$href->{"has_local_copy"} = 0;
    }
}

# am I a Spruce library?
my $isSpruce = $dbh->selectrow_array("select count(*) from org_members where member_id=? and oid=(select oid from org where symbol='SPRUCE')", undef, $oid);

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { new_patron_requests => $aref,
						       am_spruce => $isSpruce
						     } );
