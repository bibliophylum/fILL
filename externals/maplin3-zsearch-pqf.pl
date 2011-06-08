#!/usr/bin/perl
#
# Program: maplin3-zsearch-pqf.pl
# Purpose: z39.50 spray-search component of cgiapp "maplin3"
#          perform a z39.50 spray search, tracking the status and saving the results
# Author:  David A. Christensen
# Date:    2008.05.08
# Mods:    2008.05.30 - target selections
#          2008.07.21 - filter out not-for-loans
#          2008.09.23 - add ability to filter nfl based on control fields (ie < '010')
#          2008.09.25 - oops... add database disconnect at the end
#          2008.10.14 - ability to filter WPL duplicates
#          2008.11.04 - added record prefetch (dramatic speed increase!)
#          2009.01.28 - added preferredRecordSyntax for OPAC recs
#          2009.02.19 - added availability info to PLS OPAC recs
#          2009.06.29 - converted to PostgreSQL from MySQL
# Notes:   Need tweaked MARC::File::XML - add the line: $parser->_cleanup();  before $parser->{ tagStack } = [];
#            in decode() subroutine.
#          Need to add column preferredRecordSyntax to zservers table.  Set every row to 'usmarc', then PLS to 'opac'
# Calling: ./maplin3-zsearch-pqf.pl libraryid session ['library'|'public']'pqf string' zserverid [ another_zserverid...]
#      Eg: ./maplin3-zsearch-pqf.pl 101 thisisatest library '@attr 1=4 @attr 2=3 @attr 4=2 "ducks geese"' 17 22 25 36

use ZOOM;
use DBI;
use MARC::Record;
use MARC::File::XML;
use XML::Simple;
use Log::Dispatch;
use Log::Dispatch::File;
use Data::Dumper;

use constant RESULTS_LIMIT => 100;
use constant DEBUG => 0;

my $lid = shift;
my $sessionid = shift;
my $searcher = shift;
my $pqf = shift;
# @ARGV will hold zservers

my %statistics = {};
$statistics{sessionid} = $sessionid . '-' . $$;
$statistics{pqf} = $pqf;
my $stats_start = time;

my $log = Log::Dispatch->new();
$log->add( Log::Dispatch::File->new
	   ( name      => 'file1',
	     min_level => 'notice',  # debug, info, notice, warning, error, critical, alert, emergency
	     filename  => '/opt/maplin3/logs/z3950.log',
	     mode      => 'append',
	     newline   => 1
	   )
    );

if (DEBUG) {
    # log in as Flin Flon to search
    if ($lid == 32) { # special for Flin Flon -- WARNING: this fills up really quickly!
	$log->add( Log::Dispatch::File->new
		   ( name      => 'file2',
		     min_level => 'debug',  # debug, info, notice, warning, error, critical, alert, emergency
		     filename  => '/opt/maplin3/logs/flinflon.log',
		     mode      => 'append',
		     newline   => 1
		   )
	    );    
    }
}

my $enable_WPL_duplicate_filter = 1;  # turned on

$pqf =~ s/^\'(.*)\'$/$1/;

$log->log( level => 'notice', message => timestamp() . "lid [$lid], searcher [$searcher], pqf [$pqf]\n");

my $dbh;
eval {
    $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
			"mapapp",
			"maplin3db",
			{AutoCommit => 1, 
			 RaiseError => 1, 
			 PrintError => 0,
			}
	);
};
if ($@) {
    $log->log( level => 'error', message => "could not connect to database: " . $@ );
    exit(1);
}

# Store the sessionid/pid
$dbh->do("INSERT INTO search_pid (sessionid, pid) VALUES (?,?)",
	 undef,
	 $sessionid,
	 $$
    );

# initial statistics row
$dbh->do("INSERT INTO search_statistics (sessionid, pqf) VALUES (?,?)",
	 undef,
	 $statistics{sessionid},
	 $statistics{pqf}
    );



# Get ebsco information
my $ebsco_href = $dbh->selectrow_hashref( "SELECT ebsco_user, ebsco_pass FROM libraries WHERE lid=?",
					  undef,
					  $lid
    );

# Get not-for-loan information
my $nfl = $dbh->selectall_arrayref( "select zid,tag,subfield,text,atstart from notforloan",
				    { Slice => {} }
    );

