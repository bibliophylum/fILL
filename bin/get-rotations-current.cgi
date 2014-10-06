#!/usr/bin/perl

use CGI;
use DBI;
use JSON;
use GD::Barcode;
use GD::Barcode::Code39;
use MIME::Base64;

my $query = new CGI;
my $lid = $query->param('lid');

my $SQL = "select 
 r.id,
 r.callno,
 r.title, 
 r.author,
 r.barcode,
 r.ts as timestamp
from 
 rotations r
 left join rotations_stats s on (s.barcode=r.barcode and s.lid=r.current_library and s.ts_start=r.ts)
where 
  r.current_library=? 
";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
                       "mapapp",
                       "maplin3db",
                       {AutoCommit => 1, 
                        RaiseError => 1, 
                        PrintError => 0,
                       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $lid );

# generate barcodes (code39 requires '*' as start and stop characters
foreach my $rotationItem (@$aref) {
    if (( $rotationItem->{barcode} ) && ( $rotationItem->{barcode} =~ /\d+/)) {
	$rotationItem->{"barcode_image"} = encode_base64(GD::Barcode::Code39->new( '*' . $rotationItem->{barcode} . '*' )->plot->png);
    }
}

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { rotation => $aref } );
