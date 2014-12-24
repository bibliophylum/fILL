#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $q = new CGI;
my $lid = $q->param('lid');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("delete from acquisitions where lid=?", undef, $lid );

$dbh->disconnect;
print "Content-Type:application/json\n\n" . to_json( { success => 1 } );
