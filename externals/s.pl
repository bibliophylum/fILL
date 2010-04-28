#!/usr/bin/perl

use ZOOM;

if ($#ARGV != 3) {
    print "usage: s @attr 1=4 dinosaur\n";
    exit;
}



eval {
    $conn = new ZOOM::Connection("library.gov.mb.ca:210/maplin");
    print("server is '", $conn->option("serverImplementationName"), "'\n");
    $conn->option(preferredRecordSyntax => "usmarc");
    $rs = $conn->search_pqf('@attr 1=4 dinosaur');
    $n = $rs->size();
    print "$n record(s) found.\n";
    print "-[Record #2 (3rd record)]--\n";
    print $rs->record(2)->render();
};
if ($@) {
    print "Error ", $@->code(), ": ", $@->message(), "\n";
}
