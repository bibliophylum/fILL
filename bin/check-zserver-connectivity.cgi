#!/usr/bin/perl
#use strict;
use CGI;
use CGI::Session;
use JSON;
use ZOOM;
use MARC::Record;
use Data::Dumper;

no if $] >= 5.017011, warnings => 'experimental::smartmatch';  # smartmatch ("~~") has been made experimental.

my $query = new CGI;
my $session;
if (($ENV{GATEWAY_INTERFACE}) && ($ENV{GATEWAY_INTERFACE} =~ /CGI/)) {  # only worry about session if we're a cgi
    $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
    if (($session->is_expired) || ($session->is_empty)) {
	print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
	exit;
    }
}
my $libsym = $query->param('libsym');
my $keepLog = $query->param('log') || 0;
my $result_href = { "success" => 0, 
		    "libsym" => $libsym,
		    "zServer_status" => {
			"connection" => {
			    "success" => -1,
			    "status" => "...",
			    "connectionString" => "...",
			},
			"search" => {
			    "success" => -1,
			    "status" => "...",
			    "type" => "search",
			    "pqf" => "...",
			    "found" => 0,
			},
			"record" => {
			    "success" => -1,
			    "status" => "...",
			    "author" => "...",
			    "title" => "...",
			},
		    },
		    "log" => "",
};

my @SpruceLibraries = qw(MWPL MAOW MMIOW MMOW MWOW MBOM MMA MSTR AB MWP MSTOS MTSIR MMCA MVE ME MS MSOG MDB MPLP MSSC MEC MNH MSRH MTK MTPK MWMW MRD MBI MSCL);
my @ParklandLibraries = qw(MDPGL MDPGP MDPMC MDPHA MDA MDPSL MDPFO MDPBO MDPGV MDPBR MDPLA MDPBI MDPSI MDPST MDPMI MDPRO MDPOR MDPWP MDPER MDPSLA MDP MRO);
my @WesternLibraries = qw(MCNC MHW MGW MNW MBW);

if ($libsym =~ /^[A-Z]{2,7}$/) {  # some sanity checking
    # pre-Perl 5.10, you'd have to use something like (untested):
    #    @SpruceLibraries = grep (/\Q$libsym\E/,@SpruceLibraries);
    #    if (scalar @SpruceLibraries == 1) { $libsym = "SPRUCE" }

    # smartmatch has been made 'experimental'....
    if ($libsym ~~ @SpruceLibraries) {
	$libsym = "SPRUCE";
    }
    if ($libsym ~~ @ParklandLibraries) {
	$libsym = "MDA";
    }
    if ($libsym ~~ @WesternLibraries) {
	$libsym = "MBW";
    }
    $result_href->{libsym} = $libsym;

    # see if that symbol shows up in any of the pazpar2/settings/ files:
    my $cmd = '/bin/grep "name=\"symbol\" value=\"' . $libsym . '\"" /opt/fILL/pazpar2/settings/*.xml';
    #print STDERR "cmd [$cmd]\n";
    my @f = `$cmd`;

    if (scalar @f == 1) {
	my $t = $f[0];
	chomp $t;
	if ($t =~ /set target=/) {
	    $t =~ s/^.*(target=.*) name=.*/$1/;
	} else {
	    # Individual library profile... doesn't have connection info in the <set ...>,
	    # instead, it shows up once in the "settings" line (<settings target=...>)
	    # (This is now the default!)
	    my $fn = $t;
	    $fn =~ s/^(.*\.xml):.*/$1/;
	    open(my $file, '<', $fn) or die "Can't open $fn for read: $!";
	    # these files are tiny, so just slurp the whole thing:
	    my @lines = <$file>;
	    foreach (@lines) {
		next unless /^<settings /;
		chomp;
		my $line = $_;
		$line =~ s/^<settings (target=.*)>$/$1/;
		$t = $line;
		last;
	    }
	    close $file;
	}
	$t =~ s/\"//g;
	my ($garbage,$target) = split(/=/, $t);

	$result_href = _test_zserver($result_href, $target);
#	# temporary, for testing
#	my $log = $result_href->{log} if ($keepLog);
#	delete $result_href->{log};
    } else {
	$result_href->{success} = 0;
	$result_href->{libsym} => "$libsym connection information not found.";
    }
}
#print STDERR "result:\n" . Dumper($result_href) . "\n";
my $success = 0;
if (($result_href->{zServer_status}{connection}) && ($result_href->{zServer_status}{connection}{success})
    && ($result_href->{zServer_status}{search}) && ($result_href->{zServer_status}{search}{success})
    && ($result_href->{zServer_status}{record}) && ($result_href->{zServer_status}{record}{success})) {
    $success = 1;
}
$result_href->{success} = $success;

