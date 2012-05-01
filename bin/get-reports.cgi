#!/usr/bin/perl

use DBI;
use JSON;

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

my $SQL="select rid, name, description, generator from reports where rtype=?";
my $aref_summary   = $dbh->selectall_arrayref($SQL, { Slice => {} }, 'Summary' );
my $aref_borrowing = $dbh->selectall_arrayref($SQL, { Slice => {} }, 'Borrowing' );
my $aref_lending   = $dbh->selectall_arrayref($SQL, { Slice => {} }, 'Lending' );
my $aref_narrative = $dbh->selectall_arrayref($SQL, { Slice => {} }, 'Narrative' );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { reports => { summary => $aref_summary,
								    borrowing => $aref_borrowing, 
								    lending => $aref_lending,
								    narrative => $aref_narrative
						       }});
