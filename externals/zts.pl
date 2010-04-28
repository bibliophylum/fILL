#!/usr/bin/perl
#
# Calling: ./zts.pl [optional list of zserver ids]
#      Eg: ./zts.pl 17 22 25 36

use ZOOM;
use MARC::Record;
use MARC::File::XML;
use XML::Simple;
use Log::Dispatch;
use Log::Dispatch::File;
use Log::Dispatch::Screen;
use Data::Dumper;

use constant RESULTS_LIMIT => 100;

my $logger = Log::Dispatch->new;
$logger->add( Log::Dispatch::File->new( name      => 'file1',
					min_level => 'debug',
					filename  =>  "zts-$$.log",
	      )
    );
$logger->add( Log::Dispatch::Screen->new( name      => 'screen',
					  min_level => 'info',
					  stderr    => 1,
	      )
    );


my $lid = 1;  # id of the library doing the searching; for the zts, just set to 1.
my $sessionid = "zserver-test-suite";

my $xs = XML::Simple->new( KeyAttr => {server => 'id'} );
my $zts_targets = $xs->XMLin('zts_targets.xml');

my @targets;
if (@ARGV) {
    @targets = @ARGV;  # does no error checking!
} else {
    askForTargets(\@targets, $zts_targets);
}

my $pqf = build_pqf();

open(MARC,">","zts-$$.mrc");

$pqf =~ s/^\'(.*)\'$/$1/;

$logger->log( level => 'info', message => "PID [$$], $sessionid [$pqf]\n");

# you might want to do some synchronously....
#my @sync_master_list = qw( 37 38 39 40 41 42 43 22 );
my @sync_master_list = ();
my %lookup_sync_searchers = map { $_ => 1 } @sync_master_list;
my @search_parallel;
my @search_serially;
foreach my $target (@targets) {
    push(@search_parallel, $target) unless exists $lookup_sync_searchers{$target};
    push(@search_serially, $target) if     exists $lookup_sync_searchers{$target};
}

my $sequential_record_id = 1;

parallel_search($sessionid, $pqf, \@search_parallel, $lid) if (@search_parallel);
serial_search(  $sessionid, $pqf, \@search_serially) if (@search_serially);

if (DEBUG) {
    close LOG;
}
close MARC;

#---- end --------

#---------------------------------------------------------------------------------------------
#
#
sub parallel_search {
    my ($sessionid, $pqf, $aref_zservers, $lid) = @_;

    $logger->log( level => 'info', message => "parallel searching\n");

    my $ar_conn = get_list_of_available_servers( $aref_zservers );
    return undef unless @$ar_conn;

    my @z;       # z39.50 connections
    my @r;       # results
    
    for (my $i = 0; $i < @$ar_conn; $i++) {
	spray_search($ar_conn, $pqf, \@z, $i, \@r, $lid);
    }

    handle_spray_events($sessionid, \@z, \@r, $ar_conn);

    prefetch(\@r);
    store_all_result_sets( $sessionid, $ar_conn, \@r);

    $logger->log( level => 'info', message => "done parallel searching\n");
    
}

#-----------------------------------------------------------------------------------------------
#
#
sub serial_search {
    my ($sessionid, $pqf, $aref_zservers) = @_;

    $logger->log( level => 'info', message => "serialized searching\n");

    my $ar_conn = get_list_of_available_servers( $aref_zservers );
    return undef unless @$ar_conn;

    my @z;       # z39.50 connections
    my @r;       # results
    
    for (my $i = 0; $i < @$ar_conn; $i++) {
	my $s = serialized_search( $sessionid,
				   "f",
				   $pqf,
				   \%{ $ar_conn->[$i] }
	    );
    }
    $logger->log( level => 'info', message => "done serialized searching\n");
}

