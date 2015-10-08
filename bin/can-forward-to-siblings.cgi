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

my $SQL = "select can_forward_to_siblings from org where oid=?";
my @flags = $dbh->selectrow_array($SQL, undef, $oid );
@flags[0] = 0 unless (@flags);

$SQL = "select o.oid, o.symbol, o.org_name, o.city from org_members om left join org o on o.oid=om.member_id where om.oid in (select oid from org_members where member_id=?) order by o.city";
my $retargets;
if (@flags[0]) {
    $retargets = $dbh->selectall_arrayref($SQL, { Slice => {} }, $oid );
}

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { forward => { canForwardToSiblings => @flags[0],
								    retargets => $retargets 
						       }});
