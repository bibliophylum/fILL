#!/usr/bin/perl
use strict;
use warnings;

use CGI;
use CGI::Session;
use DBI;
use JSON;
use Data::Dumper;

my $query = new CGI;
#my $session = new CGI::Session(undef, $query, {Directory=>"/tmp"});
my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
if (($session->is_expired) || ($session->is_empty)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
    exit;
}

my $dr = $session->dataref();

my $oid = $query->param('oid');
my $opt_in_returns_only = $query->param('opt_in_returns_only');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $SQL = "update org set opt_in_returns_only=? where oid=?"; 
my $retval = $dbh->do( $SQL, undef, $opt_in_returns_only, $oid );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