#--------------------------------------------------------------------------------------------------
#
#
sub get_list_of_available_servers {
    my $aref_zservers = shift;

    my @ar_conn;
    foreach my $id (@$aref_zservers) {
	push @ar_conn, { id => $id, 
			 name => $zts_targets->{server}->{$id}->{name},
			 z3950_connection_string => $zts_targets->{server}->{$id}->{z3950_connection_string},
			 preferredrecordsyntax => $zts_targets->{server}->{$id}->{preferredrecordsyntax},
	};
    }

    return \@ar_conn;
}

#-------------------------------------------------------------------------------------------------
#
#
sub spray_search {
    my ($ar_conn, $pqf, $z, $i, $r, $lid) = @_;

    $logger->log( level => 'debug', message => "$ar_conn->[$i]{id}, 0, Connecting...\n");
    
    my $options = new ZOOM::Options();
    $options->option(async => 1);
    $options->option(count => 1);
    $options->option(preferredRecordSyntax => $ar_conn->[$i]{preferredrecordsyntax});
    $options->option(timeout => 30);
    $z->[$i] = create ZOOM::Connection($options);
    $z->[$i]->connect($ar_conn->[$i]{z3950_connection_string}, 0); 

    if ($z->[$i]->errcode() != 0) {
	# something went wrong
	$logger->log( level => 'error', message => "something went wrong!\n");
	$logger->log( level => 'error', message => "connection $ar_conn->[$i]{id}, error (" . $z->[$i]->errcode() . ") - ", $z->[$i]->errmsg() . "\n" );
	
    } else {
	# Let's try a search
	$r->[$i] = $z->[$i]->search_pqf( $pqf );
    }
}

#-----------------------------------------------------------------------------------------------------
#
#
sub handle_spray_events {
    my ($sessionid, $z, $r, $ar_conn) = @_;

    $logger->log( level => 'info', message => "waiting for z39.50 events\n");
    my $i;
    while (($i = ZOOM::event($z)) != 0) {

	my $ev = $z->[$i-1]->last_event();

	$logger->log( level => 'debug', 
		      message => "connection $ar_conn->[$i-1]{id}, event ($ev) - " . ZOOM::event_str($ev) . "\n" );
	
	if ($ev == ZOOM::Event::ZEND) {
	    $size = $r->[$i-1]->size();
	    $ar_conn->[$i-1]{hits} = $size;
	    $logger->log( level => 'info', 
			  message => "connection $ar_conn->[$i-1]{id}, event ($ev) - END, $size hits\n");
	}
    }
    $logger->log( level => 'info', message => "no more z39.50 events\n");
}

#---------------------------------------------------------------------------------------------------
#
#
sub prefetch {
    my $r = shift;

    $logger->log( level => 'debug', message => "prefetch\n");

    my $max_prefetch;
    for (my $i = 0; $i < @$r; $i++) {
	$max_prefetch = $r->[$i]->size();
	$max_prefetch = RESULTS_LIMIT if ($max_prefetch > RESULTS_LIMIT);
	$r->[$i]->records(0, $max_prefetch, 0);
    }

}

#--------------------------------------------------------------------------------------------------------
#
#
sub store_all_result_sets {
    my ($sessionid, $ar_conn, $r) = @_;

    $logger->log( level => 'info', message => "store_all_result_sets\n");

    my $id = 1;
    for (my $i = 0; $i < @$r; $i++) {       # for each result set...

	store_result_set($r->[$i], \%{ $ar_conn->[$i] });

    }
}

#---------------------------------------------------------------------------------------------------
#
#
sub get_opac_record {
    my ($xml, $ar_conn) = @_;
    my $marc;
    
    eval {
	# a common problem with bad records:
	my @leader = ( $xml =~ /^.*<leader>(.*)<\/leader>.*$/ms );
	die "Invalid leader length, [$leader[0]]" unless (length($leader[0]) == 24);
	
	$marc = MARC::Record->new_from_xml( $xml, 'utf8' );
    };
    if ($@) {
	# couldn't convert to marc
	$logger->log( level => 'error', message => "$sessionid [Couldn't convert to MARC]\n");
	return undef;
    } else {
	# a bunch of xml processing to dig out the holdings; don't need it for zts
    }
    return $marc;
}

