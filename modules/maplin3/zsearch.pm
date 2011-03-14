package maplin3::zsearch;
use warnings;
use strict;
use base 'maplin3base';
use ZOOM;
use MARC::Record;
use Data::Dumper;
#use Fcntl qw(LOCK_EX LOCK_NB);

#--------------------------------------------------------------------------------
# Define our runmodes
#
sub setup {
    my $self = shift;
    $self->start_mode('search_simple_ajax_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'search_simple_ajax_form'    => 'search_simple_ajax_process',
	'search_common_form'         => 'search_common_process',
	'results_form'               => 'results_process',
	'show_marc_form'             => 'show_marc_process',
	'request_form'               => 'request_process',
	'send_email_form'            => 'send_email_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub search_simple_ajax_process {
    my $self = shift;
    my $q = $self->query;

    # Get list of standard (ILL) resource zservers
    my $SQL_getServersList = "SELECT id, name, available, alive FROM zservers WHERE isstandardresource=1 ORDER BY name";
    my $ar_SRconn = $self->dbh->selectall_arrayref(
	$SQL_getServersList,
	{ Slice => {} }
	);

    # Get list of electronic resource zservers
    $SQL_getServersList = "SELECT id, name, available, alive FROM zservers WHERE iselectronicresource=1 ORDER BY name";
    my $ar_ERconn = $self->dbh->selectall_arrayref(
	$SQL_getServersList,
	{ Slice => {} }
	);

    # Get list of database zservers
    $SQL_getServersList = "SELECT id, name, available, alive FROM zservers WHERE isdatabase=1 ORDER BY name";
    my $ar_DBconn = $self->dbh->selectall_arrayref(
	$SQL_getServersList,
	{ Slice => {} }
	);

    # Get list of web resource zservers
    $SQL_getServersList = "SELECT id, name, available, alive FROM zservers WHERE iswebresource=1 ORDER BY name";
    my $ar_WRconn = $self->dbh->selectall_arrayref(
	$SQL_getServersList,
	{ Slice => {} }
	);

    if ($q->param('newsearch')) {

	if ($q->param('keywords')) {
	    #
	    # start the external process
	    #	    
	    my $index = $q->param('index');
	    my $searchTerms = $q->param('keywords');
	    $self->log->debug("searchTerms: [$searchTerms]");

	    my $pqf = "\@attr 1=";
	    if ($index eq "title") {
		$pqf .= "4";
	    } elsif ($index eq "author") {
		$pqf .= "1003";
	    } elsif ($index eq "subject") {
		$pqf .= "21";
	    } else {  # any
		$pqf .= "1016";
	    }
	    $pqf .= " \@attr 2=3 \@attr 4=2 \"";
	    $pqf .= $searchTerms;
	    $pqf .= "\"";
	    $pqf =~ s/\'//g;  # HACK!  Toast any single quotes, so we can quote the whole thing
	                      #        in order to pass it to the shell.

	    my $includeStandardResources = 0;
	    my $includeElectronicResources = 0;
	    my $includeDatabaseResources = 0;
	    my $includeWebResources = 0;
	    $includeStandardResources = 1 if ($q->param('inclSR'));
	    $includeElectronicResources = 1 if ($q->param('inclER'));
	    $includeDatabaseResources = 1 if ($q->param('inclDB'));
	    $includeWebResources = 1 if ($q->param('inclWR'));
	    my $cntIncludeCategories = $includeStandardResources + $includeElectronicResources + $includeDatabaseResources + $includeWebResources;
	    
	    # Who are we?
	    my $session = $self->session->id();
	    $self->log->debug("starting search process, sessionid: $session");
	    
	    # Clear any old search results
	    $self->dbh->do("DELETE FROM marc WHERE sessionid=?",undef,$session);
	    
	    # Clear the status_check table
	    $self->dbh->do("DELETE FROM status_check WHERE sessionid=?",undef,$session);
	    
	    # simple, but may allow multiple instances to run (which is ok, if there are not too many....
#	    my $system_busy = 0;
#	    for (my $i=1; $i<10; $i++) {
#		if (-e '/tmp/maplin.zsearch') {
#		    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat('/tmp/maplin.zsearch');
#		    if (time() - $mtime > 180) {
#			# delete the fakelock if it's more than 3 minutes old
#			# (it didn't get cleaned up... don't know why yet)
#			unlink '/tmp/maplin.zsearch';
#		    }
#		    $system_busy = 1;
#		    sleep 3;
#		} else {
#		    open FAKELOCK, ">>", '/tmp/maplin.zsearch' or die "Cannot open lock file: $!";
#		    print FAKELOCK "$$\n";
#		    close FAKELOCK;
#		    chmod 0666, "/tmp/maplin.zsearch"; # world-readable, world-writable, so cron can clean up
#		    $system_busy = 0;
#		    last;
#		}
#		
#	    }
#	
#	    if ($system_busy) {
#		my $template = $self->load_tmpl('search/busy.tmpl');	
#		$template->param( username => $self->authen->username,
##				  sessionid => $session,
#		    );
#		return $template->output;
#
#	    } else {
		# system is not (very) busy

		if (my $pid = fork) {            # parent does
		    use POSIX qw( strftime );
		    
		    $self->header_add(
			# date in the past
			-expires       => 'Sat, 26 Jul 1997 05:00:00 GMT',
			# always modified
			-Last_Modified => strftime('%a, %d %b %Y %H:%M:%S GMT', gmtime),
			# HTTP/1.0
			-Pragma        => 'no-cache',
			# HTTP/1.1
			-Cache_Control => join(', ', qw(
                        no-store
                        no-cache
                        must-revalidate
                        post-check=0
                        pre-check=0
                        )),
			);
		    
		    my $template = $self->load_tmpl('search/searching_ajax.tmpl');	
		    $template->param( username => $self->authen->username,
				      sessionid => $session,
			);
		    return $template->output;
		    
		} elsif (defined $pid) {         # child does
		    close STDOUT;  # so parent can go on
		    
		    {
			#Stop the annoying (and log-filling)
			#"Name "maplin3::zsearch::F" used only once: possible typo"
			no warnings;
			#local $^W = 0;
			
			# Need the user id in order to look up zserver credentials....
			my $userhref = $self->dbh->selectrow_hashref("SELECT lid from libraries WHERE name=?", {}, $self->authen->username);
			
			# Create the zservers list
			my @selectedZservers;
			my $sqlZserversList = "SELECT id FROM zservers WHERE (available=1 and alive=1)";
			
			my $sqlPhrase = "";
			if ($includeStandardResources) {
			    $sqlPhrase .= " OR isstandardresource=1";
			}
			
			if ($includeElectronicResources) {
			    $sqlPhrase .= " OR iselectronicresource=1";
			}
			
			if ($includeDatabaseResources) {
			    $sqlPhrase .= " OR isdatabase=1";
			}
			
			if ($includeWebResources) {
			    $sqlPhrase .= " OR iswebresource=1";
			}
			
			$sqlPhrase =~ s/^ OR (.*)/$1/; # remove the initial " OR "
			$sqlZserversList .= " AND ($sqlPhrase)";
			
			my $ar_ids = $self->dbh->selectall_arrayref(
			    $sqlZserversList
			    );
			my $areAnySelected = 0;
			foreach my $ar_id (@$ar_ids) {
			    #$self->log->debug("id: " . $ar_id->[0]);
			    if ($q->param("cb_" . $ar_id->[0])) {
				push @selectedZservers, $ar_id->[0];
				$areAnySelected = 1;
			    }
			}
			# If there were no individual zserver selections,
			# select them all
			unless ($areAnySelected) {
			    foreach my $ar_id (@$ar_ids) {
				push @selectedZservers, $ar_id->[0];
			    }
			}
			
			$pqf = "'" . $pqf . "'";
			$self->log->debug("pqf: $pqf\nzservers: " . Dumper(@selectedZservers));
			
			unless (open F, "-|") {
			    open STDERR, ">&=1";
			    exec "/opt/maplin3/externals/maplin3-zsearch-pqf.pl", $userhref->{lid}, $session, 'library', $pqf, @selectedZservers;
			    die "Cannot execute /opt/maplin3/externals/maplin3-zsearch-pqf.pl";
			}
			
			# buf will contain STDOUT/STDERR of the command exec'd
			#my $buf = "";
			#while (<F>) {
			#	$buf .= $_;
			#}
			# do something with buf, if you like :-)
			
			# In our case, we just want to let maplin3-zsearch.pl go off
			# and do it's thing. (It updates the db table status_check,
			# and we really don't want to wait for it - parent is checking
			# the db and refreshing itself)
		    }
		    exit 0;
		    
		} else {
		    die "Cannot fork: $!";
		}
#	    }
	}

    } else {
	if ($q->param('cancel')) {
	    # cancel an existing search
	    $self->_cancel_search();
	}

	my $userhref = $self->dbh->selectrow_hashref("SELECT use_standardresource, use_databaseresource, use_electronicresource, use_webresource from libraries WHERE name=?", {}, $self->authen->username);

	my $template = $self->load_tmpl('search/simple_ajax.tmpl');	
	$template->param( username => $self->authen->username,
			  sessionid => $self->session->id(),
			  use_standardresource   => $userhref->{use_standardresource} ? 1 : 0,
			  use_databaseresource   => $userhref->{use_databaseresource} ? 1 : 0,
			  use_electronicresource => $userhref->{use_electronicresource} ? 1 : 0,
			  use_webresource        => $userhref->{use_webresource} ? 1 : 0,
			  SRzservers => $ar_SRconn,
			  ERzservers => $ar_ERconn,
			  DBzservers => $ar_DBconn,
			  WRzservers => $ar_WRconn,
	    );
	return $template->output;
    }

}


#--------------------------------------------------------------------------------
#
#
sub search_common_process {
    my $self = shift;
    my $q = $self->query;

    # Get list of standard (ILL) resource zservers
    my $SQL_getServersList = "SELECT id, name, available, alive FROM zservers WHERE isstandardresource=1 ORDER BY name";
    my $ar_SRconn = $self->dbh->selectall_arrayref(
	$SQL_getServersList,
	{ Slice => {} }
	);

    # Get list of electronic resource zservers
    $SQL_getServersList = "SELECT id, name, available, alive FROM zservers WHERE iselectronicresource=1 ORDER BY name";
    my $ar_ERconn = $self->dbh->selectall_arrayref(
	$SQL_getServersList,
	{ Slice => {} }
	);

    # Get list of database resource zservers
    $SQL_getServersList = "SELECT id, name, available, alive FROM zservers WHERE isdatabase=1 ORDER BY name";
    my $ar_DBconn = $self->dbh->selectall_arrayref(
	$SQL_getServersList,
	{ Slice => {} }
	);

    # Get list of web resource zservers
    $SQL_getServersList = "SELECT id, name, available, alive FROM zservers WHERE iswebresource=1 ORDER BY name";
    my $ar_WRconn = $self->dbh->selectall_arrayref(
	$SQL_getServersList,
	{ Slice => {} }
	);

    if ($q->param('newsearch')) {

	if ( ($q->param('title_keywords'))
	     || ($q->param('author_keywords')) 
	     || ($q->param('subject_keywords'))
	     || ($q->param('any_keywords'))
	    ){
	    #
	    # start the external process
	    #

	    # build the pqf query string
	    my @pqf_chunks;
	    if ($q->param('any_keywords')) {
		push @pqf_chunks, "\@attr 1=1016 \@attr 2=3 \@attr 4=2 \"" . $q->param('any_keywords') . "\"";
	    }
	    if ($q->param('title_keywords')) {
		push @pqf_chunks, "\@attr 1=4 \@attr 2=3 \@attr 4=2 \"" . $q->param('title_keywords') . "\"";
	    }
	    if ($q->param('author_keywords')) {
		push @pqf_chunks, "\@attr 1=1003 \@attr 2=3 \@attr 4=2 \"" . $q->param('author_keywords') . "\"";
	    }
	    if ($q->param('subject_keywords')) {
		push @pqf_chunks, "\@attr 1=21 \@attr 2=3 \@attr 4=2 \"" . $q->param('subject_keywords') . "\"";
	    }
	    my $pqf = "";
	    foreach my $chunk (@pqf_chunks) {
		$pqf = "\@and $pqf $chunk";
	    }
	    $pqf =~ s/\@and  //; # clean up the first one - note the double space!
	    $pqf =~ s/\'//g;     # HACK! Toast any single quotes, so we can quote the whole thing
	    $pqf = "\'$pqf\'";   #       in order to pass it to the shell.
	    
	    my $includeStandardResources = 0;
	    my $includeElectronicResources = 0;
	    my $includeDatabaseResources = 0;
	    my $includeWebResources = 0;
	    $includeStandardResources = 1 if ($q->param('inclSR'));
	    $includeElectronicResources = 1 if ($q->param('inclER'));
	    $includeDatabaseResources = 1 if ($q->param('inclDB'));
	    $includeWebResources = 1 if ($q->param('inclWR'));
	    my $cntIncludeCategories = $includeStandardResources + $includeElectronicResources + $includeDatabaseResources + $includeWebResources;
	    
	    # Who are we?
	    my $session = $self->session->id();
	    $self->log->debug("starting search process, sessionid: $session");
	    
	    # Clear any old search results
	    $self->dbh->do("DELETE FROM marc WHERE sessionid=?",undef,$session);
	    
	    # Clear the status_check table
	    $self->dbh->do("DELETE FROM status_check WHERE sessionid=?",undef,$session);
	    
#	    # simple, but may allow multiple instances to run (which is ok, if there are not too many....
#	    my $system_busy = 0;
#	    for (my $i=1; $i<10; $i++) {
#		if (-e '/tmp/maplin.zsearch') {
#		    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat('/tmp/maplin.zsearch');
#		    if (time() - $mtime > 180) {
#			# delete the fakelock if it's more than 3 minutes old
#			# (it didn't get cleaned up... don't know why yet)
#			unlink '/tmp/maplin.zsearch';
#		    }
#		    $system_busy = 1;
#		    sleep 3;
#		} else {
#		    open FAKELOCK, ">>", '/tmp/maplin.zsearch' or die "Cannot open lock file: $!";
#		    print FAKELOCK "$$\n";
#		    close FAKELOCK;
#		    chmod 0666, "/tmp/maplin.zsearch"; # world-readable, world-writable, so cron can clean up
#		    $system_busy = 0;
#		    last;
#		}
#		
#	    }
#	
#	    if ($system_busy) {
#		my $template = $self->load_tmpl('search/busy.tmpl');	
#		$template->param( username => $self->authen->username,
##				  sessionid => $session,
#		    );
#		return $template->output;
#
#	    } else {
		# system is not (very) busy

		if (my $pid = fork) {            # parent does
		    use POSIX qw( strftime );
		    
		    $self->header_add(
			# date in the past
			-expires       => 'Sat, 26 Jul 1997 05:00:00 GMT',
			# always modified
			-Last_Modified => strftime('%a, %d %b %Y %H:%M:%S GMT', gmtime),
			# HTTP/1.0
			-Pragma        => 'no-cache',
			# HTTP/1.1
			-Cache_Control => join(', ', qw(
                        no-store
                        no-cache
                        must-revalidate
                        post-check=0
                        pre-check=0
                        )),
			);
		    
		    my $template = $self->load_tmpl('search/searching_ajax.tmpl');	
		    $template->param( username => $self->authen->username,
				      sessionid => $session,
				      from_common_search => 1,
			);
		    return $template->output;
		    
		} elsif (defined $pid) {         # child does
		    close STDOUT;  # so parent can go on
		    
		    {
			#Stop the annoying (and log-filling)
			#"Name "maplin3::zsearch::F" used only once: possible typo"
			no warnings;
			#local $^W = 0;
			
			# Need the user id in order to look up zserver credentials....
			my $userhref = $self->dbh->selectrow_hashref("SELECT lid from libraries WHERE name=?", {}, $self->authen->username);
			
			# Create the zservers list
			my @selectedZservers;
			my $sqlZserversList = "SELECT id FROM zservers WHERE (available=1 and alive=1)";
			
			my $sqlPhrase = "";
			if ($includeStandardResources) {
			    $sqlPhrase .= " OR isstandardresource=1";
			}
			
			if ($includeElectronicResources) {
			    $sqlPhrase .= " OR iselectronicresource=1";
			}
			
			if ($includeDatabaseResources) {
			    $sqlPhrase .= " OR isdatabase=1";
			}
			
			if ($includeWebResources) {
			    $sqlPhrase .= " OR iswebresource=1";
			}
			
			$sqlPhrase =~ s/^ OR (.*)/$1/; # remove the initial " OR "
			$sqlZserversList .= " AND ($sqlPhrase)";
			
			my $ar_ids = $self->dbh->selectall_arrayref(
			    $sqlZserversList
			    );
			my $areAnySelected = 0;
			foreach my $ar_id (@$ar_ids) {
			    #$self->log->debug("id: " . $ar_id->[0]);
			    if ($q->param("cb_" . $ar_id->[0])) {
				push @selectedZservers, $ar_id->[0];
				$areAnySelected = 1;
			    }
			}
			# If there were no individual zserver selections,
			# select them all
			unless ($areAnySelected) {
			    foreach my $ar_id (@$ar_ids) {
				push @selectedZservers, $ar_id->[0];
			    }
			}
			
			$self->log->debug("pqf: $pqf\nzservers: " . Dumper(@selectedZservers));
			
			unless (open F, "-|") {
			    open STDERR, ">&=1";
			    exec "/opt/maplin3/externals/maplin3-zsearch-pqf.pl", $userhref->{lid}, $session, 'library', $pqf, @selectedZservers;
			    die "Cannot execute /opt/maplin3/externals/maplin3-zsearch-pqf.pl";
			}
			
			# buf will contain STDOUT/STDERR of the command exec'd
			#my $buf = "";
			#while (<F>) {
			#	$buf .= $_;
			#}
			# do something with buf, if you like :-)
			
			# In our case, we just want to let maplin3-zsearch.pl go off
			# and do it's thing. (It updates the db table status_check,
			# and we really don't want to wait for it - parent is checking
			# the db and refreshing itself)
		    }
		    exit 0;
		    
		} else {
		    die "Cannot fork: $!";
		}
#	    }
	}

    } else {
	if ($q->param('cancel')) {
	    # cancel an existing search
	    $self->_cancel_search();

	}

	my $userhref = $self->dbh->selectrow_hashref("SELECT use_standardresource, use_databaseresource, use_electronicresource, use_webresource from libraries WHERE name=?", {}, $self->authen->username);

	my $template = $self->load_tmpl('search/common_search.tmpl');	
	$template->param( username => $self->authen->username,
			  sessionid => $self->session->id(),
			  use_standardresource   => $userhref->{use_standardresource} ? 1 : 0,
			  use_databaseresource   => $userhref->{use_databaseresource} ? 1 : 0,
			  use_electronicresource => $userhref->{use_electronicresource} ? 1 : 0,
			  use_webresource        => $userhref->{use_webresource} ? 1 : 0,
			  SRzservers => $ar_SRconn,
			  ERzservers => $ar_ERconn,
			  DBzservers => $ar_DBconn,
			  WRzservers => $ar_WRconn,
	    );
	return $template->output;
    }

}

#--------------------------------------------------------------------------------
#
#
sub _cancel_search {
    my $self = shift;

    my $sessionid = $self->session->id();
    
    my $href = $self->dbh->selectrow_hashref(
	"SELECT pid FROM search_pid WHERE sessionid=?",
	{},
	$sessionid,
	);
    
    my $searchpid = $href->{pid};
    if ($searchpid) {
	$self->log->debug("cancelling search, pid [$searchpid]");
	my @args = ("kill", $searchpid);
	system(@args);
	if ($? == -1) { 
	    $self->log->debug("kill $searchpid, failed to execute"); 
	} else {
	    # Toast the sessionid/pid db entry
	    $self->dbh->do("DELETE FROM search_pid WHERE sessionid=?",
			   undef,
			   $sessionid,
		);
	}
    }

    # clean up status_check
    $self->dbh->do("DELETE FROM status_check WHERE sessionid=?",
		   undef,
		   $sessionid,
	);

    # toast any already-saved records
    $self->dbh->do("DELETE FROM marc WHERE sessionid=?",
		   undef,
		   $sessionid,
	);
}

#--------------------------------------------------------------------------------
#
#
sub results_process {
    my $self = shift;
    my $q = $self->query;

    my $limit;

    my $marc_aref;
    my @bibs;

    # For the lists of limits:
    my %limits_subjects;
    my %limits_authors;
    my %limits_pubdate;

    my $countRecords = 0;
	
    my $connstatus = "";
    my @res = ();

    my $pqf;
    if ($q->param('pqf')) {
	$pqf = $q->param('pqf');
    }

    # 'Title' is special - and always displayed
    my @dispFieldList = qw/Author PubDate ISBN Abstract Subjects Info Link Holdings/;
#    my @dispFieldList = qw/Author PubDate ISBN Subjects Link/;
    my @hidden_fields; # passed to template
    my @shown_fields;  # passed to template
    my $DisplayableFields_href = $self->_adjust_displayed_fields(\@dispFieldList, \@hidden_fields, \@shown_fields);
    $DisplayableFields_href->{'Title'} = 1;

    my $currentLimits = $self->_adjust_current_limits();

    # Get the list of zservers (and info on where in the MARC they keep their holdings data)
    my $ar_zservers = $self->dbh->selectall_arrayref(
	"SELECT id, holdings_tag, holdings_location, holdings_callno, holdings_collection, holdings_avail, holdings_due, handles_holdings_improperly FROM zservers",
	{ Slice => {} }
	);
    
    # Sorting
    my $sort_by = $q->param('sort');
    if (not defined $sort_by) {
	$sort_by = $self->session->param('sort_by');
    }
    if (not defined $sort_by) {
	$sort_by = "title";
    }
    $self->session->param('sort_by', $sort_by);
#    $self->log->debug("Search results: sorting by $sort_by");

    # Get the array of MARC records that were found
    my $sql = "SELECT id, marc, zid, found_at_server, isbn FROM marc WHERE sessionid=?";
    if ($sort_by eq 'author') {              # --Hmm.  Can't use a placeholder for ORDER BY....
	$sql .=  " ORDER BY author";
    } else {
	$sql .=  " ORDER BY title";
    }
#    $self->log->debug("Search results: " . $sql . ", sessionid [" . $self->session->id() . "], sort by $sort_by");
    $marc_aref = $self->dbh->selectall_arrayref($sql,
						undef,
						$self->session->id(),
	);
#    $self->log->debug("Total of " . @$marc_aref . " rows from db");
    
    my %usedISBNs;

    my $i = 0;
    foreach my $row_array (@$marc_aref) {

	my $rec_id = $row_array->[0];
	my $marc_string = $row_array->[1];
#	my $marcrec = new_from_usmarc MARC::Record($marc_string);   # this can blow up!
	my $zid = $row_array->[2];
	my $found_at_server = $row_array->[3];
	my $isbn = $row_array->[4];
	
	my $marcrec;
	eval {
	    no warnings;
	    local $SIG{'__DIE__'};
	    $marcrec = new_from_usmarc MARC::Record($marc_string); 
	};
	if ($@) {
	    # record blew up
	    $self->log->debug("Record blew up: isbn [$isbn], marc: [$marc_string]\n...so skipping");
	    next;
	} else {
	    # successfully converted to MARC::Record
	    $self->log->debug("successfully converted to MARC::Record");
	}

	
	if ($self->_limitCheckOK($marcrec, $currentLimits)) {

	    my $bibinfo_href;

	    # need to check if there *is* an ISBN, first....
	    if ((not defined $isbn) || (length($isbn) == 0)) {
		$isbn = "No ISBN in record ($rec_id)";

	    } else {

		# if this is an e-book, we want a separate result.
		# alter the isbn...

		if ($self->_isEbook( $marcrec )) {
		    $isbn = '(e)' . $isbn;
		}

	    }

	    if (exists $usedISBNs{ $isbn }) {

		# Build a holdings array for the new record
		my $holdings_aref = $self->_build_holdings($rec_id, $zid, $ar_zservers, $marcrec);

		# Get a reference to the existing holdings array
		my $bibholdings_aref = $bibs[ $usedISBNs{$isbn} ]->{holdings};

		# Tack the new array onto the existing one
		@$bibholdings_aref = (@$bibholdings_aref, @$holdings_aref);

		# Update the holdings count
		$bibinfo_href->{holdings_count} = scalar @{ $bibs[ $usedISBNs{$isbn} ]->{holdings} };
		
		# build subject list
		my @subjlist = $marcrec->field("6..");
		my @bibsubjects;
		foreach my $subj (@subjlist) {
		    # force scalar context, so we only get the first $a in the field
		    my $s = $subj->subfield('a');
		    if ($s) {
			push @bibsubjects, { subject => $s }; # for display
		    }
		}

		# Get a reference to the existing subjects array
		my $primary_subjects_aref = $bibs[ $usedISBNs{$isbn} ]->{search_results_subjects};

		# Tack the new array onto the existing one
		@$primary_subjects_aref = (@$primary_subjects_aref, @bibsubjects);
		# ...and remove duplicates
		my %seen;
		@$primary_subjects_aref = grep { ! $seen{ $_->{subject} }++ } @$primary_subjects_aref;
		

	    } else {
		#
		# This is a new ISBN
		#
		$usedISBNs{ $isbn } = scalar @bibs;  # usedISBNs will hold the array index of the 'primary' MARC
		$countRecords++;

		# Build displayable fields from MARC record
		$bibinfo_href = $self->_build_bibinfo( $rec_id, $zid, $marcrec, $isbn );

		# Build holdings array for this record
		my $holdings_aref = $self->_build_holdings($rec_id, $zid, $ar_zservers, $marcrec);
		$bibinfo_href->{holdings} = $holdings_aref;
		$bibinfo_href->{holdings_count} = scalar @{ $bibinfo_href->{holdings} };

		# build subject list for display
		my @subjlist = $marcrec->field("6..");
		my @bibsubjects;  # for display
		foreach my $subj (@subjlist) {
		    # force scalar context, so we only get the first $a in the field
		    my $s = $subj->subfield('a');
		    if ($s) {
			push @bibsubjects, { subject => $s }; # for display
		    }
		}
		# add subjects list to the things we can (potentially) display
		$bibinfo_href->{search_results_subjects} = \@bibsubjects;

		# Visibility info - this must go into each bib due to the way HTML::Template
		# handles variables and loops (unless we wanted to make them global....)
		$bibinfo_href->{isVisible_Title}    = $DisplayableFields_href->{ 'Title'    };
		$bibinfo_href->{isVisible_Author}   = $DisplayableFields_href->{ 'Author'   };
		$bibinfo_href->{isVisible_PubDate}  = $DisplayableFields_href->{ 'PubDate'  };
		$bibinfo_href->{isVisible_ISBN}     = $DisplayableFields_href->{ 'ISBN'     };
		$bibinfo_href->{isVisible_Abstract} = $DisplayableFields_href->{ 'Abstract' };
		$bibinfo_href->{isVisible_Subjects} = $DisplayableFields_href->{ 'Subjects' };
		$bibinfo_href->{isVisible_Info}     = $DisplayableFields_href->{ 'Info'     };
		$bibinfo_href->{isVisible_Link}     = $DisplayableFields_href->{ 'Link'     };
		$bibinfo_href->{isVisible_Holdings} = $DisplayableFields_href->{ 'Holdings' };
		
		push @bibs, $bibinfo_href;

	    }


	    $self->_add_to_limit_lists( $marcrec, \%limits_authors, \%limits_pubdate, \%limits_subjects );

	    $i++;
	}
    }


    my @undo_limits = ();
    my $cl = $currentLimits;
    if ($cl) {
	$cl =~ s/^\/(.*)/$1/;
	my @undo = split /\//,$cl;
	foreach my $undo_limit (@undo) {
	    push @undo_limits, { undo_limit => $undo_limit,
				 unlimit => $undo_limit,
	    };
	}
    }
    
    my @authors;
    foreach my $key (sort keys %limits_authors) {
	push @authors, { author => $key,
			 a_limit => "a:$key",
	};
    }
    
    my @pubdate;
    foreach my $key (reverse sort keys %limits_pubdate) {
	push @pubdate, { pubdate => $key,
			 pd_limit => "pd:$key",
	};
    }
    
    my @subjects;
    foreach my $key (sort keys %limits_subjects) {
	push @subjects, { subject => $key,
			  s_limit => "s:$key",
	};
    }

    # cache control - some systems (UofW) seem to have a web cache system in place
    # which ends up showing old search results after new searches...
    use POSIX qw( strftime );

    $self->header_add(
	# date in the past
	-expires       => 'Sat, 26 Jul 1997 05:00:00 GMT',
	# always modified
	-Last_Modified => strftime('%a, %d %b %Y %H:%M:%S GMT', gmtime),
	# HTTP/1.0
	-Pragma        => 'no-cache',
	# HTTP/1.1
	-Cache_Control => join(', ', qw(
                        no-store
                        no-cache
                        must-revalidate
                        post-check=0
                        pre-check=0
                        )),
	);

    # Parse the template
    my $template = $self->load_tmpl('search/results.tmpl');
    $template->param( USERNAME => $self->authen->username,
#		      PQFSTRING => $pqf,
		      COUNT  => $countRecords,
		      UNDO_LIMITS => \@undo_limits,
		      SUBJECTS => \@subjects,
		      AUTHORS => \@authors,
		      PUBDATES => \@pubdate,
		      BIBS => \@bibs,
		      SORTED_BY_TITLE => $sort_by eq "title" ? 1 : 0,
		      HIDDEN_FIELDS => \@hidden_fields,
		      SHOWN_FIELDS => \@shown_fields,
	);

    my $html_output = $template->output;
    return $html_output;

}


#--------------------------------------------------------------------------------
#
#
sub search_simple_process {
    my $self = shift;

    # Clear any old search results
    my $sql = "DELETE FROM marc WHERE sessionid=" .
	$self->dbh->quote($self->session->id());

    $self->dbh->do( $sql );

    my $template = $self->load_tmpl(	    
	                      'search/simple.tmpl',
			      cache => 1,
			     );	
    $template->param( username => $self->authen->username,
		      sessionid => $self->session->id(),
		      sql => $sql,
	);
    # Parse the template
    my $html_output = $template->output;
    return $html_output;
}


#--------------------------------------------------------------------------------
#
#
sub show_marc_process {
    my $self = shift;
    my $q = $self->query;

    my $id = $q->param("id");

    my $sql = "SELECT marc FROM marc WHERE sessionid=";
    $sql .= $self->dbh->quote($self->session->id());
    $sql .= " AND id=$id";

    $self->log->debug($sql);

    # returns an array of arrays?  Ah.  1 array per row.
    my $marc_aref = $self->dbh->selectrow_arrayref($sql);
    my $marc_string = $marc_aref->[0];
    my $marc = new_from_usmarc MARC::Record($marc_string);

    my $template = $self->load_tmpl(	    
	                      'search/marc.tmpl'
			     );	
    $template->param( username => $self->authen->username,
		      marc => $marc->as_formatted() );

    # Parse the template
    my $html_output = $template->output;
    return $html_output;
}

#--------------------------------------------------------------------------------
#
#
sub request_process {
    my $self = shift;
    my $q          = $self->query;
    my $zid        = $q->param("zid");
    my $record_id  = $q->param("id");
    my $loc        = $q->param("loc");
    my $callno     = $q->param("callno");
    my $collection = $q->param("collection");

    my $from = "From: plslib1\@mts.net\n";

    my $sql = "SELECT email_address, library, mailing_address_line1, mailing_address_line2, mailing_address_line3 from libraries WHERE name=";
    $sql .= $self->dbh->quote($self->authen->username);
    $self->log->debug($sql);
    my $aref = $self->dbh->selectrow_arrayref($sql);
    $self->log->debug( $aref->[0] );
    my $reply_to = "Reply-to: " . $aref->[0];
    my $cc = "Cc: " . $aref->[0];
    my $library = $aref->[1];
    my $mail1 = $aref->[2];
    my $mail2 = $aref->[3];
    my $mail3 = $aref->[4];

    my $to;
    my $holding_library_name;

    $aref = undef;
    if ($loc) {
	$sql = "SELECT email_address, name FROM locations WHERE zid=";
	$sql .= $zid . " AND location=";
	$sql .= $self->dbh->quote($loc);
	$self->log->debug($sql);
	$aref = $self->dbh->selectrow_arrayref($sql);
	$to = "To: " . $aref->[0] if ($aref);
	$holding_library_name = $aref->[1] if ($aref);
    }
    if (not defined($aref)) {
	# if there is no matching location, use the zserver's (generic) email address
	$sql = "SELECT email_address, name FROM zservers WHERE id=";
	$sql .= $zid;
	$aref = $self->dbh->selectrow_arrayref($sql);
	$to = "To: " . $aref->[0];
	$holding_library_name = $aref->[1];
    }

    $sql = "SELECT marc, found_at_server FROM marc WHERE sessionid=? AND id=?";
#    $sql .= $self->dbh->quote($self->session->id());
#    $sql .= " AND id=$record_id";
    my $marc_aref = $self->dbh->selectrow_arrayref($sql,
						   undef,
						   $self->session->id(),
						   $record_id,
	);
    my $marc_string = $marc_aref->[0];
    my $fas = $marc_aref->[1];
    my $marc = new_from_usmarc MARC::Record($marc_string);
    my $subject = "Subject: ILL Request: " . $marc->title() . "\n";

    my $content = "This is an automatically generated request from MAPLIN-3\n\n";
    $content .= $library . " would like to request the following item\nfrom ";
    $content .= $holding_library_name . ":\n-------------------------------------\n";
    $content .= "Title: " . $marc->title() . "\n";
    $content .= "Author: " . $marc->author() . "\n";
    if ($loc) {
	$content .= "Location: " . $loc . "\n";
	$content .= "Call #: " . $callno . "\n";
	$content .= "Collection: " . $collection . "\n" if ($collection);
    } else {
	$content .= "(Holdings information not available)\n";
    }
    my $pubdate = $marc->subfield('260','c');

    my $template = $self->load_tmpl('search/request.tmpl');

    $template->param(username => $self->authen->username,
		     FROM => $from,
		     TO => $to,
		     CC => $cc,
		     REPLY_TO => $reply_to,
		     SUBJECT => $subject,
		     CONTENT => $content,
		     LIBRARY => $library,
		     MAIL1   => $mail1,
		     MAIL2   => $mail2,
		     MAIL3   => $mail3,
		     ZID     => $zid,
		     RECORD_ID => $record_id,
		     LOC       => $loc,
		     CALLNO    => $callno,
		     COLLECTION => $collection,
		     FAS        => $fas,
		     PUBDATE => $pubdate,
		     SENT    => 0
	);

    return $template->output;
}



#--------------------------------------------------------------------------------
# Almost exactly like request_process....
#
sub send_email_process {
    my $self = shift;
    my $q          = $self->query;
    my $zid        = $q->param("zid");
    my $record_id  = $q->param("id");
    my $loc        = $q->param("loc");
    my $callno     = $q->param("callno");
    my $collection = $q->param("collection");
    my $patron     = $q->param("patron");
    my $notes      = $q->param("notes");
    my $pubdate    = $q->param("pubdate");

    my $from = "From: plslib1\@mts.net\n";

    my $to;
    my $holding_library_name;

    my $sql = "SELECT email_address, library, mailing_address_line1, mailing_address_line2, mailing_address_line3, lid from libraries WHERE name=";
    $sql .= $self->dbh->quote($self->authen->username);
    $self->log->debug($sql);
    my $aref = $self->dbh->selectrow_arrayref($sql);
    $self->log->debug( $aref->[0] );
    my $reply_to = "Reply-to: " . $aref->[0] . "\n";
    my $cc = "Cc: " . $aref->[0] . "\n";
    my $library = $aref->[1];
    my $mail1 = $aref->[2];
    my $mail2 = $aref->[3];
    my $mail3 = $aref->[4];
    my $lid   = $aref->[5]; # used for _update_ILL_stats

    $aref = undef;
    if ($loc) {
	$sql = "SELECT email_address, name FROM locations WHERE zid=";
	$sql .= $zid . " AND location=";
	$sql .= $self->dbh->quote($loc);
	$self->log->debug($sql);
	$aref = $self->dbh->selectrow_arrayref($sql);
	$to = "To: " . $aref->[0] . "\n" if ($aref);
	$holding_library_name = $aref->[1] if ($aref);
    }
    if (not defined($aref)) {
	# if there is no matching location, use the zserver's (generic) email address
	$sql = "SELECT email_address, name FROM zservers WHERE id=";
	$sql .= $zid;
	$aref = $self->dbh->selectrow_arrayref($sql);
	$to = "To: " . $aref->[0] . "\n";
	$holding_library_name = $aref->[1];
    }
    $self->_update_ILL_stats($lid, $zid, $loc, $callno, $pubdate);

    $sql = "SELECT marc, found_at_server FROM marc WHERE sessionid=? AND id=?";
    my $marc_aref = $self->dbh->selectrow_arrayref($sql,
						   undef,
						   $self->session->id(),
						   $record_id,
	);
    my $marc_string = $marc_aref->[0];
    my $fas = $marc_aref->[1];

    my $marc = new_from_usmarc MARC::Record($marc_string);
    my $subject = "Subject: ILL Request: " . $marc->title() . "\n";

    my $content = "This is an automatically generated request from MAPLIN-3\n\n";
    $content .= $library . " would like to request the following item from ";
    $content .= $holding_library_name . ":\n-------------------------------------\n";
    $content .= "Title: " . $marc->title() . "\n";
    $content .= "Author: " . $marc->author() . "\n";
    if ($loc) {
	$content .= "Location: " . $loc . "\n";
	$content .= "Call #: " . $callno . "\n";
	$content .= "Collection: " . $collection . "\n" if ($collection);
    } else {
	$content .= "(Holdings information not available)\n";
    }
    $content .= "\nPatron: " . $patron . "\n";
    $content .= "Notes: " . $notes . "\n";
    $content .= "(Found at zServer: " . $fas . ")\n";
    $content .= "\n-------------------------------------\n";
    $content .= "Requesting library: " . $self->authen->username . "\n";
    $content .= "\n$library\n$mail1\n$mail2\n$mail3\n";

    my $error_sendmail = 0;
    my $sendmail = "/usr/sbin/sendmail -t";

    eval {
	open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
	#    print SENDMAIL $from;
	print SENDMAIL $reply_to;
	print SENDMAIL $to;
	print SENDMAIL $cc;
	print SENDMAIL $subject;
	print SENDMAIL "Content-type: text/plain\n\n";
	print SENDMAIL $content;
	close(SENDMAIL);
    };
    if ($@) {
	# sendmail blew up
	$self->log->debug("sendmail blew up");
	$error_sendmail = 1;
	$content =~ s/This is an automatically generated request from MAPLIN-3/MAPLIN had a problem sending email.\nThis is a MANUAL request./;
	$content = "--- copy from here ---\n" . $content . "\n--- copy to here ---\n";
    } else {
	$self->log->debug("sendmail sent request");
    }
    
    my $template = $self->load_tmpl('search/request.tmpl');

    $template->param(username => $self->authen->username,
		     FROM => $from,
		     TO => $to,
		     CC => $cc,
		     REPLY_TO => $reply_to,
		     SUBJECT => $subject,
		     CONTENT => $content,
		     PATRON => $patron,
		     NOTES => $notes,
		     LIBRARY => $library,
		     MAIL1 => $mail1,
		     MAIL2 => $mail2,
		     MAIL3 => $mail3,
		     ZID => $zid,
		     RECORD_ID => $record_id,
		     LOC => $loc,
		     CALLNO => $callno,
		     COLLECTION => $collection,
		     FAS => $fas,
		     SENT => 1,
		     ERROR_SENDMAIL => $error_sendmail,
	);

    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub _limitCheckOK {
    my $self = shift;
    my ($marc, $sessionLimits) = @_;

    $sessionLimits = "" unless $sessionLimits;
    $sessionLimits =~ s/^\/(.*)/$1/;  # chew off the leading "/"
    my @limits = split /\//,$sessionLimits;
    my $cnt = 0;
    foreach my $limit (@limits) {
	my ($limitType,$limitPhrase) = split(/:/,$limit);
	if ($limitType eq "s") {
	    my @subjlist = $marc->field("6..");
	    SUBJECT: foreach my $subj (@subjlist) {
		if ($subj->subfield('a') eq $limitPhrase) {
		    $cnt++;
		    last SUBJECT;
		}
	    }
	} elsif ($limitType eq "a") {
	    my $author = $marc->author();
	    $author =~ s/[^a-zA-Z ]//g;
	    if ($author eq $limitPhrase) {
		$cnt++;
	    }
	} elsif ($limitType eq "pd") {
	    my $pd = $marc->publication_date();
	    $pd =~ s/\D*(\d\d\d\d).*/$1/;
	    if ($pd eq $limitPhrase) {
		$cnt++;
	    }
	} else {
	    # nothing
	}
    }

    return 1 if ($cnt == @limits);  # if it satisfies all limits

    return 0;
}


#--------------------------------------------------------------------------------
#
#
sub _update_ILL_stats {
    my $self = shift;
    my ($lid,$zid,$loc,$callno,$pubdate) = @_;

    my $ac = $self->dbh->{AutoCommit};
    $self->dbh->{AutoCommit} = 0;  # enable transactions, if possible
    $self->dbh->{RaiseError} = 1;

    eval {

	#
	# Timestamped information
	#
	my $rows_affected = $self->dbh->do("INSERT INTO ill_stats (lid, zid, location, callno, pubdate) VALUES (?,?,?,?,?)",
					   undef,
					   $lid,
					   $zid,
					   $loc,
					   $callno,
					   $pubdate
	    );
	
	#
	# Increment the sender's count
	#
	$rows_affected = $self->dbh->do("UPDATE libraries SET ill_sent=ill_sent+1 WHERE lid=?",
					undef,
					$lid
	    );
	
	if ($rows_affected == "0E0") {
	    
	    $self->log->warning("Unable to update ill_sent for lid [$lid], logged in as user [" . $self->authen->username . "]");
	}
	
	
	#
	# Increment the target's count
	#
	$rows_affected = $self->dbh->do(
	    "UPDATE zservers SET ill_received=ill_received+1 WHERE id=?",
	    {},
	    $zid,
	    );
	if ($rows_affected == "0E0") {
	    $self->log->warning("Unable to update ill_received for zserver [$zid]");
	}
	
	#
	# Increment the target location's count (if it exists)
	#
	$rows_affected = $self->dbh->do(
	    "UPDATE locations SET ill_received=ill_received+1 WHERE zid=? AND location=?",
	    {},
	    $zid,
	    $loc
	    );
	if ($rows_affected == "0E0") {
	    #$self->log->warning("Unable to update location table ill_received for zserver [$zid], location [$loc]");
	}
    };

    if ($@) {
	$self->log->warning("ILL stats transaction aborted because $@");
	# now rollback to undo the incomplete changes
	# but do it in an eval{} as it may also fail
	eval { $self->dbh->rollback };
    }

    $self->dbh->{AutoCommit} = $ac;  # reset to original value
}

#--------------------------------------------------------------------------------
#
#
sub _get_ILL_stats_net_count {
    my $self = shift;
    my ($zid,$loc) = @_;

    if (($zid == 1) && ($loc eq 'PUBLIC LIB. SERVICES pls@gov.mb.ca')) {
	# PLS is special... we want it to always be neutral.
	return 0;
    }

    # Get number of ILL requests received
    my $r_href = $self->dbh->selectrow_hashref(
	"SELECT count(*) as ill_received FROM ill_stats WHERE (ts > (current_date - interval '3 years')) and zid=? AND location=?",
	{},
	$zid,
	$loc
	);
    if ($r_href) {
	# this zserver+location has a count
    } else {
	# no data for this zserver+location, default to zserver's count
	$r_href = $self->dbh->selectrow_hashref(
	    "SELECT count(*) as ill_received FROM ill_stats WHERE (ts > (current_date - interval '3 years')) and zid=?",
	    {},
	    $zid
	    );
	if (defined $r_href) {
	    # r_href from 'zservers' ok
	} else {
	    # r_href from 'zservers' not defined.
	    $r_href->{ill_received} = 0;
	}
    }

    # Find the library id that owns this zserver+location
    my $lid_href = $self->dbh->selectrow_hashref(
	"SELECT lid FROM libraries WHERE home_zserver_id=? AND home_zserver_location=?",
	{},
	$zid,
	$loc
	);
    
    if (defined $lid_href->{lid}) {
	# found the library
    } else {
	# no library for zserver+location... just use zserver
	$lid_href = $self->dbh->selectrow_hashref(
	    "SELECT lid FROM libraries WHERE home_zserver_id=?",
	    {},
	    $zid,
	    );
    }

    my $s_href = $self->dbh->selectrow_hashref(
	"SELECT count(*) as ill_sent FROM ill_stats WHERE (ts > (current_date - interval '3 years')) and lid=?",
	{},
	$lid_href->{lid}
	);
    
#    my $s_debug = "Net: sent (" . $s_href->{ill_sent} . ") - received (" . $r_href->{ill_received} . ") = " . ($s_href->{ill_sent} - $r_href->{ill_received});
#    $self->log->debug($s_debug);

    if ($r_href && $s_href) {
	$s_href->{ill_sent} = 0 unless defined $s_href->{ill_sent};
	$r_href->{ill_received} = 0 unless defined $r_href->{ill_received};
	return $s_href->{ill_sent} - $r_href->{ill_received};
    } else {
	$self->log->debug("Net: returning 0");
	return 0;
    }
}


#--------------------------------------------------------------------------------
#
#
sub _build_bibinfo {
    my $self = shift;
    my $rec_id = shift;
    my $zid = shift;
    my $marcrec = shift;
    my $isbn = shift;

    my %bibinfo;
    $bibinfo{id} = $rec_id;
    $bibinfo{title} = $marcrec->title();
    $bibinfo{author} = $marcrec->author();
    $bibinfo{pubdate} = $marcrec->publication_date();
    $bibinfo{pubdate} =~ s/\D*(\d\d\d\d).*/$1/;
    $bibinfo{isbn} = $isbn;
    $bibinfo{abstract} = $marcrec->subfield('520',"a");
    ($bibinfo{URLs}, $bibinfo{ebooklinks}) = $self->_build_URLs( $marcrec );
    $bibinfo{is_ebook} = $self->_isEbook( $marcrec );

    # redundant unless target handles holdings improperly:
    $bibinfo{zid} = $zid;
    $bibinfo{record_id} = $rec_id;
    
    return \%bibinfo;
}

#--------------------------------------------------------------------------------
#
#
sub _build_holdings {
    my $self = shift;
    my $rec_id = shift;
    my $zid = shift;
    my $ar_zservers = shift;
    my $marcrec = shift;

    my @bibholdings;
    my $holdings_tag;
    my $holdings_location;
    my $holdings_callno;
    my $holdings_collection;
    my $holdings_avail;
    my $holdings_due;
    my $handles_holdings_improperly;

    my @target_ary = $self->dbh->selectrow_array(
	"SELECT name FROM zservers WHERE id=?",
	undef,
	$zid
	);
    my $default_location = '???';
    if (@target_ary) {
	$default_location = $target_ary[0];
    }

    # Find the array element (hash) where zid matches {id}
    foreach my $href (@$ar_zservers) {
	if ($href->{id} == $zid) {
	    $holdings_tag        = $href->{holdings_tag};
	    $holdings_location   = $href->{holdings_location};
	    $holdings_callno     = $href->{holdings_callno};
	    $holdings_collection = $href->{holdings_collection};
	    $holdings_avail      = $href->{holdings_avail};
	    $holdings_due        = $href->{holdings_due};
	    $handles_holdings_improperly = $href->{handles_holdings_improperly};
	    last;
	}
    }
    if (defined($holdings_tag)) {
	my @holdings = $marcrec->field($holdings_tag);

	if (@holdings) {
	    foreach my $holding (@holdings) {
		my %item_record;
		my $item_record_href = \%item_record;

		$item_record_href->{ zid } = $zid;
		$item_record_href->{ record_id } = $rec_id;

		if ($holdings_location) {
		    $item_record_href->{location} = $holding->subfield($holdings_location);
		} 
		$item_record_href->{location} = $default_location unless $item_record_href->{location};
		
		if ($holdings_callno) {
		    $item_record_href->{callno} = $holding->subfield($holdings_callno);
		}
		$item_record_href->{callno} = "???" unless $item_record_href->{callno};
		
		if ($holdings_collection) {
		    $item_record_href->{collection} = $holding->subfield($holdings_collection);
		}
		$item_record_href->{collection} = "???" unless $item_record_href->{collection};
		
		if ($holdings_avail) {
		    $item_record_href->{available} = $holding->subfield($holdings_avail);
		    if ($holdings_due) {
			my $due_date = $holding->subfield($holdings_due);
			$item_record_href->{available} .= " (Due $due_date)" if ($due_date);
		    }
		}
		$item_record_href->{available} = "No information" unless $item_record_href->{available};
		
		my $net_borrower_or_lender = $self->_get_ILL_stats_net_count($zid, $item_record_href->{location} );
		$item_record_href->{ is_net_borrower } = $net_borrower_or_lender >= 0 ? 1 : 0,
		$item_record_href->{ net_borrower_or_lender } = abs($net_borrower_or_lender);

		push @bibholdings, $item_record_href;
	    }
	    
	} else {
	    # no holdings information in record
	    my %item_record;
	    my $item_record_href = \%item_record;

	    $item_record_href->{ zid } = $zid;
	    $item_record_href->{ record_id } = $rec_id;
	    $item_record_href->{ location } = $default_location;
	    $item_record_href->{ callno } = '???';
	    $item_record_href->{ collection } = '???';
	    $item_record_href->{ available } = '???';
	    my $net_borrower_or_lender = $self->_get_ILL_stats_net_count($zid, $item_record_href->{location} );
	    $item_record_href->{ is_net_borrower } = $net_borrower_or_lender >= 0 ? 1 : 0,
	    $item_record_href->{ net_borrower_or_lender } = abs($net_borrower_or_lender);

	    push @bibholdings, $item_record_href;
	}

    }
    return \@bibholdings;
}

#--------------------------------------------------------------------------------
#
#
sub _adjust_current_limits {
    my $self = shift;

    my $q = $self->query;
    my $currentLimits = $self->session->param('limits');

    # limits are of the form "s:subject phrase" or "a:author name"
    my $limit = $q->param("limit");
    if (defined $limit) {
	$currentLimits .= "/$limit";
    }
    my $unlimit = $q->param("unlimit");
    if (defined $unlimit) {
	if (defined $currentLimits) {
	    $currentLimits =~ s/\/$unlimit//;
	}
    }
    
    $self->session->param('limits',$currentLimits);
    
    $self->log->debug("Limits : [$currentLimits]") if $currentLimits;
    $self->log->debug("Unlimit: [$unlimit]") if $unlimit;

    return $currentLimits;
}


#--------------------------------------------------------------------------------
#
#
sub _add_to_limit_lists {
    my $self = shift;
    my ( $marcrec, $authors_href, $pubdate_href, $subjects_href ) = @_;

    my $author = $marcrec->author();
    $author =~ s/[^a-zA-Z ]//g;
    $authors_href->{ $author } = 1;

    my $pd = $marcrec->publication_date();
    $pd =~ s/\D*(\d\d\d\d).*/$1/;
    $pubdate_href->{ $pd } = 1;

    my @subjlist = $marcrec->field("6..");
    foreach my $subj (@subjlist) {
	# force scalar context, so we only get the first $a in the field
	my $s = $subj->subfield('a');
	if ($s) {
	    $subjects_href->{ $s } = 1;  # for limits
	}
    }
}


#--------------------------------------------------------------------------------
#
#
sub _adjust_displayed_fields {
    my $self = shift;
    my ($dispFieldList, $hidden_fields, $shown_fields) = @_;

    my $q = $self->query;
    my %DisplayableFields;

    foreach my $fieldname (@$dispFieldList) {
	$DisplayableFields{ $fieldname } = 1;

	if ($q->param("isVisible_$fieldname")) {
	    if ($q->param("isVisible_$fieldname") eq "off") {
		$DisplayableFields{ $fieldname } = 0;
	    }
	    $self->session->param(-name => "isVisible_$fieldname", -value => $q->param("isVisible_$fieldname"));
	    $self->log->debug("Display field: isVisible_$fieldname [" . $q->param("isVisible_$fieldname") . "] found in query, value set to $DisplayableFields{$fieldname}");

	} elsif ($self->session->param("isVisible_$fieldname")) {
	    if ($self->session->param("isVisible_$fieldname") eq "off") {
		$DisplayableFields{ $fieldname } = 0;
	    }
	    $self->log->debug("Display field: isVisible_$fieldname [" . $self->session->param("isVisible_$fieldname") . "] found in session, value set to $DisplayableFields{$fieldname}");

	#} else {
	#    $self->log->debug("Display field: isVisible_$fieldname [1] using default");
	#    $DisplayableFields{ $fieldname } = 1; # default
	}

	if ($DisplayableFields{ $fieldname }) {
	    push @$shown_fields, { name => $fieldname };
	} else {
	    push @$hidden_fields, { name => $fieldname };
	}
    }
    return \%DisplayableFields;
}

sub _isEbook {
    my $self = shift;
    my $marcrec = shift;

    my $isEbook = 0;
    my @fld856s = $marcrec->field('856');
    foreach my $fld856 (@fld856s) {
	# aha!  we have a URL
	# ...but not all URLs are e-books (indicator 2 will tell us)
	# (if ind#2 is '2', it's a "related electronic resource", like
	# an online table of contents.
#	my $URL_relationship = $fld856->indicator('2');
#	if ($URL_relationship != 2) {
#	    $isEbook = 1;
#	}
	
	# UPDATE:  that may not be correct.  Looking at records, it
	# appears that if an 856 *does not have* a subfield 3, then
	# it is an ebook.  Otherwise, subfield 3 tells us what the link
	# is to.
	my $sfld3 = $fld856->subfield( '3' );
	$isEbook = 1 unless $sfld3;
    }
    return $isEbook;
}


sub _build_URLs {
    my $self = shift;
    my $marcrec = shift;

    my @urls;
    my @ebooklinks;

    my @fld856s = $marcrec->field('856');
    foreach my $fld856 (@fld856s) {
	my $sfld3 = $fld856->subfield( '3' );
	if ($fld856->subfield( 'u' )) {
	    if ($sfld3) {
		push @urls, { text => $sfld3, url => $fld856->subfield( 'u' ) };
	    } else {
		push @ebooklinks, { ebooklink => $fld856->subfield( 'u' ) };
	    }
	}
    }
    return (\@urls, \@ebooklinks);
}


1; # so the 'require' or 'use' succeeds