# some must by done synchronously....
#my @sync_master_list = qw( 40 41 42 43 44 45 46 );
#my @sync_master_list = qw( 37 38 39 40 41 42 43 22 ); # test box
my @sync_master_list = qw( 64 );  # Something weird with Flin Flon - only works if searched by itself...?
                                  # (perhaps zServer doesn't keep recordset?)
my %lookup_sync_searchers = map { $_ => 1 } @sync_master_list;
my @search_parallel;
my @search_serially;
foreach my $target (@ARGV) {
    push(@search_parallel, $target) unless exists $lookup_sync_searchers{$target};
    push(@search_serially, $target) if     exists $lookup_sync_searchers{$target};
}

my $sequential_record_id = 1;

parallel_search($sessionid, $pqf, \@search_parallel, $lid) if (@search_parallel);
serial_search(  $sessionid, $pqf, \@search_serially) if (@search_serially);

# Back in the old days, we'd remove WPL items if a rural library had a copy...
#
if ($enable_WPL_duplicate_filter) {
    # Remove WPL duplicates
    $SQL = "CREATE TEMPORARY TABLE wpl_duplicates AS SELECT isbn FROM marc where sessionid=? and char_length(isbn) > 0 and zid <> ?";
    my $rows = $dbh->do($SQL, undef, $sessionid, 28);
    $SQL = "DELETE FROM marc WHERE (sessionid=? and zid=? and isbn in (select isbn from wpl_duplicates))";
    $rows = $dbh->do($SQL, undef, $sessionid, 28);
}


# Toast the sessionid/pid db entry
$log->log( level => 'debug', message => timestamp() . "toast sessionid/pid in search_pid table\n" );
$dbh->do("DELETE FROM search_pid WHERE sessionid=?",
	 undef,
	 $sessionid,
    );

my $stats_end = time;
$statistics{duration} = $stats_end - $stats_start;
$dbh->do("UPDATE search_statistics SET duration=? WHERE sessionid=?",
	 undef,
	 $statistics{duration},
	 $statistics{sessionid}
    );

# Disconnect from the database.
$dbh->disconnect();

#if (-e '/tmp/maplin.zsearch') {
#    unlink '/tmp/maplin.zsearch';
#}

#---- end --------

#---------------------------------------------------------------------------------------------
#
#
sub parallel_search {
    my ($sessionid, $pqf, $aref_zservers, $lid) = @_;

    $log->log( level => 'debug', message => timestamp() . "in parallel_search\n" );

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

    clean_up_and_move_on( $sessionid, $ar_conn, \@z );

}

#-----------------------------------------------------------------------------------------------
#
#
sub serial_search {
    my ($sessionid, $pqf, $aref_zservers) = @_;

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

    clean_up_and_move_on( $sessionid, $ar_conn, \@z );

}

#--------------------------------------------------------------------------------------------------
#
#
sub get_list_of_available_servers {
    my $aref_zservers = shift;

    my $SQL = "SELECT id, name, z3950_connection_string, holdings_tag, holdings_location, holdings_callno, preferredrecordsyntax, requires_credentials FROM zservers WHERE (available=1 and alive=1)";
    if (@$aref_zservers) {
	$SQL .= " AND id IN (";
	foreach (@$aref_zservers) {
	    $SQL .= $_;  $SQL .= ",";
	}
	chop $SQL; # toast trailing comma
	$SQL .= ")";
    }

    my $ar_conn = $dbh->selectall_arrayref( $SQL, { Slice => {} } );
    return $ar_conn;
}