#--------------------------------------------------------------------------------------------------------
#
#
sub get_marc_record {
    my $raw = shift;
    my $marc;
    $logger->log( level => 'debug', message => "get_marc_record\n");
    
    if (defined $raw) {
	if (length($raw) > 5) {
	    if (length($raw) < substr($raw,0,5)) {
		$logger->log( level => 'warning', message =>"$sessionid [Length of record in leader is a lie: [$raw]]\n");
	    } else {

		eval {
		    no warnings;
		    local $SIG{'__DIE__'};
		    $marc = new_from_usmarc MARC::Record($raw); 
		};

		if ($@) {
		    # record blew up
		    $logger->log( level => 'error', message => "$sessionid [Record blew up]\n");
		} else {
		    # successfully converted to MARC::Record
		    $logger->log( level => 'debug', message => "successfully converted to MARC::Record\n");
		    $logger->log( level => 'debug', message => "  encoding is: " . $marc->encoding() . "\n");
		    if (DEBUG) {
			my @warnings = $marc->warnings();
			foreach my $warning (@warnings) {
			    $logger->log( level => 'debug', message => "  warning: $warning\n");
			}
		    }
		}
	    }
	}
    }
    return $marc;
}

#-----------------------------------------------------------------------
#
#
sub serialized_search {
    my $sessionid = shift;
    my $elementSet = shift;
    my $pqf = shift;
    my $conn_info = shift;

    $zid = $conn_info->{id};
    $connection_string = $conn_info->{z3950_connection_string};
    $preferredRecordSyntax = $conn_info->{preferredrecordsyntax};

    $logger->log( level => 'debug', message => "$zid, 0, serialized, Connecting...\n");
    
    my $s = "";
    my $conn;
    
    my $rs;
    my $n;

    eval {
	my $o1 = new ZOOM::Options(); $o1->option(preferredRecordSyntax => $preferredRecordSyntax);
	my $o2 = new ZOOM::Options(); $o2->option(elementSetName => $elementSet);
	my $opts = new ZOOM::Options($o1, $o2);
	$conn = create ZOOM::Connection($opts);
	$conn->connect($connection_string);
    };

    if ($@) {
	$logger->log( level => 'error', message => "Error " . $@->code() . ": " . $@->message() . "\n");
	$logger->log( level => 'error', message => $conn->errcode() . "," . $conn->errmsg() . "\n");
	
    } else {

        # search
	eval {
	    $rs = $conn->search_pqf($pqf);
	    $n = $rs->size();
	    $logger->log( level => 'info', message => "$n hits\n");
	    $conn_info->{hits} = $n;
	    
	    $n = RESULTS_LIMIT if ($n > RESULTS_LIMIT); # let's be reasonable
	    
	    if ($n > 0) {
		$rs->records(0, $n, 0); # prefetch
		store_result_set($rs, $conn_info);
	    }
	};
	if ($@) {
	    $logger->log( level => 'error', message => "Error " . $@->code() . ": " . $@->message() . "\n");
	}
    }
    return $s;
}

