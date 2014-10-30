#!/usr/bin/perl

use CGI;
use DBI;
use JSON;
#use Digest::MD5 qw(md5 md5_hex md5_base64);
use String::Random;
#use Data::Dumper;

my $query = new CGI;

#print STDERR $query->param('patron_name') . "\n";
#print STDERR $query->param('patron_card') . "\n";
#print STDERR $query->param('lid') . "\n";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $SR = new String::Random;
my $pass = $SR->randregex("[\w]{75}"); # generate a random-ish string for a password that will never be used.

my $rows_affected = $dbh->do("INSERT INTO patrons (is_sip2, username, password, home_library_id, name, card) VALUES (?,?,md5(?),?,?,?)", undef, 
			     1,
			     $query->param('patron_name'),
			     $pass,
			     $query->param('lid'),
			     $query->param('patron_name'),
			     $query->param('patron_card')
    );
					
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $rows_affected } );
