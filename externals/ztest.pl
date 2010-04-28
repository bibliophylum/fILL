#!/usr/bin/perl
use Getopt::Long;  # worry about it later... too tired... must sleep.
use ZOOM;

my $lib = shift;
my $preferredRecordSyntax = shift;

my @conn = (
    { library => "PLS", conn => "library.gov.mb.ca:210/maplin" },
    { library => "Jake Epp", conn => "jakeepp.gotdns.com:210/jakeepp_ils"},
    { library => "The Pas", conn => "206.45.107.244:210/L4U_Agent"},
    { library => "Flin Flon", conn => "206.45.107.155:210/L4U_Agent"},    
    { library => "unknown", conn => "204.112.214.69:210/L4U_Agent"},
    { library => "Jolys", conn => "66.244.209.14:210/L4U_Agent"},
    { library => "Border (Main)", conn => "216.36.186.84:210/L4U_Agent"},
    { library => "Border (Elkhorn)", conn => "216.36.186.86:210/L4U_Agent"},
    { library => "Evergreen (Arborg)", conn => "206.45.206.151:210/L4U_Agent"},
    { library => "Thompson", conn => "catalogue.thompsonlibrary.com:210/ILS"},
    { library => "Saint-Joachim", conn => "66.244.212.218:210/biblionet"},
    { library => "Killarney", conn => "killib.dyndns.org:210/Killarney"},
    { library => "Manitou", conn => "manitoulibrary.gotdns.com/library:210/library"},
    { library => "Parkland", conn => "207.161.70.103:5666/LSPacZ"},
    { library => "Melita", conn => "216.130.92.141:210/Melita_ILS"},
    { library => "Portage", conn => "circ.portagelibrary.com:210/collection_access"},
    { library => "Portage Mark II", conn => "24.79.32.254:210/Main"},
    { library => "Selkirk", conn => "24.76.72.252:210/Main"},
    { library => "", conn => ""},
    );

#my $lib = 0;

if ($lib eq "-h") {
    my $i = 0;
    foreach my $library (@conn) {
	print $i++, ": ", $library->{library}, ", ", $library->{conn}, "\n";
    }
    exit;
}

my $conn;
my $pqf;

eval {
    print "\n--[ Connection ]-------\n";
    print("library is '", $conn[$lib]{library},"'\n");
    print("conn is '", $conn[$lib]{conn},"'\n");

#    print "--[ PING test ]--------\n";
#    my $ip = $conn[$lib]{conn};
#    $ip =~ s|^(.*):.*$|$1|;
#    print "$ip\n";
#    print `ping -c 3 $ip`;

    print "\n--[ Z39.50 test ]------\n";
    $conn = new ZOOM::Connection($conn[$lib]{conn});
    print("server is '", $conn->option("serverImplementationName"), "'\n");
#    $conn->option(preferredRecordSyntax => "usmarc");
#    $conn->option(preferredRecordSyntax => "opac");
    $conn->option(preferredRecordSyntax => $preferredRecordSyntax);
    $conn->option(timout => 600); # where does this number come from?
};
if ($@) {
    print "Error ", $@->code(), ": ", $@->message(), "\n";

} else {
    eval {
	print "\n--[ title search ]----\n";
	$pqf = '@attr 1=4 "hunting ducks and geese"';
	print "$pqf\n";
	$rs = $conn->search_pqf($pqf);
	$n = $rs->size();
	print "$n record(s) found.\n";
	if ($n > 0) {
	    print "-[Record #0 (1st record)]--\n";
	    print $rs->record(0)->render();
	}
    };
    if ($@) {
	print "Error ", $@->code(), ": ", $@->message(), "\n";
    } else {
	eval {
	    print "\n--[ author search ]----\n";
	    $pqf = '@attr 1=1003 "asimov"';
	    print "$pqf\n";
	    $rs = $conn->search_pqf($pqf);
	    $n = $rs->size();
	    print "$n record(s) found.\n";
	    if ($n > 0) {
		print "-[Record #0 (1st record)]--\n";
		print $rs->record(0)->render();
	    }
	};
	if ($@) {
	    print "Error ", $@->code(), ": ", $@->message(), "\n";
	} else {
	    eval {
		print "\n--[ subject search ]----\n";
		$pqf = '@attr 1=21 "mars planet"';
		print "$pqf\n";
		$rs = $conn->search_pqf($pqf);
		$n = $rs->size();
		print "$n record(s) found.\n";
		if ($n > 0) {
		    print "-[Record #0 (1st record)]--\n";
		    print $rs->record(0)->render();
		}
	    };
	    if ($@) {
		print "Error ", $@->code(), ": ", $@->message(), "\n";
	    }
	}
    }
}

# This is from maplin3-zsearch.pl
#my $pqf = "";
#if ($index eq "title") {
#    $pqf = "\@attr 1=4";
#} elsif ($index eq "author") {
#    $pqf = "\@attr 1=1003";
#} elsif ($index eq "subject") {
#    $pqf = "\@attr 1=21";
#} else {
#    $pqf = "\@attr 1=1016";
#}
#$pqf .= " \@attr 2=3 \@attr 4=2 \"$search_for\"";