#--------------------------------------------------------------------
#
#
#
sub store_result_set {
    my ($rs, $conn_info) = @_;

    my $size = $rs->size();	
    $size = RESULTS_LIMIT if ($size > RESULTS_LIMIT);
    $logger->log( level => 'info', message => "store_result_set for $conn_info->{name}, size: $size\n");

    printf("rec zs %-25.25s %.254s\n","zserver name","title");
    
    for (my $j=1; $j <= $size; $j++) {        # for each record within the result set...
	$logger->log( level => 'debug', message => "record $j of " . $rs->size() . "\n");
	
	if ($rs->record($j-1)) {

	    if ($rs->record($j-1)->error()) {
		my($code, $msg, $addinfo, $dset) = $rs->record($j-1)->error();
		$logger->log( level => 'error', message => "$sessionid [$code $msg $addinfo $dset]\n");
		
	    } else {
		
		my $marc;
		my $raw;
		
		if ($conn_info->{preferredrecordsyntax} eq 'opac') {           # server returns "opac" records
		    $logger->log( level => 'debug', message => "need to get OPAC record\n");
		    my $xml = $rs->record($j-1)->get("opac");
		    $marc = get_opac_record( $xml, $ar_conn );
		    
		} else {                                                       # server returns marc records
		    $logger->log( level => 'debug', message => "need to get MARC record\n");
		    $raw = $rs->record($j-1)->raw();
		    $marc = get_marc_record( $raw );
		}
		
		if ($marc) {
		    
		    my $isNFL = 0;  # just for zts, assume everything is loanable....!!!
		    
		    unless ($isNFL) {
			
			# For proper sorting of titles...
			my $title;
			my $fld = $marc->field("245");
			if ($fld) {
			    my $chars_to_ignore = $fld->indicator(2);
			    $title = substr($fld->subfield('a'),$chars_to_ignore);
			} else {
			    $title = "";
			}
			
			# Clean up garbage in author
			my $author = $marc->author();
			$author =~ s/[^a-zA-Z ]//g;

			# Clean up isbn
			my $isbn = $marc->subfield('020','a');
			$isbn =~ s/[^0-9X]//g;

			$logger->log( level => 'debug', message => "sequential_record_id [" . $sequential_record_id . "]\n");
			$logger->log( level => 'debug', message => "found_at_server [$conn_info->{name}]\n");
			$logger->log( level => 'debug', message => "title [$title]\n");

			printf("%3d %2d %-25.25s %.254s\n",
			       $sequential_record_id++,
			       $conn_info->{id},
			       $conn_info->{name},
			       $title
			    );
			if ($raw) {
			    print MARC $raw;
			} else {
			    print MARC $marc->as_usmarc();
			}
			# ok, this had no effect on the spray search.
			#sleep(1); # fake up a load-into-database delay
		    }
		    
		    if (exists $conn_info->{acquiring}) {
			$conn_info->{acquiring} += 1;
		    } else {
			$conn_info->{acquiring} = 1;
		    }
		    
		    $id++;
		}
	    }
	} else {
	    $logger->log( level => 'warning', message => "result set record " . ($j-1) . " does not exist\n");
	    $logger->log( level => 'warning', message => "result set size is " . $rs->size() . "\n");
	}
    }
}


#=================================================================================================

#-----------------------------------------------------------------------
#
#
sub promptUser {
    my ($promptString,$defaultValue) = @_;
    if ($defaultValue) {
        print $promptString, "[", $defaultValue, "]: ";
    } else {
        print $promptString, ": ";
    }

    $| = 1;
    $_ = <STDIN>;
    chomp;

    if ("$defaultValue") {
        return $_ ? $_ : $defaultValue;
    } else {
        return $_;
    }
}


#-----------------------------------------------------------------------
#
#
sub listServers {
    my $zts_targets = shift;

    print "\nAll servers:\n------------\n";
    foreach my $id (sort keys %{$zts_targets->{server}}) {
	printf("%2d:%-30.30s [%-40.40s]\n", 
	       $id,
	       $zts_targets->{server}->{$id}->{name}, 
	       $zts_targets->{server}->{$id}->{z3950_connection_string}
	    );
    }
}

#-----------------------------------------------------------------------
#
#
sub listSelected {
    my $aref = shift;
    my $zts_targets = shift;

    print "\nServers selected for searching:\n-----------------------------\n";
    foreach my $id (@$aref) {
	printf("%2d:%-30.30s [%-40.40s]\n", 
	       $id,
	       $zts_targets->{server}->{$id}->{name}, 
	       $zts_targets->{server}->{$id}->{z3950_connection_string}
	    );
    }
}

