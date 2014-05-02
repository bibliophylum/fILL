#!/usr/bin/perl

use CGI;
use DBI;
use MARC::Record;
use JSON;
use Data::Dumper;

my $query = new CGI;
my $lid = $query->param('lid');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");
my $SQL = "select name from libraries where lid=?";
my $aref = $dbh->selectrow_arrayref($SQL, undef, $lid );
my $libsym = $aref->[0];
my $filename = $libsym . ".mrc";

$SQL = "select holdings_field,barcode_subfield,callno_subfield,library_subfield,library_default,location_subfield,location_default,collection_subfield,collection_default from rotations_lib_holdings_fields where lid=?";
$holdings = $dbh->selectrow_hashref($SQL, undef, $lid );
#print Dumper($holdings);

$SQL = "select marc, barcode, callno from rotations where current_library=? and ts >= (now() - interval '1 month')";
$aref = $dbh->selectall_arrayref($SQL, undef, $lid );
$dbh->disconnect;

open(MRC,'>',"/opt/fILL/rotations-MARC/$filename") or die $!;
binmode(MRC, ":utf8");
#open(MRC,'>',"/tmp/$filename") or die $!;

foreach my $selectdata (@$aref) {
    my $marc = MARC::Record->new_from_usmarc( $selectdata->[0] );
    if ($marc) {
	my $holdingsTag = '949';
	my $barcode_subfield = 'b';
	my $callno_subfield = 'd';
	my $library_subfield = 'a';
	my $library_default = $libsym;
	my $location_subfield = 'l';
	my $location_default = $libsym;
	my $collection_subfield = 'c';
	my $collection_default = 'Stacks';
	if ($holdings) {
	    $holdingsTag = $holdings->{holdings_field} if (defined $holdings->{holdings_field});
	    $barcode_subfield    = $holdings->{barcode_subfield}    if (defined $holdings->{barcode_subfield});
	    $callno_subfield     = $holdings->{callno_subfield}     if (defined $holdings->{callno_subfield});
	    $library_subfield    = $holdings->{library_subfield}    if (defined $holdings->{library_subfield});
	    $library_default     = $holdings->{library_default}     if (defined $holdings->{library_default});
	    $location_subfield   = $holdings->{location_subfield}   if (defined $holdings->{location_subfield});
	    $location_default    = $holdings->{location_default}    if (defined $holdings->{location_default});
	    $collection_subfield = $holdings->{collection_subfield} if (defined $holdings->{collection_subfield});
	    $collection_default  = $holdings->{collection_default}  if (defined $holdings->{collection_default});
	}
	my @oldholdings = $marc->field( '949' );
	$marc->delete_fields( @oldholdings );
	@oldholdings = $marc->field( '852' );
	$marc->delete_fields( @oldholdings );
	@oldholdings = $marc->field( '090' );
	$marc->delete_fields( @oldholdings );
	my @oldholdings = $marc->field( $holdingsTag );
	$marc->delete_fields( @oldholdings );
	my $hf = MARC::Field->new( $holdingsTag, ' ', ' ',
				   $barcode_subfield => $selectdata->[1],
				   $callno_subfield => $selectdata->[2],
				   $library_subfield => $library_default,
				   $location_subfield => $location_default,
				   $collection_subfield => $collection_default
	    );
	if ($hf) {
	    $marc->insert_fields_ordered( $hf );
	}
	print MRC $marc->as_usmarc();
    }
}
close MRC;

print "Content-Type:application/json\n\n" . to_json( { filename => "/rotations-MARC/$filename" } );
