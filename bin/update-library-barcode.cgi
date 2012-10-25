#!/usr/bin/perl

use CGI;
use DBI;
use JSON;
use Data::Dumper;

my $query = new CGI;
#print STDERR Dumper($query->param('value'));  # ducks
#print STDERR Dumper($query->param('id'));
#print STDERR Dumper($query->param('row_id')); # 85_137
#print STDERR Dumper($query->param('column'));

my ($lid,$borrower) = split /_/, $query->param('row_id');
my $SQL = "update library_barcodes set barcode=? where lid=? and borrower=?";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $retval = $dbh->do( $SQL, undef, $query->param('value'), $lid, $borrower );
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval, data => $query->param('value') } );
