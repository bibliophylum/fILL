#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $msg_from = $query->param('lid');

print STDERR "in update-library-barcode.cgi\n";
exit;

# sql to add to the request conversation
my $SQL = "insert into requests_active (request_id, msg_from, msg_to, status, message) values (?,?,?,?,?)";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

my $retval = $dbh->do( $SQL, undef, $reqid, $msg_from, $msg_to, $status, $message );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