#-----------------------------------------------------------------------
#
#
sub askForTargets {
    my $targets_aref = shift;
    my $zts_targets = shift;

    # Get targets list from user
    my $id = 's';
    while ($id ne 'x') {
	if ($id eq 's') {
	    listServers($zts_targets);
	} elsif ($id eq 'd') {
	    listSelected( $targets_aref, $zts_targets );
	} else {
	    if (exists $zts_targets->{server}->{$id}) {
		push @{$targets_aref}, $id;
		print $zts_targets->{server}->{$id}->{name} . " added to search list.\n";
	    } else {
		print "\'$i\' doesn't seem to be a valid option.\n";
	    }
	}
	
	$id = promptUser("\nEnter an id number to add a server to the search list,\nor 's' to list servers,\nor 'd' to display current search list,\nor 'x' to finish.","s");
    }
}


#-----------------------------------------------------------------------
#
#
sub build_pqf {

    my $pqf;
    my $build_or_enter = promptUser("Would you rather (b)uild a query, or (e)nter one directly? ","e");

    if ($build_or_enter eq 'b') {
	print "\nBuild a pqf query:\n------------------\n";
	my %bib1;
	
	print "(note that this will only build a query for searching 1 index... which is fine for our test)\n";

	$bib1{attr_use} = getUseAttr();
	$bib1{attr_relation} = getRelationAttr();
	$bib1{attr_position} = getPositionAttr();
	$bib1{attr_structure} = getStructureAttr();
	$bib1{attr_truncation} = getTruncationAttr();
	$bib1{attr_completeness} = getCompletenessAttr();

	
	print "\nStep 7: Search terms\n";
	$searchTerms = promptUser("\nEnter your search terms ");    
	
	if (($bib1{attr_use}) && ($searchTerms)) {
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
	    $pqf .= " \"$searchTerms\"";
	}

    } else {
	$pqf = promptUser("Enter a pqf string");
    }
    print "\nYour pqf string is:\n";
    print "$pqf\n";
    return $pqf;
}    