#-------------------------------------------------------------------------------------------------
#
#
sub spray_search {
    my ($ar_conn, $pqf, $z, $i, $r, $lid) = @_;

    $dbh->do("INSERT INTO status_check (sessionid, zid, event, msg) VALUES (?,?,?,?)",
	     undef,
	     $sessionid,
	     $ar_conn->[$i]{id},
	     0,
	     "Connecting..."
	);
    
    my $options = new ZOOM::Options();
    $options->option(async => 1);
#    $options->option(count => 1);
    $options->option(count => RESULTS_LIMIT);
    $options->option(preferredRecordSyntax => $ar_conn->[$i]{preferredrecordsyntax});
    $options->option(timeout => 30);
    if ($ar_conn->[$i]{requires_credentials}) {
	my $SQLgetcredentials = "SELECT username, password FROM library_zserver_credentials WHERE lid=? AND zid=?";
	my $h = $dbh->selectrow_hashref( $SQLgetcredentials, undef, $lid, $ar_conn->[$i]{id});
	if ((defined $h->{username}) && (defined $h->{password})) {
	    $options->option(user => $h->{username});
	    $options->option(password => $h->{password});
	}
    }
    $log->log( level => 'info', message => timestamp() . "creating z39.50 connection [$i] for [$ar_conn->[$i]{name}]\n");
    $z->[$i] = create ZOOM::Connection($options);
    $z->[$i]->connect($ar_conn->[$i]{z3950_connection_string}, 0); # Uses the specified username and password

    if ($z->[$i]->errcode() != 0) {
	# something went wrong
	$log->log( level => 'warning', message => timestamp() . zoom_error_string( $z->[$i] ) );
	$dbh->do("UPDATE status_check SET event=?, msg=? WHERE ((sessionid=?) AND (zid=?))",
		 undef,
		 $z->[$i]->errcode(),
		 $z->[$i]->errmsg(),
		 $sessionid,
		 $ar_conn->[$i]{id},
	    );
	
    } else {
	$log->log( level => 'debug', message => timestamp() . "connection created for [$ar_conn->[$i]{name}]\n");
	# Let's try a search
	$r->[$i] = $z->[$i]->search_pqf( $pqf );
    }
}

#-----------------------------------------------------------------------------------------------------
#
#
sub handle_spray_events {
    my ($sessionid, $z, $r, $ar_conn) = @_;

    my $i;
    while (($i = ZOOM::event($z)) != 0) {

	my $ev = $z->[$i-1]->last_event();

	$log->log( level => 'debug', message => timestamp() . "[$ar_conn->[$i-1]{name}] " . ZOOM::event_str($ev) ."\n");
	$dbh->do("UPDATE status_check SET event=?, msg=? WHERE ((sessionid=?) AND (zid=?))",
		 undef,
		 $ev,
		 ZOOM::event_str($ev),
		 $sessionid,
		 $ar_conn->[$i-1]{id},
		 );
	
	if ($ev == ZOOM::Event::ZEND) {
	    $size = $r->[$i-1]->size();
	    $ar_conn->[$i-1]{hits} = $size;

	    $log->log( level => 'info', message => timestamp() . "[$ar_conn->[$i-1]{name}] $size hits.\n" );
	    $dbh->do("UPDATE status_check SET event=?, msg=? WHERE ((sessionid=?) AND (zid=?))",
		     undef,
		     $ev,
		     "$size hits.",
		     $sessionid,
		     $ar_conn->[$i-1]{id},
		     );
	    
	}
    }

}

#---------------------------------------------------------------------------------------------------
#
#
sub prefetch {
    my $r = shift;

    my $max_prefetch;
    for (my $i = 0; $i < @$r; $i++) {
	$max_prefetch = $r->[$i]->size();
	$max_prefetch = RESULTS_LIMIT if ($max_prefetch > RESULTS_LIMIT);
	$log->log( level => 'debug', message => timestamp() . "prefetching $max_prefetch from result set [$i]\n" );
	$r->[$i]->records(0, $max_prefetch, 0);
    }

}

