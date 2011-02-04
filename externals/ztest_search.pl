#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use ZOOM;

my %opts = ();
GetOptions(\%opts, 'help', 'connectString=s', 'target=s', 'list');

if (($opts{help}) || ((not defined $opts{connectString}) && (not defined $opts{target}) && (not defined $opts{list}))) {
    print "\nusage: $0 [--help] [--connectString xxx.xxx.xxx.xxx:yyy/dbname] [--target name] [--list]\n";
    print "\t\n";
    print "\tThis example script does some fairly simplistic testing of the given zServer.\n";
    print "\tIt will search for the title keyword 'ducks', then the author keyword 'hemingway', and then\n";
    print "\tthe subject keywords 'mars planet'.\n";
    print "\t\n";
    print "\tFor each of those searches, it retrieves a batch of records and then displays the first record.\n";
    print "\t\n";
    print "\tThis example script does not search combined indexes (eg: author 'hemingway' and subject 'mars planet'),\n";
    print "\tnor does it attempt to be a tutorial on building pqf query strings, using the Perl ZOOM module, using the\n";
    print "\tYAZ toolkit from IndexData, or ISO 23950.\n";
    print "\t\n";
    exit;
}

# Some sample zservers
my @zservers = ( { name => 'thepas', connection => '206.45.107.244:210/Default' },
		 { name => 'flinflon', connection => '206.45.107.155:210/Default' },
		{ name => 'winnipeg', connection => '198.163.53.31:210/horizon' },
		{ name => 'loc', connection => 'z3950.loc.gov:7090/Voyager' },
		{ name => 'oca', connection => 'econtent.indexdata.com:210/oca-toronto' },
		{ name => 'gutenberg', connection => 'econtent.indexdata.com:210/gutenberg' },
		{ name => 'portage', connection => '24.79.32.253:210/Destiny' },
		{ name => 'lakeland', connection => '206.45.118.101:210/InsigniaLibrary' },
		{ name => 'legislative', connection => 'library.gov.mb.ca:211/legislative' },
    );

if ($opts{list}) {
    print "name                  connection\n------------------------------------------\n";
    foreach my $href (@zservers) {
	printf "%20s  %s\n", $href->{name}, $href->{connection};
    }
    exit;
}

my $connectString;
if ($opts{target}) {
    foreach my $href (@zservers) {
	$connectString = $href->{connection} if ($href->{name} eq $opts{target});
    }
    unless ($connectString) {
	print "No matching target name.  Try:  $0 --list\n";
	exit;
    }
} elsif ($opts{connectString}) {
    $connectString = $opts{connectString};
} else {
    print "Must specify either a target or a connection string.  Try $0 --help\n";
    exit;
}

my $conn;
eval {
    $conn = new ZOOM::Connection( $connectString );

    print "\n--[ Connection ]-------\n";
    print("server is '", $conn->option("serverImplementationName"), "'\n");
    $conn->option(preferredRecordSyntax => "usmarc");
    #$conn->option(preferredRecordSyntax => "opac");
};
if ($@) {
    print "Error ", $@->code(), ": ", $@->message(), "\n";

} else {
    eval {
	print "\n--[ title search ]----\n";
	my $pqf = '@attr 1=4 @attr 2=3 @attr 4=2 "ducks"';
	print "$pqf\n";
	my $rs = $conn->search_pqf($pqf);
	my $n = $rs->size();
	print "$n record(s) found.\n";
	if ($n > 0) {
	    $n = 50 if ($n > 50);
	    print "fetching a batch of $n records\n";
	    $rs->records(0, $n, 0);

	    print "-[Record #0 (1st record)]--\n";
	    print "--[ raw data ]--\n";
	    print $rs->record(0)->raw();
	    print"\n--[ rendered ]--\n";
	    print $rs->record(0)->render();
	}
    };
    if ($@) {
	print "Error ", $@->code(), ": ", $@->message(), "\n";
    } else {
	eval {
	    print "\n--[ author search ]----\n";
	    my $pqf = '@attr 1=1003 @attr 2=3 @attr 4=2 "hemingway"';
	    print "$pqf\n";
	    my $rs = $conn->search_pqf($pqf);
	    my $n = $rs->size();
	    print "$n record(s) found.\n";
	    if ($n > 0) {
		$n = 50 if ($n > 50);
		print "fetching a batch of $n records\n";
		$rs->records(0, $n, 0);

		print "-[Record #0 (1st record)]--\n";
		print "--[ raw data ]--\n";
		print $rs->record(0)->raw();
		print"\n--[ rendered ]--\n";
		print $rs->record(0)->render();
	    }
	};
	if ($@) {
	    print "Error ", $@->code(), ": ", $@->message(), "\n";
	} else {
	    eval {
		print "\n--[ subject search ]----\n";
		my $pqf = '@attr 1=21 @attr 2=3 @attr 4=1 "mars planet"';
		print "$pqf\n";
		my $rs = $conn->search_pqf($pqf);
		my $n = $rs->size();
		print "$n record(s) found.\n";
		if ($n > 0) {
		    $n = 50 if ($n > 50);
		    print "fetching a batch of $n records\n";
		    $rs->records(0, $n, 0);

		    print "-[Record #0 (1st record)]--\n";
		    print "--[ raw data ]--\n";
		    print $rs->record(0)->raw();
		    print"\n--[ rendered ]--\n";
		    print $rs->record(0)->render();
		}
	    };
	    if ($@) {
		print "Error ", $@->code(), ": ", $@->message(), "\n";
	    }
	}
    }
}

