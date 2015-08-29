#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use Data::Dumper;

my $SQL = "insert into library_z3950 (
 oid,
 server_address,
 server_port,
 database_name,
 request_syntax, 
 elements, 
 nativesyntax, 
 xslt, 
 index_keyword,
 index_author,
 index_title,
 index_subject,
 index_isbn,
 index_issn,
 index_date,
 index_series
) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

my $pazdir = "../pazpar2/settings";
opendir(my $dh, $pazdir) || die "can't opendir $pazdir: $!";
my @xml = grep { /\.xml$/ && -f "$pazdir/$_" } readdir($dh);
closedir $dh;

foreach my $xml (@xml) {
    print "------------------------\n";
    my %z = ();
    open(my $fh,"<","$pazdir/$xml") or die "cannot open < $xml: $!";
    while (<$fh>) {
	chomp;
	# ignore any special-processing lines... have to do those manually
	if (/pz:name/)          { /value="(.*)"/; $z{org_name} = $1; }
	if (/target=/)          { /target="(.*):(.*)\/(.*)"/; $z{server_address}=$1; $z{server_port}=$2; $z{database_name}=$3; }
	if (/name="symbol"/)    { /value="(.*)"/; $z{symbol} = $1; }
	if (/pz:allow/)         { /value="(.*)"/; $z{enabled} = $1; }
	if (/pz:cclmap:term/)   { /value="(.*)"/; $z{index_keyword} = $1; }
	if (/pz:cclmap:au/)     { /value="(.*)"/; $z{index_author} = $1; }
	if (/pz:cclmap:ti/)     { /value="(.*)"/; $z{index_title} = $1; }
	if (/pz:cclmap:su/)     { /value="(.*)"/; $z{index_subject} = $1; }
	if (/pz:cclmap:isbn/)   { /value="(.*)"/; $z{index_isbn} = $1; }
	if (/pz:cclmap:issn/)   { /value="(.*)"/; $z{index_issn} = $1; }
	if (/pz:cclmap:date/)   { /value="(.*)"/; $z{index_date} = $1; }
	if (/pz:cclmap:series/) { /value="(.*)"/; $z{index_series} = $1; }
	if (/pz:requestsyntax/) { /value="(.*)"/; $z{request_syntax} = $1; }
	if (/pz:elements/)      { /value="(.*)"/; $z{elements} = $1; }
	if (/pz:nativesyntax/)  { /value="(.*)"/; $z{nativesyntax} = $1; }
	if (/pz:xslt/)          { /value="(.*)"/; $z{xslt} = $1; }
    }
    close($fh);

    foreach my $key (sort keys %z) {
	print "\t$key\t$z{$key}\n";
    }

    if ($z{symbol}) {
	my $org = $dbh->selectrow_hashref("select oid from org where symbol=?",undef,$z{symbol});
	if ($org) {
	    my $zs = $dbh->selectrow_hashref("select oid from library_z3950 where oid=?",undef,$org->{"oid"});
	    if ($zs) {
		# an entry already exists for this
		print "Entry exists for $xml [oid: " . $org->{"oid"} . "], not loading\n";
	    } else {
		my $rv = $dbh->do($SQL,undef,
				  $org->{"oid"},
				  $z{server_address},
				  $z{server_port},
				  $z{database_name},
				  $z{request_syntax},
				  $z{elements},
				  $z{native_syntax},
				  $z{xslt},
				  $z{index_keyword},
				  $z{index_author},
				  $z{index_title},
				  $z{index_subject},
				  $z{index_isbn},
				  $z{index_issn},
				  $z{index_date},
				  $z{index_series}
		    );
		if (not defined $rv) {
		    print "Unable to add entry for $xml [oid: " . $org->{"oid"} . "]\n";
		} else {
		    print "Add entry for $xml [oid: " . $org->{"oid"} . "], added $rv\n";
		}
	    }
	} else {
	    print "No org matching symbol [" . $z{symbol} . "] - " . $z{org_name} . ", not loading\n";
	}
    } else {
	print "Missing symbol in $xml, not loading\n";
    }
}
