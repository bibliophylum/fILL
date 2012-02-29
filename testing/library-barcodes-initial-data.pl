#!/usr/bin/perl

use DBI;
use Data::Dumper;

my %prefix = (
    "MGI"	=> "264400",
    "MSTG"	=> "267840",
    "MBBB"	=> "262220",
    "MVBB"	=> "268220",
    "MSJB"	=> "267520",
    "MNDP"	=> "266390",
    "MTPL"	=> "268750",
    "MIBR"	=> "262700",
    "MSAD"	=> "267230",
    "MSAG"	=> "267240",
    "MSCL"	=> "267250",
    "MLB"	=> "265200",
    "MS"	=> "267000",
    "MSA"	=> "267200",
    "MBOM"	=> "262660",
    "ME"	=> "263000",
    "MVE"	=> "268300",
    "MMCA"	=> "266220",
    "MCB"	=> "262200",
    "MDB"	=> "263200",
    "MBBR"	=> "262270",
    "MCH"	=> "262400",
    "MEPL"	=> "263750",
    "MEL"	=> "263500",
    "MAB"	=> "262200",
    "MGE"	=> "264300",
    "MRB"	=> "267200",
    "MFF"	=> "263300",
    "MSOG"	=> "267640",
    "MHH"	=> "264400",
    "MSTE"	=> "267830",
    "MSTP"	=> "267870",
    "MSSM"	=> "267760",
    "MLDB"	=> "265320",
    "MCCB"	=> "262220",
    "MKL"	=> "265500",
    "MLR"	=> "265700",
    "MLLC"	=> "265520",
    "MMA"	=> "266200",
    "MMR"	=> "266700",
    "MMNN"	=> "266660",
    "MBB"	=> "262200",
    "MSRN"	=> "267760",
    "MDPBR"	=> "262727",
    "MDPBI"	=> "262724",
    "MDPBO"	=> "262726",
    "MDA"	=> "263200",
    "MDPER"	=> "262737",
    "MDPFO"	=> "262736",
    "MDPGP"	=> "262747",
    "MDPGL"	=> "262745",
    "MDPGV"	=> "262748",
    "MDPHA"	=> "262742",
    "MDPLA"	=> "262752",
    "MDP"	=> "262700",
    "MDPMC"	=> "262762",
    "MDPMI"	=> "262764",
    "MDPOR"	=> "262776",
    "MDPRO"	=> "262776",
    "MDPSL"	=> "262775",
    "MDPSI"	=> "262774",
    "MDPST"	=> "262778",
    "MDPWP"	=> "262797",
    "MLPJ"	=> "265750",
    "MPFN"	=> "267360",
    "MPM"	=> "267600",
    "MP"	=> "267000",
    "MPLP"	=> "267570",
    "MRIP"	=> "267470",
    "MBA"	=> "262200",
    "MRA"	=> "267200",
    "MSEL"	=> "267350",
    "MRP"	=> "267700",
    "MRO"	=> "267600",
    "MRD"	=> "267300",
    "MBI"	=> "262400",
    "MSL"	=> "267500",
    "MAOW"	=> "262690",
    "MMIOW"	=> "266466",
    "MMOW"	=> "266690",
    "MWOW"	=> "269690",
    "MTSIR"	=> "268747",
    "MSTOS"	=> "267867",
    "MESMN"	=> "263766",
    "MESP"	=> "263770",
    "MESM"	=> "263760",
    "MDS"	=> "263700",
    "MSTR"	=> "267870",
    "MTP"	=> "268700",
    "MTH"	=> "268400",
    "MMVR"	=> "266870",
    "MHP"	=> "264700",
    "TWAS"	=> "289270",
    "MCNC"	=> "262620",
    "MGW"	=> "264900",
    "MHW"	=> "264900",
    "MNW"	=> "266900",
    "MBW"	=> "262900"
    );

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

my %lids;
foreach my $key (sort keys %prefix) {
    @lid_ary = $dbh->selectrow_array("select lid from libraries where name=?", undef, $key);
    next unless (@lid_ary);
    $lids{$key} = $lid_ary[0];
}

my %seen;
my $cnt = 1;
$dbh->{AutoCommit} = 0;  # enable transactions, if possible
$dbh->{RaiseError} = 1;

foreach my $key (sort keys %prefix) {
    print STDERR "          \r" . $cnt++;
#    print "$key:\n";
    foreach my $bkey (sort keys %lids) {
	my $barcode = $prefix{$key};
	$seen{$barcode}++;
	$barcode = sprintf("%.7s%02d%02d%03d", $barcode, $seen{$barcode}, 1, $lids{$bkey});
#	print "\t$bkey\t$barcode\n";
	eval {	    
	    $dbh->do( "insert into library_barcodes (lid, borrower, barcode) values (?,?,?)", 
		      undef, $lids{$key}, $lids{$bkey}, $barcode );	
	    $dbh->commit;
	};
	if ($@) {
	    warn "$key / $bkey: Transaction aborted because $@";
	    eval { $dbh->rollback };
	}
    }
}

$dbh->disconnect;

