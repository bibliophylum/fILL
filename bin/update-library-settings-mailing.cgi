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
my $org_name = $query->param('library');
my $mailing_address_line1 = $query->param('mailing_address_line1');
my $city = $query->param('city');
my $province = $query->param('province');
my $post_code = $query->param('post_code');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $SQL = "update org set org_name=?, mailing_address_line1=?, city=?, province=?, post_code=? where oid=?"; 
my $retval = $dbh->do( $SQL, undef, $org_name, $mailing_address_line1, $city, $province, $post_code, $oid );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
