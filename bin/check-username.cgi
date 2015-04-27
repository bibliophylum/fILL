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

my $SQL = "select count(*) from patrons where username=?";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

#$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $aref = $dbh->selectrow_arrayref($SQL,undef,$query->param('username'));
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { exists => $aref->[0] } );
