#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $SQL = "select can_forward_to_children from libraries where lid=?";
my @flags = $dbh->selectrow_array($SQL, undef, $lid );
@flags[0] = 0 unless (@flags);

$SQL = "select ls.child_id as lid, l.name, l.library, l.city from library_systems ls left join libraries l on ls.child_id=l.lid where parent_id=? order by l.city";
my $retargets;
if (@flags[0]) {
    $retargets = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid );
}

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { forward => { canForwardToChildren => @flags[0],
								    retargets => $retargets 
						       }});
