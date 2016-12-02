#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lang = $query->param('lang') || 'en';

# Uncomment this on dev
my $SQL = "select distinct region from i18n_regions where lang=? and id<>0 order by region";
# Uncomment this on production
#my $SQL = "select distinct region from i18n_regions where lang=? and id<>0 and region <> 'PLS Testing' order by region";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

#$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $aref = $dbh->selectall_arrayref($SQL,undef,$lang);
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { regions => $aref } );
