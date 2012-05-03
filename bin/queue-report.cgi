#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $rid = $query->param('rid');
my $lid = $query->param('lid');
my $d_s = $query->param('start');
my $d_e = $query->param('end');

# sql to add to the report queue
my $SQL = "insert into reports_queue (rid, lid, range_start, range_end) values (?,?,?,?)";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

my $retval = $dbh->do( $SQL, undef, $rid, $lid, $d_s, $d_e );
$dbh->disconnect;

# at this point, poke the reporter-boss with a stick

print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
