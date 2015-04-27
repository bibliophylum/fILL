#!/usr/bin/perl

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
my $id = $query->param('id');
my $lid = $query->param('lid');
my $circs = $query->param('circs');


my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $SQL = "select barcode, ts from rotations where id=?";
my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $id );

$SQL = "select barcode, lid, circs from rotations_stats where barcode=? and lid=? and ts_start=?";
my $exists = $dbh->selectall_arrayref($SQL, { Slice => {} }, $aref->[0]->{barcode}, $lid, $aref->[0]->{ts});
my $retval;
if ((defined $exists) && (scalar(@$exists) > 0)) {  # should only every be 1 or 0
    # update existing
    $SQL = "update rotations_stats set circs=?, ts_end=now() where barcode=? and lid=? and ts_start=?";
    $retval = $dbh->do( $SQL, undef, $circs, $aref->[0]->{barcode}, $lid, $aref->[0]->{ts} );
} else {
    # new stat
    $SQL = "insert into rotations_stats (barcode, lid, ts_start, ts_end, circs) values (?,?,?,now(),?)";
    $retval = $dbh->do( $SQL, undef, $aref->[0]->{barcode}, $lid, $aref->[0]->{ts}, $circs );
}
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
