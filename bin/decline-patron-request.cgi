#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $prid = $query->param('prid');
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

my $SQL = "delete from patron_request_sources where prid=?";
my $rv = $dbh->do($SQL, undef, $prid );

$SQL = "delete from patron_request where prid=? and lid=?";
my $rows = $dbh->do($SQL, undef, $prid, $lid );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => ($rows == undef) ? 0 : 1 } );
