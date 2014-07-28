#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $region = $query->param('region');

my $SQL = "select city from libraries where region=? order by city";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

#$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $aref = $dbh->selectall_arrayref($SQL, undef, $region);
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { city => $aref } );