#--------------------------------------------------------------------------------------------------------
#
#
sub store_all_result_sets {
    my ($sessionid, $ar_conn, $r) = @_;

    $log->log( level => 'debug', message => timestamp() . "store_all_result_sets\n");
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
    
    $log->log( level => 'debug', message => timestamp() . "get_opac_record\n" );

    eval {
	# a common problem with bad records:
	my @leader = ( $xml =~ /^.*<leader>(.*)<\/leader>.*$/ms );
	die "Invalid leader length, [$leader[0]]" unless (length($leader[0]) == 24);
	
	$marc = MARC::Record->new_from_xml( $xml, 'utf8' );
    };
    if ($@) {
	# couldn't convert to marc
	$log->log( level => 'debug', message => timestamp() . "Could not convert to MARC [$xml]\n");
	return undef;
    } else {
	
	my $opac = XMLin( $xml, ForceArray => ['holding','circulation'] );
	
	# delete any existing 949 (WARNING: specific to PLS at this point!)
	my @f949 = $marc->field('949');
	foreach my $f (@f949) {
	    $marc->delete_field($f);
	}
	
	return undef unless $opac->{holdings};
	return undef unless $opac->{holdings}->{holding};

	my $ohh_aref = $opac->{holdings}->{holding};
	
	# now add new 949s from the OPAC rec
	foreach my $holding_href ( @$ohh_aref ) {
	    
	    unless (ref($holding_href->{localLocation}) eq "HASH") {
		
		foreach my $circ_href ( @{ $holding_href->{circulations}->{circulation} }) {

		    # Get matching Maplin-3 locations table location, if any
		    if ($ar_conn->[$i]{id} == 1) { 
			# PLS only
			my $email = $holding_href->{localLocation};
			$email =~ s/^.* - (\S+\@\S+)$/$1/;

			my $SQL = "SELECT location FROM locations WHERE zid=? AND email_address=?";
			my @m3loc = $dbh->selectrow_array( $SQL, 
							   undef,
							   $ar_conn->[$i]{id},
							   $email
			    );
			
			if ($m3loc[0]) {
			    $holding_href->{localLocation} = $m3loc[0];
			}
		    }
		
		    $holding_href->{shelvingLocation} = "PLS UC" unless $holding_href->{shelvingLocation};
		
		    my $f = MARC::Field->new('949','','',
					     'm' => $holding_href->{localLocation},
					     'c' => $holding_href->{shelvingLocation},
					     'd' => $circ_href->{midspine},
					     's' => $circ_href->{temporaryLocation},
					     't' => $circ_href->{availabilityDate}
			);
		    $marc->append_fields( $f );
		}
	    }
	}
	return undef unless $marc->field('949');
	$log->log( level => 'debug', message => timestamp() . "successfully converted to MARC::Record\n");
	$log->log( level => 'debug', message => timestamp() . "encoding is: " . $marc->encoding() . "\n");
	$log->log( level => 'debug', message => timestamp() . "title is: " . $marc->title() . "\n");
    }
    return $marc;
}

#--------------------------------------------------------------------------------------------------------
#
#
sub get_marc_record {
    my $raw = shift;
    my $marc;
    $log->log( level => 'debug', message => timestamp() . "get_marc_record\n" );    
    if (defined $raw) {
	if (length($raw) > 5) {
	    if (length($raw) < substr($raw,0,5)) {
		$log->log( level => 'debug', message => timestamp() . "$sessionid [Length of record in leader is a lie: [$raw]]\n");
	    } else {

		eval {
		    no warnings;
		    local $SIG{'__DIE__'};
		    $marc = new_from_usmarc MARC::Record($raw); 
		};

		if ($@) {
		    # record blew up
		    $log->log( level => 'debug', message => timestamp() . "Could not convert to MARC::Record [$raw]\n");
		} else {
		    # successfully converted to MARC::Record
		    $log->log( level => 'debug', message => timestamp() . "successfully converted to MARC::Record\n");
		    $log->log( level => 'debug', message => timestamp() . "encoding is: " . $marc->encoding() . "\n");
		    $log->log( level => 'debug', message => timestamp() . "title is: " . $marc->title() . "\n");

		    my @warnings = $marc->warnings();
		    foreach my $warning (@warnings) {
			$log->log( level => 'debug', message => timestamp() . "MARC conversion warning: $warning\n");
		    }
		}
	    }
	}
    }
    return $marc;
}

#-----------------------------------------------------------------------------------------
#
#
sub check_if_not_loanable {
    my ($zid, $marc) = @_;

    # not-for-loan check
    my $isNFL = 0;
    
    foreach my $hr_nfl (@$nfl) {                           # all not-for-loan data

	next unless ($hr_nfl->{zid} == $zid);                # skip unless this is the right server

	# get all the matching fields
	my @nfl_fields = $marc->field( $hr_nfl->{tag} );
	foreach my $nfl_fld (@nfl_fields) {
	    
	    if ($nfl_fld->is_control_field()) {
		my $nfl_data = $nfl_fld->data();
		if ($hr_nfl->{atstart}) {
		    next unless ($nfl_data =~ /^$hr_nfl->{text}/);
		} else {
		    next unless ($nfl_data =~ /$hr_nfl->{text}/);
		}
		$isNFL = 1;
		last;
		
	    } else {
		my @nfl_subfields = $nfl_fld->subfield( $hr_nfl->{subfield} );
		foreach my $nfl_sub (@nfl_subfields) {
		    if ($hr_nfl->{atstart}) {
			next unless ($nfl_sub =~ /^$hr_nfl->{text}/);
		    } else {
			next unless ($nfl_sub =~ /$hr_nfl->{text}/);
		    }
		    $isNFL = 1;
		    last;
		}
	    }
	    last if ($isNFL);
	}
	last if ($isNFL);
    }

    return $isNFL;
}

