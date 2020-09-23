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

my $dr = $session->dataref();

my $oid = $query->param('oid');
my $lib_status = $query->param('lib_status');
$lib_status =~ s/^\s+|\s+$//g;
if ($lib_status eq "") { undef $lib_status; }

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $SQL = "update org set lib_status=? where oid=?"; 
my $retval = $dbh->do( $SQL, undef, $lib_status, $oid );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval, orig => $dr } );
