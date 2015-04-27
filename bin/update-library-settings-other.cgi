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
my $slips_with_barcodes = $query->param('slips_with_barcodes');
my $centralized_ill = $query->param('centralized_ill');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $SQL = "update libraries set slips_with_barcodes=?, centralized_ill=? where lid=?"; 
my $retval = $dbh->do( $SQL, undef, $slips_with_barcodes, $centralized_ill, $lid );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