#print "Content-Type:application/json\n\n" . to_json( { success => $success, libsym => $libsym, zServer_status => $result_href } );
print "Content-Type:application/json\n\n" . to_json( $result_href );

#print Dumper($result_href);
exit;

#--------------------------------------------------------------------------------
# INTERNAL
# parameter: "xxx.xxx.xxx.xxx:port/dbname"
# parameter: preferred record syntax (eg: "usmarc", "opac")
# parameter: element set ('b' or 'f')
# parameter: pqf string
# parameter: username (if required, otherwise use undef)
# parameter: password (if required, otherwise use undef)
# parameter: scan (1 to do a scan instead of a search)
#
sub _test_zserver {
    my $result_href = shift;
    my $connection_string = shift;
    my $preferredRecordSyntax = shift;
    my $elementSet = shift;
    my $pqf = shift;
    my $usr = shift;
    my $pwd = shift;
    my $scan = shift;

    $preferredRecordSyntax = "usmarc" unless ($preferredRecordSyntax);
    $elementSet = "F" unless ($elementSet);  # TLC server doesn't recognize 'f', but does recognize 'F'... standard says it is case insensitive.
    $pqf = '@attr 1=4 "ducks"' unless ($pqf);

    my $conn;
    my $rs;
    my $n;

    $result_href->{log} = "";

    $result_href->{zServer_status}{connection}{connectionString} = $connection_string;
    $result_href->{log} .= "\n--[ Connection ]-------\n" if ($keepLog);
    $result_href->{log} .= "$connection_string\n" if ($keepLog);
    $result_href->{log} .= "preferredRecordSyntax set to: $preferredRecordSyntax\n" if ($keepLog);

    eval {
	my $o1 = new ZOOM::Options(); $o1->option(user => $usr);
	my $o2 = new ZOOM::Options(); $o2->option(password => $pwd);
	my $otmp = new ZOOM::Options($o1, $o2);

	my $o3 = new ZOOM::Options(); $o3->option(preferredRecordSyntax => $preferredRecordSyntax);
	my $otmp2 = new ZOOM::Options($otmp, $o3);

	my $o4 = new ZOOM::Options(); $o4->option(elementSetName => $elementSet);
	my $opts = new ZOOM::Options($otmp2, $o4);
	$conn = create ZOOM::Connection($opts);
	$conn->connect($connection_string); # Uses the specified username and password
    };

    if ($@) {
	$result_href->{zServer_status}{connection}{success} = 0;
	$result_href->{zServer_status}{connection}{status} = "Error " . $@->code() . ": " . $@->message();
	$result_href->{log} .= "Error " . $@->code() . ": " . $@->message() . "\n" if ($keepLog);
    } else {
	$result_href->{zServer_status}{connection}{success} = 1;
	$result_href->{zServer_status}{connection}{status} = "Connection successful";
	if ($scan) {
	    # scan
	    eval {

		$result_href->{zServer_status}{search}{pqf} = $pqf;
		$result_href->{log} .= "\n--[ scan ]----\n" if ($keepLog);
		$result_href->{log} .= "$pqf\n" if ($keepLog);
		my $ss = $conn->scan_pqf($pqf);
		$n = $ss->size();
		$result_href->{log} .= "$n term(s) found.\n" if ($keepLog);
		$result_href->{zServer_status}{search}{found} = $n;
		for my $i (1 .. $n) {
		    $result_href->{log} .=  "\t--[Term #" . $i . " (" . ($i - 1) . "th term)]--\n" if ($keepLog);
		    my ($term, $occurrences) = $ss->term($i-1);
		    my ($displayTerm, $occurrences2) = $ss->display_term($i-1);
		    $result_href->{log} .=  "\t\t[$term]($occurrences): $displayTerm\n" if ($keepLog);
		}
	    };
	    if ($@) {
		$result_href->{zServer_status}{search}{success} = 0;
		$result_href->{zServer_status}{search}{type} = "scan";
		$result_href->{zServer_status}{search}{status} = "Error " . $@->code() . ": " . $@->message();
		$result_href->{log} .= "Error " . $@->code() . ": " . $@->message() . "\n" if ($keepLog);
	    } else {
		$result_href->{zServer_status}{search}{success} = 1;
		$result_href->{zServer_status}{search}{type} = "scan";
		$result_href->{zServer_status}{search}{status} = "Scan successful";
	    }
	} else {
	    # search
	    eval {
		$result_href->{zServer_status}{search}{pqf} = $pqf;
		$result_href->{log} .= "\n--[ search ]----\n" if ($keepLog);
		$result_href->{log} .= "$pqf\n" if ($keepLog);
		$rs = $conn->search_pqf($pqf);
		$n = $rs->size();
		$result_href->{log} .= "$n record(s) found.\n" if ($keepLog);
		$result_href->{zServer_status}{search}{found} = $n;
		
		$n = 3 if ($n > 3); # let's be reasonable

		$result_href->{zServer_status}{record}{title} = "";
		$result_href->{zServer_status}{record}{author} = "";
		
		if ($n > 0) {
		    $rs->records(0, $n, 0); # prefetch
		    
		    my $x = 0;
		    while ($x < $n) {
			if ($x == 0) {
			    my $marc = MARC::Record->new_from_usmarc( $rs->record($x)->raw() );
			    if ($marc) {
				$result_href->{zServer_status}{record}{title} = $marc->title();
				$result_href->{zServer_status}{record}{author} = $marc->author();
				if (($result_href->{zServer_status}{record}{title}) && (length($result_href->{zServer_status}{record}{title}) > 0)) {
				    $result_href->{zServer_status}{record}{success} = 1;
				    $result_href->{zServer_status}{record}{status} = "Valid MARC record";
				} else {
				    $result_href->{zServer_status}{record}{success} = 0;
				    $result_href->{zServer_status}{record}{status} = "Invalid MARC record";
				}
			    } else {
				$result_href->{zServer_status}{record}{success} = 0;
				$result_href->{zServer_status}{record}{status} = $MARC::Record::ERROR;
			    }
			}

			
			$result_href->{log} .= "\n\n-[Record $x]--\n" if ($keepLog);
			$result_href->{log} .= $rs->record($x)->render() if ($keepLog);
			$result_href->{log} .= "\nRAW DATA:\n" if ($keepLog);
			$result_href->{log} .= $rs->record($x)->raw() if ($keepLog);
			
			$x++;
		    }
		}
	    };
	    if ($@) {
		$result_href->{zServer_status}{search}{success} = 0;
		$result_href->{zServer_status}{search}{type} = "search";
		$result_href->{zServer_status}{search}{status} = "Error " . $@->code() . ": " . $@->message();
		$result_href->{log} .= "Error " . $@->code() . ": " . $@->message() . "\n" if ($keepLog);
	    } else {
		$result_href->{zServer_status}{search}{success} = 1;
		$result_href->{zServer_status}{search}{type} = "search";
		$result_href->{zServer_status}{search}{status} = "Search successful";
	    }
	}
    }
    return $result_href;
}
#--------------------------------------------------------------------------------
# ...currently unused, but I wanted to save the code...
#
sub admin_test_zserver_process {
    my $self = shift;
    my $q = $self->query;

    my $test_results = "";

    my $zserver = $q->param("zserver");
    my $conn   = $q->param("conn") || $zserver;
    my $prs    = $q->param("prs") || "usmarc";
    my $es     = $q->param("es") || "f";
    my $pqf    = $q->param("pqf");
    my $usr    = $q->param("usr");
    my $pwd    = $q->param("pwd");
    my $scan   = $q->param("scan") || 0;

    my %bib1;
    $bib1{attr_use} = $q->param("use");
    $bib1{attr_relation} = $q->param("relation");
    $bib1{attr_position} = $q->param("position");
    $bib1{attr_structure} = $q->param("structure");
    $bib1{attr_truncation} = $q->param("truncation");
    $bib1{attr_completeness} = $q->param("completeness");
    $bib1{terms} = $q->param("terms");
    if (($bib1{attr_use}) && ($bib1{terms})) {
	$pqf = "\@attr 1=" . $bib1{attr_use};
	if ($bib1{attr_relation}) {
	    $pqf .= " \@attr 2=" . $bib1{attr_relation};
	}
	if ($bib1{attr_position}) {
	    $pqf .= " \@attr 3=" . $bib1{attr_position};
	}
	if ($bib1{attr_structure}) {
	    $pqf .= " \@attr 4=" . $bib1{attr_structure};
	}
	if ($bib1{attr_truncation}) {
	    $pqf .= " \@attr 5=" . $bib1{attr_truncation};
	}
	if ($bib1{attr_completeness}) {
	    $pqf .= " \@attr 6=" . $bib1{attr_completeness};
	}
	$pqf .= " \"$bib1{terms}\"";
    }

    my $ar_conn = $self->dbh->selectall_arrayref(
	"SELECT name, z3950_connection_string FROM zservers ORDER BY name",
	{ Slice => {} }
	);

    if ($conn) {
	$test_results = _test_zserver($conn, $prs, $es, $pqf, $usr, $pwd, $scan);
    }

    my $template = $self->load_tmpl('admin/test_zserver.tmpl');
    $template->param(pagetitle => 'fILL Admin Test zServer',
		     username => $self->authen->username,
		     zservers => $ar_conn,
		     conn => $conn,
		     pqf => $pqf,
		     test_results => $test_results,
	);
    return $template->output;
}


