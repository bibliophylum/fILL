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

unless ($pid =~ /^pid/) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, data => $query->param('value') } ); 
    exit;
}
$pid =~ s/^pid//;

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $original_card;
my $SQL;
if ($column == 2) { 
    # if the patron barcode has changed, we need to change it in all active requests
    my $aref = $dbh->selectrow_arrayref("select card from patrons where pid=?",undef,$pid);
    $original_card = $aref->[0];
    $dbh->do("update request_group set patron_barcode=? where patron_barcode=? and requester=?",undef,$value,$original_card,$lid);
    $SQL = "update patrons set card=? where home_library_id=? and pid=?"; 
}
elsif ($column == 4) { $SQL = "update patrons set email_address=? where home_library_id=? and pid=?"; } 
elsif ($column == 5) { $value = (lc($value) eq "yes") ? 1 : 0;  $SQL = "update patrons set is_verified=? where home_library_id=? and pid=?"; } 
elsif ($column == 6) { $value = (lc($value) eq "yes") ? 1 : 0;  $SQL = "update patrons set is_enabled=? where home_library_id=? and pid=?"; } 
elsif ($column == 9) { $SQL = "update patrons set password=md5(?) where home_library_id=? and pid=?"; } 
else { print "Content-Type:application/json\n\n" . to_json( { success => 0, data => $query->param('value') } ); exit; }

my $retval = $dbh->do( $SQL, undef, $value, $lid, $pid );

# if patron card updated, need to update it in any active requests (request_group table)


$dbh->disconnect;

if ($column == 9) { $value = '-- password changed --'; }
if (($column == 5) || ($column == 6)) { $value = ($value == 1 ? "yes" : "no"); }

print "Content-Type:application/json\n\n" . to_json( { success => $retval, data => $value } );
