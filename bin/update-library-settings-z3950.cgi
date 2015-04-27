#!/usr/bin/perl
use strict;
use warnings;

use CGI;
use CGI::Session;
use DBI;
use JSON;
use Data::Dumper;

my $query = new CGI;
my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
if (($session->is_expired) || ($session->is_empty)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
    exit;
}

my $lid = $query->param('lid');
my $server = $query->param('z3950_server_address');
my $port = $query->param('z3950_server_port');
my $database = $query->param('z3950_database_name');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $SQL = "update library_z3950 set server_address=?, server_port=?, database_name=? where lid=?"; 
my $retval = $dbh->do( $SQL, undef, $server, $port, $database, $lid );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
