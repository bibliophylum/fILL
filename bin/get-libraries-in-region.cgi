#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lang = $query->param('lang') || 'en';
my $region = $query->param('region');

#my $SQL = "select oid,city,org_name from org where region=? order by city";
my $SQL = "select oid,city,org_name from org where region=(select id from i18n_regions where region=? and lang=?) order by org_name";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

#$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $aref = $dbh->selectall_arrayref($SQL, undef, $region, $lang);
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { inregion => $aref } );