sub getUseAttr {

    print "\nStep 1: Use attribute\n";
    my @useAttributes = (
	{value => 4, name => "Title - 4"},
	{value => 1003, name => "Author - 1003"},
	{value => 21, name => "Subject heading - 21"},
	{value => 1, name => "Personal name - 1"},
	{value => 2, name => "Corporate name - 2"},
	{value => 3, name => "Conference name - 3"},
	{value => 5, name => "Title series - 5"},
	{value => 6, name => "Title uniform - 6"},
	{value => 7, name => "ISBN - 7"},
	{value => 8, name => "ISSN - 8"},
	{value => 9, name => "LC card number - 9"},
	{value => 10, name => "BNB card no. - 10"},
	{value => 11, name => "BGF number  - 11"},
	{value => 12, name => "Local number - 12"},
	{value => 13, name => "Dewey classification - 13"},
	{value => 14, name => "UDC classification - 14"},
	{value => 15, name => "Bliss classification - 15"},
	{value => 16, name => "LC call number - 16"},
	{value => 17, name => "NLM call number - 17"},
	{value => 18, name => "NAL call number - 18"},
	{value => 19, name => "MOS call number - 19"},
	{value => 20, name => "Local classification - 20"},
	{value => 22, name => "Subject Rameau - 22"},
	{value => 23, name => "BDI index subject - 23"},
	{value => 24, name => "INSPEC subject - 24"},
	{value => 25, name => "MESH subject - 25"},
	{value => 26, name => "PA subject - 26"},
	{value => 27, name => "LC subject heading  - 27"},
	{value => 28, name => "RVM subject heading - 28"},
	{value => 29, name => "Local subject index - 29"},
	{value => 30, name => "Date - 30"},
	{value => 31, name => "Date of publication - 31"},
	{value => 32, name => "Date of acquisition - 32"},
	{value => 33, name => "Title key - 33"},
	{value => 34, name => "Title collective - 34"},
	{value => 35, name => "Title parallel - 35"},
	{value => 36, name => "Title cover - 36"},
	{value => 37, name => "Title added title page - 37"},
	{value => 38, name => "Title caption - 38"},
	{value => 39, name => "Title running - 39"},
	{value => 40, name => "Title spine - 40"},
	{value => 41, name => "Title other variant - 41"},
	{value => 42, name => "Title former - 42"},
	{value => 43, name => "Title abbreviated - 43"},
	{value => 44, name => "Title expanded - 44"},
	{value => 45, name => "Subject precis - 45"},
	{value => 46, name => "Subject rswk - 46"},
	{value => 47, name => "Subject subdivision - 47"},
	{value => 48, name => "No. nat'l biblio. - 48"},
	{value => 49, name => "No. legal deposit  - 49"},
	{value => 50, name => "No. govt pub. - 50"},
	{value => 51, name => "No. music publisher - 51"},
	{value => 52, name => "Number db - 52"},
	{value => 53, name => "Number local call - 53"},
	{value => 54, name => "Code--language - 54"},
	{value => 55, name => "Code--geographic area - 55"},
	{value => 56, name => "Code--institution - 56"},
	{value => 57, name => "Name and title * - 57"},
	{value => 58, name => "Name geographic - 58"},
	{value => 59, name => "Place publication - 59"},
	{value => 60, name => "CODEN - 60"},
	{value => 61, name => "Microform generation - 61"},
	{value => 62, name => "Abstract - 62"},
	{value => 63, name => "Note - 63"},
	{value => 1000, name => "Author-title - 1000"},
	{value => 1001, name => "Record type - 1001"},
	{value => 1002, name => "Name - 1002"},
	{value => 1004, name => "Author-name personal - 1004"},
	{value => 1005, name => "Author-name corporate - 1005"},
	{value => 1006, name => "Author-name conference - 1006"},
	{value => 1007, name => "Identifier--standard - 1007"},
	{value => 1008, name => "Subject--LC children's - 1008"},
	{value => 1009, name => "Subject name -- personal - 1009"},
	{value => 1010, name => "Body of text - 1010"},
	{value => 1011, name => "Date/time added to db - 1011"},
	{value => 1012, name => "Date/time last modified - 1012"},
	{value => 1013, name => "Authority/format id - 1013"},
	{value => 1014, name => "Concept-text - 1014"},
	{value => 1015, name => "Concept-reference - 1015"},
	{value => 1016, name => "Any - 1016"},
	{value => 1017, name => "Server-choice - 1017"},
	{value => 1018, name => "Publisher - 1018"},
	{value => 1019, name => "Record-source - 1019"},
	{value => 1020, name => "Editor - 1020"},
	{value => 1021, name => "Bib-level - 1021"},
	{value => 1022, name => "Geographic-class - 1022"},
	{value => 1023, name => "Indexed-by - 1023"},
	{value => 1024, name => "Map-scale - 1024"},
	{value => 1025, name => "Music-key - 1025"},
	{value => 1026, name => "Related-periodical - 1026"},
	{value => 1027, name => "Report-number - 1027"},
	{value => 1028, name => "Stock-number - 1028"},
	{value => 1030, name => "Thematic-number - 1030"},
	{value => 1031, name => "Material-type - 1031"},
	{value => 1032, name => "Doc-id - 1032"},
	{value => 1033, name => "Host-item - 1033"},
	{value => 1034, name => "Content-type - 1034"},
	{value => 1035, name => "Anywhere - 1035"},
	{value => 1036, name => "Author-Title-Subject - 1036"},
	);
    
    my $i = 1;
    my $s;
    foreach my $href (@useAttributes) {
	if (($i % 3) == 0) {
	    print "\t$s\n";
	    $s = "";
	}
	$s .= sprintf("%-35.35s", $href->{name});
	$i++;
    }
    my $attr = promptUser("\nEnter a use attribute ","4");
    # do some error checking... someday
    
    return $attr;
}

