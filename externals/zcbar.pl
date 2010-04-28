#!/usr/bin/perl
#
# Program: zcbar.pl
# Purpose: extract barcodes from zerocirc MARC records and add them to barcode field
#          of zerocirc table
# Author:  David Christensen
# Notes:   Have to be VERY CAREFUL: if you don't update claimed_timestamp yourself,
#          MySQL will update it automatically with the default of CURRENT_TIMESTAMP
#          (meaning that you lose whatever value was in there before!)
# Date:    2008-07-04
# Mods:

use DBI;
use MARC::Record;

my $max = 50645;
#my $max = 5;
my $i = 1;

# Set up database connection
my $dbh = DBI->connect("DBI:mysql:database=maplin;mysql_server_prepare=1",
		      "mapapp",
		      "maplin3db", 
		      {LongReadLen => 65536} 
	);

#my $sel = $dbh->prepare("SELECT id, claimed_timestamp, marc_blob FROM zerocirc");
my $sel = $dbh->prepare("SELECT id, claimed_timestamp, marc_blob FROM zerocirc");
my $rv = $sel->execute or die $sel->errstr;


while ($i <= $max) {
    my $ary_ref = $sel->fetchrow_arrayref;
    my $marc = MARC::Record::new_from_usmarc( $ary_ref->[2] );
    my $barcode = $marc->subfield('949',"b");
    print "ID: ", $ary_ref->[0], "\tBC [", $barcode, "]\t", $ary_ref->[1], "\t", $marc->title(), "\n";

#    my $rows = $dbh->do("UPDATE hmm3 SET barcode=?, claimed_timestamp=? WHERE id=?",
    my $rows = $dbh->do("UPDATE zerocirc SET barcode=?, claimed_timestamp=? WHERE id=?",
			undef,
			$barcode,
			$ary_ref->[1],
			$ary_ref->[0],
	);
    $i++;
}

