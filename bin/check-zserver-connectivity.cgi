#!/usr/bin/perl
#use strict;
use CGI;
use CGI::Session;
use JSON;
use ZOOM;
use MARC::Record;
use DBI;
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

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;
    
if ($libsym =~ /^[A-Z]{2,7}$/) {  # some sanity checking
#    print STDERR "Checking symbol [$libsym]\n";
    my @org = $dbh->selectrow_array("select oid from org where symbol=?", undef, $libsym);
#    print STDERR Dumper(@org);
    my $settingsFileName = get_settings_filename( $org[0] );	    
    my $path = "/opt/fILL/pazpar2/settings";
#    print STDERR "looking for $path/$settingsFileName\n";

    # We could just pull the connection info out of the DB, but that might not be in sync with the pazpar2 settings file...
    if ( $settingsFileName && -f "$path/$settingsFileName" ) {
#	print STDERR "file [$settingsFileName] found\n";
	open(my $file, '<', "$path/$settingsFileName") or die "Can't open $path/$settingsFileName for read: $!";
	my $t;
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

	$t =~ s/\"//g;
	my ($garbage,$target) = split(/=/, $t);
#	print STDERR "target [$target]\n";
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

print "Content-Type:application/json\n\n" . to_json( $result_href );

#print Dumper($result_href);
exit;

#--------------------------------------------------------------------------------
# Recursive...
#
sub get_settings_filename {
    my ($oid, $maxdepth) = @_;
    $maxdepth = 4 unless defined $maxdepth;
#    print STDERR "depth: $maxdepth\n";
#    print STDERR "depth limit reached, exiting\n" if ($maxdepth <= 0);
    return undef if ($maxdepth <= 0);

    my @lz39 = $dbh->selectrow_array("select count(oid) from library_z3950 where oid=?", undef, $oid);

    if (@lz39 && $lz39[0] != 0) {
#	print STDERR "oid [$oid] has zServer\n";
	my @org = $dbh->selectrow_array("select org_name from org where oid=?", undef, $oid);
	my $s = $org[0];
	$s =~ s/ /_/g;
	$s =~ s/\.//g;
	$s =~ s/:/-/g;
	$s .= ".xml";
	return $s;

    } else {
#	print STDERR "oid [$oid] does not have zServer, checking for parent.\n";
	my @parent = $dbh->selectrow_array("select oid from org_members where member_id=?", undef, $oid);
	if (@parent) {
#	    print STDERR "...parent is oid [" . $parent[0] . "], checking parent\n";
	    return get_settings_filename($parent[0], ($maxdepth - 1));
	}
#	print STDERR "...no parent found\n";
	return undef;
    }
}

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