#----------------------------------------------------------------------------------------
#
#
sub clean_up_and_move_on {
    my $sessionid = shift;
    my $ar_conn = shift;
    my $z = shift;

    $log->log( level => 'debug', message => timestamp() . "clean up and move on\n");
    for (my $i = 0; $i < @$ar_conn; $i++) {
	my $h = $dbh->selectrow_hashref("SELECT event, msg FROM status_check WHERE ((sessionid=?) AND (zid=?))",
					undef,
					$sessionid,
					$ar_conn->[$i]{id},
	    );
	
	if ($h->{event} == 10) {
	    if ((exists $ar_conn->[$i]{hits}) && ($ar_conn->[$i]{hits} > 0)) {
		$dbh->do("UPDATE status_check SET event=?, msg=? WHERE ((sessionid=?) AND (zid=?))",
			 undef,
			 99,
			 $ar_conn->[$i]{hits} . " hits.  Records acquired.",
			 $sessionid,
			 $ar_conn->[$i]{id},
		    );
	    } else {
		# Zero records found
		$dbh->do("UPDATE status_check SET event=? WHERE ((sessionid=?) AND (zid=?))",
			 undef,
			 99,
			 $sessionid,
			 $ar_conn->[$i]{id},
		    );
	    }
	} elsif ($h->{event} == 4) {
	    # timeout - disable it so it doesn't annoy anyone else
	    $dbh->do("UPDATE zservers SET alive=0 WHERE (id=?)",
		     undef,
		     $ar_conn->[$i]{id},
		);
	    
	    # Send an email about it
	    eval {
		my $sendmail = "/usr/sbin/sendmail -t";
		open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
		print SENDMAIL "From: plslib1\@mts.net\n";
		print SENDMAIL "To: David.Christensen\@gov.mb.ca\n";
		print SENDMAIL "Subject: Maplin-3 message: zServer " . $ar_conn->[$i]{id} . "(" . $ar_conn->[$i]{name} . ") down\n";
		print SENDMAIL "Content-type: text/plain\n\n";
		print SENDMAIL "zServer is not responding:\n";
		print SENDMAIL "zServer id : " . $ar_conn->[$i]{id} . "\n";
		print SENDMAIL "Name       : " . $ar_conn->[$i]{name} . "\n";
		print SENDMAIL "Connection : " . $ar_conn->[$i]{z3950_connection_string} . "\n";
		print SENDMAIL "Noticed    : " . localtime;
		print SENDMAIL "\n\n";
		close(SENDMAIL);
	    };
	    if ($@) {
		$log->log( level => 'debug', message => timestamp() . "zServer $ar_conn->[i]{id} timed out, but I couldn't send an email about it!\n");
	    }
	    
	}
	# explicitly close connections
	$z->[$i]->destroy();
	$log->log( level => 'info', message => timestamp() . "connection [$i] closed\n");
    }
}

