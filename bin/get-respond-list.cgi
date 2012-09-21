#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

# sql to get requests to this library, which this library has not responded to yet
my $SQL = "select r.id, r.title, r.author, r.note, date_trunc('second',ra.ts) as ts, l.name as from, l.library, ra.msg_from, s.call_number from request r left join requests_active ra on (r.id = ra.request_id) left join sources s on (s.request_id = ra.request_id and s.lid = ra.msg_to) left join libraries l on ra.msg_from = l.lid where ra.msg_to=? and ra.status='ILL-Request' and ra.request_id not in (select request_id from requests_active where msg_from=?) order by s.call_number, r.author, r.title";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

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
