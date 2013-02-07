#!/usr/bin/perl
use strict;
use warnings;

use CGI;
use DBI;
use JSON;
use Data::Dumper;

my $query = new CGI;
#print STDERR Dumper($query->param('value'));
#print STDERR Dumper($query->param('pid'));
#print STDERR Dumper($query->param('lid'));
#print STDERR Dumper($query->param('column'));

my $pid = $query->param('pid');
my $lid = $query->param('lid');
my $column = $query->param('column');
my $value = $query->param('value');

my $SQL;
if ($column == 4)    { $SQL = "update patrons set email_address=? where home_library_id=? and pid=?"; }
elsif ($column == 5) { $value = ($value == 0) ? 0 : 1;  $SQL = "update patrons set is_enabled=? where home_library_id=? and pid=?"; }
elsif ($column == 6) { $value = ($value == 0) ? 0 : 1;  $SQL = "update patrons set is_verified=? where home_library_id=? and pid=?"; }
elsif ($column == 9) { $SQL = "update patrons set password=md5(?) where home_library_id=? and pid=?"; }
else { print "Content-Type:application/json\n\n" . to_json( { success => 0, data => $query->param('value') } ); exit; }

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

if ($column == 9) { $value = '-- password changed --'; }

print "Content-Type:application/json\n\n" . to_json( { success => $retval, data => $value } );