#-----------------------------------------------------------------------
#
#
sub serialized_search {
    my $sessionid = shift;
    my $elementSet = shift;
    my $pqf = shift;
    my $conn_info = shift;

    my $usr = shift;
    my $pwd = shift;
    my $scan = shift;

    $zid = $conn_info->{id};
    $connection_string = $conn_info->{z3950_connection_string};
    $preferredRecordSyntax = $conn_info->{preferredrecordsyntax};

    $preferredRecordSyntax = "usmarc" unless ($preferredRecordSyntax);
    $elementSet = "f" unless ($elementSet);
    $pqf = '@attr 1=4 "duck hunting"' unless ($pqf);

    $dbh->do("INSERT INTO status_check (sessionid, zid, event, msg) VALUES (?,?,?,?)",
	     undef,
	     $sessionid,
	     $zid,
	     0,
	     "Connecting..."
	);
    
    my $s = "";
    my $conn;
    
    my $rs;
    my $n;

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
	$log->log( level => 'warning', message => timestamp() . zoom_error_string( $conn ) . "\n");
	$dbh->do("UPDATE status_check SET event=?, msg=? WHERE ((sessionid=?) AND (zid=?))",
		 undef,
		 $conn->errcode(),
		 $conn->errmsg(),
		 $sessionid,
		 $zid,
	    );
	
    } else {

        # search
	eval {
	    $rs = $conn->search_pqf($pqf);
	    $n = $rs->size();
	    $conn_info->{hits} = $n;
	    
	    $n = RESULTS_LIMIT if ($n > RESULTS_LIMIT); # let's be reasonable
	    
	    if ($n > 0) {
		$rs->records(0, $n, 0); # prefetch

		$dbh->do("UPDATE status_check SET event=?, msg=? WHERE ((sessionid=?) AND (zid=?))",
			 undef,
			 ZOOM::Event::ZEND,
			 $conn_info->{hits} . " hits.",
			 $sessionid,
			 $conn_info->{id},
		    );
		store_result_set($rs, $conn_info);

	    }
	};
	if ($@) {
	    $log->log( level => 'warning', message => timestamp() . zoom_error_string( $conn ) . "\n");
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

    my $stored = 0;
    my $size = $rs->size();	
    $size = RESULTS_LIMIT if ($size > RESULTS_LIMIT);
    $log->log( level => 'info', message => timestamp() . "store_result_set for [$conn_info->{name}], size: $size\n");
    
#    $log->log( level => 'debug', Dumper($rs) );
	
    for (my $j=1; $j <= $size; $j++) {        # for each record within the result set...
	$log->log( level => 'debug', message => timestamp() . "record $j\n");

	eval {
	    local $SIG{ALRM} = sub { die "alarm!\n" }; # # NB: \n required
	    alarm 10;

	    if ($rs->record($j-1)) {
		$log->log( level => 'debug', message => timestamp() . "checking for errors\n");
		if ($rs->record($j-1)->error()) {
		    my($code, $msg, $addinfo, $dset) = $rs->record($j-1)->error();
		    # log this stuff...
		    $log->log( level => 'warning', message => timestamp() . "[$code $msg $addinfo $dset]\n");
		    
		} else {
		    $log->log( level => 'debug', message => timestamp() . "no errors (yet)\n");
		    
		    my $marc;
		    my $raw;
		    
		    if ($conn_info->{preferredrecordsyntax} eq 'opac') {           # server returns "opac" records
			my $xml = $rs->record($j-1)->get("opac");
			$marc = get_opac_record( $xml, $ar_conn );
			
		    } else {                                                       # server returns marc records
			$raw = $rs->record($j-1)->raw();
			$marc = get_marc_record( $raw );
		    }
		    
		    if ($marc) {
			
			my $isNFL = check_if_not_loanable( $conn_info->{id}, $marc );
#		    my $isNFL = 0;  # just for debugging, assume everything is loanable....!!!
			
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
			    
			    # hook for mid-stream processing of records
			    if (_process($marc, $conn_info)) { undef $raw };
			    
			    # The underlying postgres tables are UTF-8.  Postgres is smart enough to translate, 
			    #   as long as it knows what to expect.
			    # If the MARC record lies, there's not much we can do about it.
			    # Without specifically setting the client encoding (even thought it's not perfect),
			    #   we would often hang on the 'insert into marc' line.
			    if ($marc->encoding() eq 'UTF-8') {
				$dbh->do("SET CLIENT_ENCODING TO Unicode");
			    } else {
				$dbh->do("SET CLIENT_ENCODING TO Latin1");
			    }

			    $log->log( level => 'debug', message => timestamp() . "inserting into marc table\n");
			    my $rv;
			    eval {
				$rv = $dbh->do("INSERT INTO marc (sessionid, id, marc, zid, found_at_server,title,author,isbn) VALUES (?,?,?,?,?,?,?,?)",
					       undef,
					       $sessionid,
					       $sequential_record_id++,
					       $raw ? $raw : $marc->as_usmarc(),
					       $conn_info->{id},
					       $conn_info->{name},
					       sprintf("%.254s",$title),
					       sprintf("%.254s",$author),
					       $isbn
				    );
			    };
			    if ($@) {
				$log->log( level => 'warning', message => timestamp() . "eval failed - insert into marc table, connection [$conn_info->{id}, $conn_info->{name}], title [$title], " . $@ . "\n");
			    } else {
				$log->log( level => 'debug', message => timestamp() . "return value from insert into marc, rv=[$rv]\n");
				$stored++;
				
				# this should never happen:
				unless ($rv) {
				    $log->log( level => 'error', message => timestamp() . "insert into marc returned undef: $DBI::errstr\n");
				}
			    }
			}
			
			if (exists $conn_info->{acquiring}) {
			    $conn_info->{acquiring} += 1;
			} else {
			    $conn_info->{acquiring} = 1;
			}
			$dbh->do("UPDATE status_check SET msg=? WHERE ((sessionid=?) AND (zid=?))",
				 undef,
				 $conn_info->{hits} . " hits.  Saving record " . $conn_info->{acquiring},
				 $sessionid,
				 $conn_info->{id},
			    );
			
			$id++;
		    }
		}
	    } else {
		$log->log( level => 'debug', message => timestamp() . "Result set record $j does not exit???  Result set size reported as [" . $rs->size() . "]\n");
		#$log->log( level => 'debug', message => timestamp() . $rs->record($j-1)->render() );
	    }

	    alarm 0; # turn off alarm
	}; # end of eval

	if ($@) {
	    $log->log( level => 'debug', message => timestamp() . "error: " . $@ . "\n" );
	    if ($@ eq "alarm\n") {
		# timed out
		$log->log( level => 'debug', message => timestamp() . "Record was taking too long, so bailed.\n" );
	    }
	    #die unless $@ eq "alarm\n"; # propagate unexpected errors
	} else {
	    # didn't
	    $log->log( level => 'debug', message => timestamp() . "Finished processing record.\n");
	}
    }
    $log->log( level => 'info', message => timestamp() . "store_result_set for [$conn_info->{name}], stored: $stored\n");

    # statistics
    $dbh->do("UPDATE search_statistics SET records=records+? WHERE sessionid=?",
	     undef,
	     $stored,
	     $sessionid . '-' . $$
	);

    $rs->destroy();  # clean up after ourselves.
}