sub getRelationAttr {
    print "\nStep 2: Relation attribute\n";
    my @relationAttributes = (
	{value => 1, name => "less than - 1"},
	{value => 2, name => "less than or equal - 2"},
	{value => 3, name => "equal - 3"},
	{value => 4, name => "greater or equal - 4"},
	{value => 5, name => "greater than - 5"},
	{value => 6, name => "not equal - 6"},
	{value => 100, name => "phonetic - 100"},
	{value => 101, name => "stem - 101"},
	{value => 102, name => "relevance - 102"},
	{value => 103, name => "AlwaysMatches - 103"},
	);
    foreach my $href (@relationAttributes) {
	print "\t" . $href->{name} . "\n";
    }
    my $attr = promptUser("\nEnter a relation attribute ","3");
    return $attr;
}

sub getPositionAttr {
    print "\nStep 3: Position attribute\n";
    my @positionAttributes = (
	{value => 1, name => "first in field - 1"},
	{value => 2, name => "first in subfield - 2"},
	{value => 3, name => "any position in field - 3"},
	);
    foreach my $href (@positionAttributes) {
	print "\t" . $href->{name} . "\n";
    }
    my $attr = promptUser("\nEnter a position attribute ","3");
    return $attr;
}

sub getStructureAttr {
    print "\nStep 4: Structure attribute\n";
    my @structureAttributes = (
	{value => 1, name => "phrase - 1"},
	{value => 2, name => "word - 2"},
	{value => 3, name => "key - 3"},
	{value => 4, name => "year - 4"},
	{value => 5, name => "date (normalized) - 5"},
	{value => 6, name => "word list - 6"},
	{value => 100, name => "date (un-normalized) - 100"},
	{value => 101, name => "name (normalized) - 101"},
	{value => 102, name => "name (un-normalized) - 102"},
	{value => 103, name => "structure - 103"},
	{value => 104, name => "urx - 104"},
	{value => 105, name => "free-form-text - 105"},
	{value => 106, name => "document-text - 106"},
	{value => 107, name => "local number - 107"},
	{value => 108, name => "string - 108"},
	{value => 109, name => "numeric string - 109"},
	);
    foreach my $href (@structureAttributes) {
	print "\t" . $href->{name} . "\n";
    }
    my $attr = promptUser("\nEnter a structure attribute ","2");
    return $attr;
}

sub getTruncationAttr {
    print "\nStep 5: Truncation attribute\n";
    my @truncationAttributes = (
	{value => 1, name => "right truncation - 1"},
	{value => 2, name => "left truncation - 2"},
	{value => 3, name => "left and right - 3"},
	{value => 100, name => "do not truncate - 100"},
	{value => 101, name => "process # in search term - 101"},
	{value => 102, name => "reg-Expr1 - 102"},
	{value => 103, name => "reg-Expr2 - 103"},
	);
    foreach my $href (@truncationAttributes) {
	print "\t" . $href->{name} . "\n";
    }
    my $attr = promptUser("\nEnter a truncation attribute ","100");
    return $attr;
}

sub getCompletenessAttr {
    print "\nStep 6: Completeness attribute\n";
    my @completenessAttributes= (
	{value => 1, name => "incomplete subfield - 1"},
	{value => 2, name => "complete subfield - 2"},
	{value => 3, name => "complete field - 3"},
	);
    foreach my $href (@completenessAttributes) {
	print "\t" . $href->{name} . "\n";
    }
    my $attr = promptUser("\nEnter a completeness attribute ","1");
    return $attr;
}
