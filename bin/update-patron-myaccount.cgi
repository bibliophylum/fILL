#!/usr/bin/perl
use strict;
use warnings;

use CGI;
use DBI;
use JSON;
use Data::Dumper;

my $query = new CGI;
my $pid = $query->param('pid');
my $lid = $query->param('lid');
my $userSetting = $query->param('usersetting');
my $value = $query->param('value');

my $SQL;

# untaint us some data....
if ($userSetting eq "email_address") {
    if ($value =~ /(\w{1}[\w\-\.]*)\@([\w\-\.]+)/) {
	$value = "$1\@$2";
    } else {
	$value = "invalid email address";
    }
    $SQL = "update patrons set email_address=? where home_library_id=? and pid=?";
} elsif ($userSetting eq "name") {
    if ($value =~ /(\w{1}[\w\-\. ]*)/) {
	$value = "$1";
    } else {
	$value = "invalid name - letters periods and spaces only";
    }
    $SQL = "update patrons set name=? where home_library_id=? and pid=?";
} else { 
    print "Content-Type:application/json\n\n" . to_json( { success => 0, data => $query->param('value') } ); 
    exit; 
}

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $retval = $dbh->do( $SQL, undef, $value, $lid, $pid );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval, data => $value } );
