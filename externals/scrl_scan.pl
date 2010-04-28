#!/usr/bin/perl

use ZOOM;

print "test #1 - finding search terms\n";
eval {
    $conn = new ZOOM::Connection("206.45.116.103:210/ILS");

    print("server is '", $conn->option("serverImplementationName"), "'\n");
    $conn->option(preferredRecordSyntax => "usmarc");
    $ss = $conn->scan_pqf('@attr 1=1003 a');
    $n = $ss->size();
    print "$n term(s) found.\n";
    for $i (1 .. $n) {
	print "\t--[Term #" . $i . " (" . ($i - 1) . "th term)]--\n";
	($term, $occurrences) = $ss->term($i-1);
	($displayTerm, $occurrences2) = $ss->display_term($i-1);
	print "\t\t[$term]($occurrences): $displayTerm\n";
    }
};
if ($@) {
    print "Error ", $@->code(), ": ", $@->message(), "\n";
}

exit;

print "\ntest #2 - returning a record\n";
eval {
    if ($L4U) {
	$conn = new ZOOM::Connection("206.45.107.244:210/L4U_Agent"); # The Pas Regional Library
    } else {
	$conn = new ZOOM::Connection("library.gov.mb.ca:210/maplin");
    }
    print("server is '", $conn->option("serverImplementationName"), "'\n");
    $conn->option(preferredRecordSyntax => "usmarc");
    $ss = $conn->scan_pqf('@attr 1=1003 a');
    $n = $ss->size();
    print "scanset size: $n\n";
    my $x = 0;
    my $term;
    my $occurrences;
    print "Looking for occurrences > 0...\n";
    while ($x <= $n) {
	#($term, $occurrences) = $ss->display_term($x);
	($term, $occurrences) = $ss->term($x);
	print "\t[$term]($occurrences)\n";
	print "\tFound one!\n" if ($occurrences > 0);
	last if ($occurrences > 0);
	$x++;
    }
    $rs = $conn->search_pqf('@attr 1=1003 "' . $term . '"');
    $rs_size = $rs->size();
    print "resultset size: $rs_size\n";
    if ($rs_size > 0) {
	print "-[Record #0 (1st record)]--\n";
	print $rs->record(0)->render();
    } else {
	print "No records in result set.\n";
    }
};
if ($@) {
    print "Error ", $@->code(), ": ", $@->message(), "\n";
}


print "\ntest #3 - playing with the cache\n";
eval {
    if ($L4U) {
	$conn = new ZOOM::Connection("206.45.107.244:210/L4U_Agent"); # The Pas Regional Library
    } else {
	$conn = new ZOOM::Connection("library.gov.mb.ca:210/maplin");
    }
    print("server is '", $conn->option("serverImplementationName"), "'\n");
    $conn->option(preferredRecordSyntax => "usmarc");
    $ss = $conn->scan_pqf('@attr 1=1003 a');
    $n = $ss->size();
    print "scanset size: $n\n";
    my $x = 0;
    my $term;
    my $occurrences;
    print "Looking for occurrences > 0...\n";
    while ($x <= $n) {
	#($term, $occurrences) = $ss->display_term($x);
	($term, $occurrences) = $ss->term($x);
	print "\t[$term]($occurrences)\n";
	print "\tFound one!\n" if ($occurrences > 0);
	last if ($occurrences > 0);
	$x++;
    }
    print 'Here is the search: @attr 1=1003 "' . $term . "\"\n";
    $rs = $conn->search_pqf('@attr 1=1003 "' . $term . '"');

    # grab the records from the server into local cache
    $rv = $rs->records(0, $occurrences - 1, 1);
    print "rv: $rv\n";
    print '@$rv: ' . @$rv . "\n";

    $rec1 = $rs->record_immediate(0)
	or print "first record wasn't in cache\n";

    if ($rec1) {
	print $rec1->render();
    }

};
if ($@) {
    print "Error ", $@->code(), ": ", $@->message(), "\n";
}