#=================================================================================================

#-----------------------------------------------------------------------
#
# Mid-stream processing (ie - after record returned from zserver,
# before storing in marc table)
# Returns 1 if the marc record changes.
#
sub _process {
    my $marc = shift;
    my $conn_info = shift;

    if ($conn_info->{name} =~ /^EBSCOhost/) {
	my $db = $conn_info->{z3950_connection_string};
	$db =~ s/.*\/(.*)$/$1/;
	_EBSCOize($marc,$db,$conn_info->{z3950_connection_string});
	return 1;
    }
    return 0;
}

#-----------------------------------------------------------------------
#
#
sub _EBSCOize {
    my $marc = shift;
    my $db = shift;
    my $description = shift;

    my $user = $ebsco_href->{ebsco_user};
    my $pass = $ebsco_href->{ebsco_pass};

    my @f856 = $marc->field('856');
    foreach my $fld (@f856) {
	$marc->delete_field( $fld );
    }
    my $accession_number = $marc->subfield('016','a');
    my $field = MARC::Field->new(
	856, '4', '0',
	'u' => "http://search.ebscohost.com/login.aspx?authtype=uid&user=$user&password=$pass&direct=true&db=$db&AN=$accession_number&site=ehost-can",
	'z' => "link to article on $description"
	);
    my $numFldsAppended = $marc->append_fields( $field );
}

#-----------------------------------------------------------------------
#
#
sub zoom_error_string {
    $conn = shift;

    ($errcode, $errmsg, $addinfo, $diagset) = $conn->error_x();
    return "ZOOM error $errcode: $errmsg, $addinfo, $diagset\n";
}

#-----------------------------------------------------------------------
#
#
sub timestamp {
    #  0    1    2     3     4    5     6     7     8
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    return sprintf("%04d-%02d-%02d %02d:%02d:%02d %-35s", 
		   $year + 1900, $mon + 1, $mday, $hour, $min, $sec,
		   $sessionid
	);
}
