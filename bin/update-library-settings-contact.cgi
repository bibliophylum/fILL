#!/usr/bin/perl
use strict;
use warnings;

use CGI;
use DBI;
use JSON;
use Data::Dumper;

my $query = new CGI;

my $lid = $query->param('lid');
my $email_address = $query->param('email_address');
my $website = $query->param('website');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $SQL = "update libraries set email_address=?, website=? where lid=?"; 
my $retval = $dbh->do( $SQL, undef, $email_address, $website, $lid );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
