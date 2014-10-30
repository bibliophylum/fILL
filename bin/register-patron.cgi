#!/usr/bin/perl

use CGI;
use DBI;
use JSON;
#use Digest::MD5 qw(md5 md5_hex md5_base64);
use Data::Dumper;

my $query = new CGI;

#print STDERR $query->param('home_library') . "\n";
#print STDERR $query->param('patron_name') . "\n";
#print STDERR $query->param('patron_card') . "\n";
#print STDERR $query->param('patron_pin') . "\n";
#print STDERR $query->param('email_address') . "\n";
#print STDERR $query->param('username') . "\n";
#print STDERR $query->param('password') . "\n";
#print STDERR $query->param('sip2_enabled') . "\n";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

if ($query->param('sip2_enabled') && ($query->param('sip2_enabled') == 1)) {
}

my $SQL = "select lid from libraries where city=?";
my $aref = $dbh->selectrow_arrayref($SQL,undef,$query->param('home_library'));
my $rows_affected = 0;
if ($aref) {
    $rows_affected = $dbh->do("INSERT INTO patrons (username, password, home_library_id, email_address, name, card) VALUES (?,md5(?),?,?,?,?)", undef, 
			      $query->param('username'),
			      $query->param('password'),
			      $aref->[0],
			      $query->param('email_address'),
			      $query->param('patron_name'),
			      $query->param('patron_card')
	);
}
					
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $rows_affected } );
