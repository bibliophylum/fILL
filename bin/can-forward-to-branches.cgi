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

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $SQL = "select can_forward_to_children from org where oid=?";
my @flags = $dbh->selectrow_array($SQL, undef, $oid );
@flags[0] = 0 unless (@flags);

#$SQL = "select ls.child_id as oid, o.symbol, o.org_name, o.city from library_systems ls left join org o on ls.child_id=o.oid where parent_id=? order by o.city";
$SQL = "select oid, symbol, org_name, city from org where oid in (select member_id from org_members where oid=?) order by city";
my $retargets;
if (@flags[0]) {
    $retargets = $dbh->selectall_arrayref($SQL, { Slice => {} }, $oid );
}

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { forward => { canForwardToChildren => @flags[0],
								    retargets => $retargets 
						       }});
