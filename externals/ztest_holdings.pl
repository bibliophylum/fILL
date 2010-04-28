#!/usr/bin/perl
use ZOOM;
use MARC::Record;
use MARC::File::XML;
use XML::Simple;
use Data::Dumper;

eval {
    $conn = new ZOOM::Connection("library.gov.mb.ca:210/maplin");
    print "\n--[ Connection ]-------\n";
    print("server is '", $conn->option("serverImplementationName"), "'\n");
    #$conn->option(preferredRecordSyntax => "usmarc");
    $conn->option(preferredRecordSyntax => "opac");
};
if ($@) {
    print "Error ", $@->code(), ": ", $@->message(), "\n";

} else {
    eval {
	print "\n--[ title search ]----\n";
#	$pqf = '@attr 1=4 "the book of positive quotations"';
#	$pqf = '@attr 1=4 "ducks"';
	$pqf = '@attr 1=4 "case for mars"';
	print "$pqf\n";
	$rs = $conn->search_pqf($pqf);
	$n = $rs->size();
	print "$n record(s) found.\n";
	if ($n > 0) {
	    print "-[Record #0 (1st record)]--\n";
	    print $rs->record(0)->render();
	    #print $rs->record(0)->raw() . "\n";
	    print "---------------------------\n";
	    $xml = $rs->record(0)->get("opac");
	    print $xml . "\n";
	    print "---------------------------\n";
	    my $marc = MARC::Record->new_from_xml( $xml );
	    print "Title: " . $marc->title() . "\n";
	    print "---------------------------\n";
	    my $opac = XMLin( $xml, ForceArray => ['holdings'] );
	    #print Dumper( $opac->{holdings} );
	    foreach my $href ( @{$opac->{holdings} }) {
		print "Location: " . $href->{holding}->{localLocation} . "\n";
	    }
	}
    };
}

