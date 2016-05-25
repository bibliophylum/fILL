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

my $oid = $query->param('oid');
my $lender_internal_notes = $query->param('lender_internal_notes');
my $slips_with_barcodes = $query->param('slips_with_barcodes');
my $centralized_ill = $query->param('centralized_ill');
my $rows_per_page = $query->param('rows_per_page') || 25;

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $SQL = "update org set lender_internal_notes_enabled=?, slips_with_barcodes=?, centralized_ill=?, rows_per_page=? where oid=?"; 
my $retval = $dbh->do( $SQL, undef, $lender_internal_notes, $slips_with_barcodes, $centralized_ill, $rows_per_page, $oid );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
