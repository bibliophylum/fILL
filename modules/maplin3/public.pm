package maplin3::public;
use warnings;
use strict;
use base 'publicbase';
use ZOOM;
use MARC::Record;
use Data::Dumper;


#--------------------------------------------------------------------------------
# Define our runmodes
#
sub setup {
    my $self = shift;
    $self->start_mode('search_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'search_form'           => 'search_process',
	'results_form'          => 'results_process',
	'request_form'          => 'request_process',
	'send_email_form'       => 'send_email_process',
	'registration_form'     => 'registration_process',
	'welcome_form'          => 'public_welcome_process',
	'myaccount_form'        => 'myaccount_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub search_process {
    my $self = shift;
    my $q = $self->query;

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
	    my $includeDatabaseResources = 0;
	    my $includeElectronicResources = 0;
	    my $includeWebResources = 0;
	    $includeStandardResources = 1 if ($q->param('inclSR'));
	    $includeDatabaseResources = 1 if ($q->param('inclDB'));
	    $includeElectronicResources = 1 if ($q->param('inclER'));
	    $includeWebResources = 1 if ($q->param('inclWR'));
	    my $cntIncludeCategories = $includeStandardResources + $includeElectronicResources + $includeWebResources;

#	    my $includeStandardResources = 1;
#	    my $includeElectronicResources = 1;
#	    my $includeDatabaseResources = 1;
#	    my $includeWebResources = 0;
#	    my $cntIncludeCategories = $includeStandardResources + $includeElectronicResources + $includeDatabaseResources + $includeWebResources;
	    
	    # Who are we?
	    my $session = $self->session->id();
	    $self->log->debug("starting search process, sessionid: $session");
	    
	    # Clear any old search results
	    $self->dbh->do("DELETE FROM marc WHERE sessionid=?",undef,$session);
	    
	    # Clear the status_check table
	    $self->dbh->do("DELETE FROM status_check WHERE sessionid=?",undef,$session);
	    
	    # simple, but may allow multiple instances to run (which is ok, if there are not too many....
	    my $system_busy = 0;
	    for (my $i=1; $i<10; $i++) {
		if (-e '/tmp/maplin.zsearch') {
		    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat('/tmp/maplin.zsearch');
		    if (time() - $mtime > 180) {
			# delete the fakelock if it's more than 3 minutes old
			# (it didn't get cleaned up... don't know why yet)
			unlink '/tmp/maplin.zsearch';
		    }
		    $system_busy = 1;
		    sleep 3;
		} else {
		    open FAKELOCK, ">>", '/tmp/maplin.zsearch' or die "Cannot open lock file: $!";
		    print FAKELOCK "$$\n";
		    close FAKELOCK;
		    chmod 0666, "/tmp/maplin.zsearch"; # world-readable, world-writable, so cron can clean up
		    $system_busy = 0;
		    last;
		}
		
	    }
	
	    if ($system_busy) {
		my $template = $self->load_tmpl('search/busy.tmpl');	
		$template->param( username => $self->authen->username,
#				  sessionid => $session,
		    );
		return $template->output;

	    } else {
		# system is not (very) busy

		if (my $pid = fork) {            # parent does
		    use POSIX qw( strftime );
		    
		    $self->header_add(
			# date in the past
			#-expires       => 'Sat, 26 Jul 1997 05:00:00 GMT',
			#-expires       => strftime('%a, %d %b %Y %H:%M:%S GMT', gmtime),
			-expires => 0,
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
                        max-age=0
                        )),
			);
		    
		    $SIG{CHLD} = 'IGNORE';
		    
		    my $template = $self->load_tmpl('public/searching.tmpl');
		    $template->param( USERNAME => $self->authen->username,
				      sessionid => $session );
		    return $template->output;
		    
		} elsif (defined $pid) {         # child does
		    close STDOUT;  # so parent can go on
		    
		    {
			#Stop the annoying (and log-filling)
			#"Name "maplin3::zsearch::F" used only once: possible typo"
			no warnings;
			#local $^W = 0;
			
			# Need the patron's home-library id in order to look up zserver credentials....
			my $patronhref = $self->dbh->selectrow_hashref("SELECT home_library_id FROM patrons WHERE username=?", {}, $self->authen->username);
			
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
			foreach my $ar_id (@$ar_ids) {
			    push @selectedZservers, $ar_id->[0];
			}
#sleep(10);
			unless (open F, "-|") {
			    open STDERR, ">&=1";
			    exec "/opt/maplin3/externals/maplin3-zsearch-pqf.pl", $patronhref->{home_library_id}, $session, $pqf, @selectedZservers;
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
	    }
	}

    } else {
	if ($q->param('cancel')) {
	    # cancel an existing search
	    $self->_cancel_search();
	}

	my $template = $self->load_tmpl('public/search.tmpl');	
	$template->param( USERNAME => $self->authen->username);
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
#    my @dispFieldList = qw/Author PubDate ISBN Subjects Link Holdings/;
    my @dispFieldList = qw/Author PubDate ISBN Abstract Subjects Info Link/;
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
    $self->log->debug("Search results: sorting by $sort_by");

    # Get the array of MARC records that were found
    my $sql = "SELECT id, marc, zid, found_at_server, isbn FROM marc WHERE sessionid=?";
    if ($sort_by eq 'author') {              # --Hmm.  Can't use a placeholder for ORDER BY....
	$sql .=  " ORDER BY author";
    } else {
	$sql .=  " ORDER BY title";
    }
    $self->log->debug("Search results: " . $sql . ", sessionid [" . $self->session->id() . "], sort by $sort_by");
    $marc_aref = $self->dbh->selectall_arrayref($sql,
						undef,
						$self->session->id(),
	);
    $self->log->debug("Total of " . @$marc_aref . " rows from db");
    
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

# DEBUG:
#		if ('0471625809' eq $isbn) {
#		    $self->log->debug( "First record, array index [" . $usedISBNs{ $isbn } . "]" );
#		    $self->log->debug( "Holdings count: " . $bibinfo_href->{holdings_count} );
#		    $self->log->debug( Dumper( $bibinfo_href ) );
#		}

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
    my $template = $self->load_tmpl('public/results.tmpl');
    $template->param( USERNAME => $self->authen->username,
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
sub request_process {
    my $self = shift;
    my $q = $self->query;
    my $bkid  = $q->param("bkid");

    if (defined $bkid) {
	$self->session->param('bkid', $bkid);
    } else {
	$bkid = $self->session->param('bkid');
    }

    # Get all the info we need to build the request
    my $SQL_getPatron = "SELECT pid,name,card,is_enabled,verified,email_address,home_library_id,ill_requests FROM patrons WHERE username=?";
    my $patron_href = $self->dbh->selectrow_hashref( $SQL_getPatron,
						     undef,
						     $self->authen->username
	);
    my $SQL_getLibrary = "SELECT library, email_address, unverified_patron_request_limit, home_zserver_id, home_zserver_location FROM libraries WHERE lid=?";
    my $library_href = $self->dbh->selectrow_hashref( $SQL_getLibrary,
						      undef,
						      $patron_href->{home_library_id}
	);

    # What do we do with disabled patron accounts?
    unless ($patron_href->{is_enabled}) {
	# Currently, we'll never get here because the patron account must be enabled
	# in order for the patron to log in. (hmm - it *could* happen if the librarian
	# disabled the patron account after the patron was logged in....)
	my $template = $self->load_tmpl('public/request_patron_account_disabled.tmpl');
	return $template->output;
    }
    
    # How about unverified patrons?
    if (($patron_href->{verified} == 0)
	&& ($patron_href->{ill_requests} >= $library_href->{unverified_patron_request_limit}) ) {

	$self->log->debug("public: unverified patron attempting limit-exceeding request");
	my $template = $self->load_tmpl('public/request_unverified_limit_exceeded.tmpl');
	return $template->output;
    }

    my $email_href = $self->_build_request($bkid, $patron_href, $library_href);
    
    my $template = $self->load_tmpl('public/request.tmpl');

    $template->param( USERNAME => $self->authen->username,
		      #FROM => $email_href->{from},
		      TO => $email_href->{to},
		      CC => $email_href->{cc},
		      REPLY_TO => $email_href->{reply_to},
		      SUBJECT => $email_href->{subject},
		      CONTENT => $email_href->{content},
		      SENT => 0,
	);

    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub send_email_process {
    my $self = shift;
    my $q = $self->query;
    my $bkid  = $q->param("bkid");

    if (defined $bkid) {
	$self->session->param('bkid', $bkid);
    } else {
	$bkid = $self->session->param('bkid');
    }

    # Get all the info we need to build the request
    my $SQL_getPatron = "SELECT pid,name,card,is_enabled,verified,email_address,home_library_id,ill_requests FROM patrons WHERE username=?";
    my $patron_href = $self->dbh->selectrow_hashref( $SQL_getPatron,
						     undef,
						     $self->authen->username
	);
    my $SQL_getLibrary = "SELECT library, email_address, unverified_patron_request_limit, home_zserver_id, home_zserver_location FROM libraries WHERE lid=?";
    my $library_href = $self->dbh->selectrow_hashref( $SQL_getLibrary,
						      undef,
						      $patron_href->{home_library_id}
	);

    # What do we do with disabled patron accounts?
    unless ($patron_href->{is_enabled}) {
	# Currently, we'll never get here because the patron account must be enabled
	# in order for the patron to log in. (hmm - it *could* happen if the librarian
	# disabled the patron account after the patron was logged in....)
	my $template = $self->load_tmpl('public/request_patron_account_disabled.tmpl');
	return $template->output;
    }
    
    # How about unverified patrons?
    if (($patron_href->{verified} == 0)
	&& ($patron_href->{ill_requests} >= $library_href->{unverified_patron_request_limit}) ) {

	$self->log->debug("public: unverified patron attempting limit-exceeding request");
	my $template = $self->load_tmpl('public/request_unverified_limit_exceeded.tmpl');
	return $template->output;
    }

    my $email_href = $self->_build_request($bkid, $patron_href, $library_href);
    
    my $error_sendmail = 0;
    my $sendmail = "/usr/sbin/sendmail -t";
    eval {
	open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
#	print SENDMAIL "from: $email_href->{from}\n";
	print SENDMAIL $email_href->{reply_to};
	print SENDMAIL $email_href->{to};
	print SENDMAIL $email_href->{cc};
	print SENDMAIL $email_href->{subject};
	print SENDMAIL "\n\n";
	print SENDMAIL $email_href->{content};
	print SENDMAIL "\n";
	close(SENDMAIL);

	$self->log->debug($email_href->{reply_to});
	$self->log->debug($email_href->{to});
	$self->log->debug($email_href->{cc});
	$self->log->debug($email_href->{subject});
	$self->log->debug("\n\n");
	$self->log->debug($email_href->{content});
	$self->log->debug("\n");
    };
    if ($@) {
	# sendmail blew up
	$self->log->debug("sendmail blew up");
	$error_sendmail = 1;
	$email_href->{content} =~ s/This is an automatically generated patron request from Maplin/Maplin had a problem sending email.\nThis is a MANUAL request from your patron/;
	$email_href->{content} = "--- copy from here ---\n" . $email_href->{content} . "\n--- copy to here ---\n";
    } else {
	$self->log->debug("sendmail sent request");
    }
    
    $self->_update_patron_request_count($patron_href->{pid});

    my $template = $self->load_tmpl('public/request.tmpl');

    $template->param( USERNAME => $self->authen->username,
		      #FROM => $email_href->{from},
		      TO => $email_href->{to},
		      CC => $email_href->{cc},
		      REPLY_TO => $email_href->{reply_to},
		      SUBJECT => $email_href->{subject},
		      CONTENT => $email_href->{content},
		      SENT => 1,
		      ERROR_SENDMAIL => $error_sendmail,
	);

    return $template->output;
}

#--------------------------------------------------------------------------------
#
# Patron self-registration
#
sub registration_process {
    my $self = shift;
    my $q = $self->query;

    my @towns;
    my $library_href;
    my $patron_href;

    my $region;
    my $lid;
    my $ask_patron_info = 0;
    my $username_exists = 0;
    my $openshelf_inquiry = 0;

    my $now = localtime;
    $self->log->debug( $now );

    if ($q->param('clear')) {
	$self->session->clear('region');
	$self->session->clear('home_library_id');
	$self->session->clear('home_library');
	$self->session->clear('home_town');
	$self->session->clear('home_libtype');
	$self->session->clear('home_email');
	$self->session->clear('patron_name');
	$self->session->clear('patron_card');
	$self->session->clear('patron_email');
	$self->session->clear('patron_username');
	$self->session->clear('patron_password');
    }

    if ($q->param('openshelf')) {
	$openshelf_inquiry = 1;
    }

    # try to get session variable (ie - user has already chosen)
    $self->log->debug("Do we have a region?");
    if ($self->session->param('region')) {
	$region = $self->session->param('region');
	$self->log->debug("\tregion from session data");
    } elsif ($q->param('region')) {
	$region = $q->param('region');
	$self->session->param('region',$region);
	$self->log->debug("\tregion from param data, saved to session");
    }

    # Do we have a region yet?
    if (defined $region) {

	$self->log->debug("Got region.  Do we have a library id?");

	# try to get town/library session variable(s)
	if ($self->session->param('home_library_id')) {

	    # already in a session variable.  load them into the href
	    $lid = $self->session->param('home_library_id');
	    $library_href = { 
		lid     => $self->session->param('home_library_id'),
		library => $self->session->param('home_library'), 
		town    => $self->session->param('home_town'), 
	    };
	    $self->log->debug("\tlid from session data");

	} elsif ($q->param('lid')) {

	    # passed in a library id.  lookup the rest.
	    $lid = $q->param('lid');
	    $self->session->param('home_library_id', $lid);

	    my $sql = "SELECT lid, library, town FROM libraries WHERE lid=?";
	    $library_href = $self->dbh->selectrow_hashref($sql, undef, $lid);

	    $self->session->param('home_library_id',$library_href->{lid});
	    $self->session->param('home_library',$library_href->{library});
	    $self->session->param('home_town',$library_href->{town});
	    $self->log->debug("\tlid from param data, saved to session");

	} elsif ($region =~ /^WINNIPEG$/) {
	    # I hate special cases!
	    my $sql = "SELECT lid, library, town FROM libraries WHERE library like '%Winnipeg Public%'";
	    $library_href = $self->dbh->selectrow_hashref($sql);

	    $self->session->param('home_library_id',$library_href->{lid});
	    $self->session->param('home_library',$library_href->{library});
	    $self->session->param('home_town',$library_href->{town});
	    $lid = $library_href->{lid};
	    $self->log->debug("\tlid from param data, saved to session");
	}

	# Do we have a town/library yet?
	if (defined $lid) {

	    $self->log->debug("Got a lid.  Do we have patron info?");
	    # try to get patron info session variables

	    if ($self->session->param('patron_name')) {
		# already in a session variable.  load them into the href
		$patron_href = { 
		    name     => $self->session->param('patron_name'),
		    card     => $self->session->param('patron_card'),
		    email    => $self->session->param('patron_email'),
		    username => $self->session->param('patron_username'),
		    password => $self->session->param('patron_password')
		};

		$self->log->debug("\tpatron info from session data");

	    } elsif ($q->param('patron_name')) {
		$patron_href = { 
		    name     => $q->param('patron_name'),
		    card     => $q->param('patron_card'),
		    email    => $q->param('patron_email'),
		    username => $q->param('patron_username'),
		    password => $q->param('patron_password')
		};

		eval {
		    my $rows_affected = $self->dbh->do("INSERT INTO patrons (username, password, home_library_id, email_address, name, card) VALUES (?,md5(?),?,?,?,?)",
						       undef,
						       $patron_href->{username},
						       $patron_href->{password},
						       $self->session->param('home_library_id'),
						       $patron_href->{email},
						       $patron_href->{name},
						       $patron_href->{card}
			);
		    $self->session->param('~logged-in', 1);
		    $self->log->debug("\tpatron info from params");
		    $self->log->debug( Dumper($patron_href) );
		    
		    return 1;
		} or do {
		    $self->log->debug("\tpatron username exists... ask for another");
		    $username_exists = 1;
		};

		unless ($username_exists) {
		    $self->session->param('patron_name', $patron_href->{name});
		    $self->session->param('patron_card', $patron_href->{card});
		    $self->session->param('patron_email', $patron_href->{email});
		    $self->session->param('patron_username', $patron_href->{username});
		    $self->session->param('patron_password', $patron_href->{password});
		    $self->log->debug("\tpatron info saved to session");
		}
	    }

	    if ((defined $patron_href) and ($username_exists == 0)) {
		# do nothing
		$self->log->debug("Got everything we need.  Let the user continue.");
	    } else {
		$self->log->debug("\tno patron yet... ask for it");
		$ask_patron_info = 1;
	    }

	} else {
	    # No town yet.  get towns list to display.

	    $self->log->debug("\tno lid yet... ask for it");
	    my $sql = "SELECT lid, town FROM libraries WHERE region=? ORDER BY town";
	    @towns = @{ $self->dbh->selectall_arrayref($sql,
						       { Slice => {} },
						       $q->param('region'),
			    )};
	    #$self->log->debug( Dumper(@towns) );
	}	
	
    } else {
	$self->log->debug("\tno region... ask for it");
    }

    $self->log->debug("Loading template");
    my $template = $self->load_tmpl('public/registration.tmpl');

    $self->log->debug("Filling template parameters");
    $template->param(USERNAME => 'Not yet registered.',
		     ASK_REGION => defined($region) ? 0 : 1,
		     ASK_TOWN   => defined($lid)    ? 0 : 1,
		     ASK_PATRON_INFO => $ask_patron_info,
		     USERNAME_EXISTS => $username_exists,
		     REGION => $region,
		     TOWNS => \@towns,
		     LIBRARY => $library_href->{library},
		     TOWN    => $library_href->{town},
		     PATRON_NAME => $patron_href->{name},
		     PATRON_CARD => $patron_href->{card},
		     PATRON_EMAIL => $patron_href->{email},
		     PATRON_USERNAME => $patron_href->{username},
		     PATRON_PASSWORD => $patron_href->{password},
		     OPENSHELF_INQUIRY => $openshelf_inquiry,
	);

    $self->log->debug("Display page");
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub public_welcome_process {
    # The application object
    my $self = shift;

    my $template = $self->load_tmpl(	    
	                      'public/welcome_public.tmpl',
			      cache => 0,
			     );	

    # Parse the template
    $template->param(USERNAME => $self->authen->username);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub myaccount_process {
    my $self = shift;
    my $q = $self->query;

    my $SQL_getPatron = "SELECT pid, username, patrons.email_address, patrons.last_login, patrons.name, card, ill_requests, library from patrons, libraries WHERE username=? AND libraries.lid=patrons.home_library_id";

    my $status;
    my $new_password = 0;

    # If the user has clicked the 'update' button, $lid will be defined
    # (the user is submitting a change)
    if ($q->param("pid")) {

	if ($q->param("action") =~ /new_password/) {
	    $new_password = 1;
	    $status = "Changing password"
	} elsif ($q->param("passwd")) {
	    if ($q->param("passwd") eq $q->param("passwd2")) {
		$self->dbh->do("UPDATE patrons SET password=md5(?) WHERE pid=?",
			       undef,
			       $q->param("passwd"),
			       $q->param("pid")
		    );
	    } else {
		$status = "Passwords did not match.  Please try again.";
	    }
	} else {

	    $self->log->debug("MyAccount:Settings: Updating pid [" . $q->param("pid") . "]");
	    $self->dbh->do("UPDATE patrons SET name=?, email_address=? WHERE pid=?",
			   undef,
			   $q->param("name"),
			   $q->param("email_address"),
			   $q->param("pid")
		);
	    $status = "Updated.";
	}
    }

    # Get the form data
    my $href = $self->dbh->selectrow_hashref(
	$SQL_getPatron,
	{},
	$self->authen->username,
	);
    $self->log->debug("MyAccount:Settings: Edit patron id [" . $href->{pid} . "]");
    
    $status = "Editing in process." unless $status;

    my $template = $self->load_tmpl('public/myaccount.tmpl');
    $template->param(username      => $self->authen->username,
	             status        => $status,
		     pid           => $href->{pid},
		     username      => $href->{username},
		     email_address => $href->{email_address},
		     library       => $href->{library},
		     last_login    => $href->{last_login},
		     name          => $href->{name},
		     card          => $href->{card},
		     ill_requests  => $href->{ill_requests},
		     new_password  => $new_password
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub _limitCheckOK {
    my $self = shift;
    my ($marc, $currentLimits) = @_;

#    $self->log->debug("_limitCheckOk: currentLimits [$currentLimits]");
#    $self->log->debug("_limitCheckOk: Checking title [" . $marc->title() . "]");

    $currentLimits = "" unless $currentLimits;
    $currentLimits =~ s/^\/(.*)/$1/;  # chew off the leading "/"
    my @limits = split /\//,$currentLimits;
    my $cnt = 0;
    foreach my $limit (@limits) {
	my ($limitType,$limitPhrase) = split(/:/,$limit);
#	$self->log->debug("  ($limitType) ($limitPhrase)");
	if ($limitType eq "s") {
	    my @subjlist = $marc->field("6..");
	    SUBJECT: foreach my $subj (@subjlist) {
#		$self->log->debug("  [" . $subj->subfield('a') . ']');
		if ($subj->subfield('a') eq $limitPhrase) {
		    $cnt++;
#		    $self->log->debug("  Ok!");
		    last SUBJECT;
		}
	    }
	} elsif ($limitType eq "a") {
	    if ($marc->author() eq $limitPhrase) {
		$cnt++;
#		$self->log->debug("  Ok! Author.");
	    }
	} elsif ($limitType eq "pd") {
	    my $pd = $marc->publication_date();
	    $pd =~ s/\D*(\d\d\d\d).*/$1/;
	    if ($pd eq $limitPhrase) {
		$cnt++;
#		$self->log->debug("  Ok! Publication date.");
	    }
	} else {
	    # nothing
	}
    }

#    $self->log->debug("  ...we're keeping it.") if ($cnt == @limits);
    return 1 if ($cnt == @limits);  # if it satisfies all limits

#    $self->log->debug("  ...we're not keeping it.");
    return 0;
}


#--------------------------------------------------------------------------------
#
#
sub _update_patron_request_count {
    my $self = shift;
    my $pid = shift;

    my $ac = $self->dbh->{AutoCommit};
    $self->dbh->{AutoCommit} = 0;  # enable transactions, if possible
    $self->dbh->{RaiseError} = 1;

    eval {

	my $rows_affected = $self->dbh->do("UPDATE patrons SET ill_requests=ill_requests+1 WHERE pid=?",
					   undef,
					   $pid
	    );
	
	if ($rows_affected == "0E0") {
	    
	    $self->log->warning("Unable to update ill_requests count for patron [$pid], logged in as user [" . $self->authen->username . "]");
	}	
	
    };

    if ($@) {
	$self->log->warning("patron request count transaction aborted because $@");
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

    # Get number of ILL requests received
    my $r_href = $self->dbh->selectrow_hashref(
	"SELECT ILL_received FROM locations WHERE zid=? AND location=?",
	{},
	$zid,
	$loc
	);
    if ($r_href) {
	# this zserver+location has a count
    } else {
	# no data for this zserver+location, default to zserver's count
	$r_href = $self->dbh->selectrow_hashref(
	    "SELECT ILL_received FROM zservers WHERE id=?",
	    {},
	    $zid
	    );
	if (defined $r_href) {
	    # r_href from 'zservers' ok
	} else {
	    # r_href from 'zservers' not defined.
	    $r_href->{ILL_received} = 0;
	}
    }
    
    # Get number of ILL requests sent by all users who call this their
    # home zserver / home zserver location
    my $s_href = $self->dbh->selectrow_hashref(
	"SELECT sum(ILL_sent) as ILL_sent from libraries WHERE home_zserver_id=? AND home_zserver_location=?",
	{},
	$zid,
	$loc
	);
    if (defined $s_href->{ILL_sent}) {
	# this home_zserver + home_zserver_location has a count
    } else {
	if ($zid == 1) {
	    # PLS is special... union catalogue.
	    $s_href->{ILL_sent} = 0;
	} else {
	    
	    $s_href = $self->dbh->selectrow_hashref(
		"SELECT sum(ILL_sent) as ILL_sent from libraries WHERE home_zserver_id=?",
		{},
		$zid,
		);
	    if ($s_href) {
		if (defined $s_href->{ILL_sent}) {
		    # ok
		} else {
		    # s_href->{ILL_sent} is still not defined.
		    # defaulting it to 0
		    $s_href->{ILL_sent} = 0;
		}
	    } else {
		# s_href still not defined!  creating, and setting s_href->{ILL_sent} = 0
		$s_href->{ILL_sent} = 0;
	    }
	}
    }
    
#    my $s_debug = "Net: sent (" . $s_href->{ILL_sent} . ") - received (" . $r_href->{ILL_received} . ") = " . ($s_href->{ILL_sent} - $r_href->{ILL_received});
#    $self->log->debug($s_debug);

    if ($r_href && $s_href) {
	$s_href->{ILL_sent} = 0 unless defined $s_href->{ILL_sent};
	$r_href->{ILL_received} = 0 unless defined $r_href->{ILL_received};
	return $s_href->{ILL_sent} - $r_href->{ILL_received};
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
    $self->log->debug( Dumper( $bibinfo{URLs} ));
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

		$item_record_href->{ zserver_id } = $zid;
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

	    $item_record_href->{ zserver_id } = $zid;
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

    $authors_href->{ $marcrec->author() } = 1;
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


#--------------------------------------------------------------------------------
#
#
sub _build_request {
    my $self = shift;
    my ($bkid, $patron_href, $library_href) = @_;

    my %email = ();

    # Build the request
#    $email{from}     = "From: plslib1\@mts.net\n";  # don't need this at all.
    $email{to}       = "To: " . $library_href->{email_address} . "\n";
    $email{reply_to} = "Reply-to: " . $patron_href->{email_address} . "\n";
    $email{cc}       = "Cc: " . $patron_href->{email_address} . "\n";

    # Get the MARC record and ISBN matching 'bkid' (and this session_id)
    $self->log->debug("bkid: $bkid, sessionid: " . $self->session->id());
    my $sql = "SELECT marc, isbn FROM marc WHERE id=? AND sessionid=?";
    my @bkid_ary = $self->dbh->selectrow_array( $sql,
						undef,
						$bkid,
						$self->session->id()
	);
    my $primary_marc = new_from_usmarc MARC::Record( $bkid_ary[0] );
    my $isbn = $bkid_ary[1];
    $self->log->debug("ISBN: [$isbn]");

    # Get the list of records matching bkid's ISBN (and this session_id)
    $sql = "SELECT id, found_at_server, zid, marc FROM marc WHERE isbn=? AND sessionid=?";
    my @matching = @{ $self->dbh->selectall_arrayref( $sql,
						      { Slice => {} },
						      $isbn,
						      $self->session->id()
			  ) };
    $self->log->debug( scalar @matching . " records matched");

    # Figure out net lender / net borrower stuff
    my @requestable_items;
    foreach my $href (@matching) {

	# Get holdings tag information (and zserver's name+email, in case there are no holdings info in the MARC)
	$sql = "SELECT holdings_tag, holdings_location, holdings_callno, holdings_collection, holdings_avail, holdings_due, name, email_address FROM zservers WHERE id=?";
	my $zserver_href = $self->dbh->selectrow_hashref( $sql,
							  undef,
							  $href->{zid}
	    );

	# See if there are holdings fields in the MARC record
	my $marc = new_from_usmarc MARC::Record( $href->{marc} );
	my @holdings = $marc->field( $zserver_href->{holdings_tag} );
	if (@holdings) {
	    # got some
	    foreach my $fld (@holdings) {

		my %item_record;
		my $item_record_href = \%item_record;

		$item_record_href->{record_id} = $href->{id};
		$item_record_href->{zserver_id} = $href->{zid};

		# see if there's a matching location in the locations table
		my @loc_ary;
		if ($fld->subfield( $zserver_href->{holdings_location} )) {
		    $sql = "SELECT name, email_address FROM locations WHERE zid=? and location=?";
		    @loc_ary = $self->dbh->selectrow_array( $sql,
							    undef,
							    $href->{zid},
							    $fld->subfield( $zserver_href->{holdings_location} )
			);
		}
		    
		if (@loc_ary) {
		    # there is a matching location
		    $item_record_href->{location} = $loc_ary[0];
		    $item_record_href->{email}    = $loc_ary[1];
		    #$self->log->debug( "matching location, email is: $item_record_href->{email}");
		} else {
		    # there is no matching location, so use zservers's information
		    $item_record_href->{location} = $zserver_href->{name};
		    $item_record_href->{email}    = $zserver_href->{email_address};
		    #$self->log->debug( "no matching location, using: $item_record_href->{email}");
		};
		
		# get the rest of the holdings info
		$item_record_href->{callno}     = $fld->subfield( $zserver_href->{holdings_callno} );
		$item_record_href->{collection} = $fld->subfield( $zserver_href->{holdings_collection} );
		$item_record_href->{avail}      = $fld->subfield( $zserver_href->{holdings_avail} );
		$item_record_href->{due}        = $fld->subfield( $zserver_href->{holdings_due} );
		$item_record_href->{netILL}     = $self->_get_ILL_stats_net_count( $href->{zid},
										   $fld->subfield( $zserver_href->{holdings_location} )
		    );

		push @requestable_items, $item_record_href;
	    }

	} else {
	    # no holdings fields, so use zserver's information
	    my %item_record;
	    my $item_record_href = \%item_record;

	    $item_record_href->{record_id} = $href->{record_id};
	    $item_record_href->{zid}       = $href->{zid};
	    $item_record_href->{location}  = $zserver_href->{name};
	    $item_record_href->{email}     = $zserver_href->{email_address};
	    #...and fake the rest
	    $item_record_href->{callno}     = "not in record";
	    $item_record_href->{collection} = "not in record";
	    $item_record_href->{avail}      = "not in record";
	    $item_record_href->{due}        = "not in record";
	    $item_record_href->{netILL}     = $self->_get_ILL_stats_net_count( $href->{zid},"???");
	    push @requestable_items, $item_record_href;

	}
    }

    # at this point, we should have an array of holdings hashes.
    # sort them by netILL
    @requestable_items = reverse sort { $a->{netILL} <=> $b->{netILL} } @requestable_items;

    $email{subject} = "Subject: Patron Request: " . $primary_marc->title() . "\n";

    my $content = "This is an automatically generated patron request from Maplin\n";
    $content .= "to " . $library_href->{library} . "\n\n";

    $content .= $patron_href->{name} . " (library card #" . $patron_href->{card} . ")";
    $content .= " would like you to request the following item for them:\n\n";
    $content .= "Title: " . $primary_marc->title() . "\n";
    $content .= "Author: " . $primary_marc->author() . "\n";
    $content .= "Published: " . $primary_marc->subfield('260','c') . "\n";
    $content .= "ISBN: " . $isbn . "\n";
    $content .= "\nRecommended source (based on net-borrower/net-lender numbers):\n";
    $content .= sprintf("%-40s %-25s %16s %14s %14s %14s %7s\n",
			"Library","Email address","Call #", "Collection","Availability","Due","NetILL"
	);
    $content .= '-' x 136;
    $content .= "\n";
    
#    # Show ALL requestable locations
#    foreach my $ihref (@requestable_items) {
#	$content .= sprintf("%-40s ", $ihref->{location});
#	$content .= sprintf("%-25s ", $ihref->{email});
#	$content .= sprintf("%16s ", $ihref->{callno});
#	$content .= sprintf("%14s ", $ihref->{collection});
#	$content .= sprintf("%14s ", $ihref->{avail});
#	$content .= sprintf("%14s ", $ihref->{due});
#	$content .= sprintf("%7s", $ihref->{netILL});
#	#$content .= "  " . $ihref->{zid} . "\t";
#	#$content .= $ihref->{record_id} . "\t";
#	#$content .= $self->session->id() . "\n";
#    }

    # is the patron's home library zserver/location in the list?
    

    # Show ONLY TOP requestable locations
    my $ihref = $requestable_items[0];
    $content .= sprintf("%-40s ", $ihref->{location});
    $content .= sprintf("%-25s ", $ihref->{email});
    $content .= sprintf("%16s ", $ihref->{callno});
    $content .= sprintf("%14s ", $ihref->{collection});
    $content .= sprintf("%14s ", $ihref->{avail});
    $content .= sprintf("%14s ", $ihref->{due});
    $content .= sprintf("%7s", $ihref->{netILL});
    #$content .= "  " . $ihref->{zid} . "\t";
    #$content .= $ihref->{record_id} . "\t";
    #$content .= $self->session->id() . "\n";


    $content .= "\n";
#    $content .= '_' x 40;

    $email{content} = $content;

    return \%email;
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
	if ($sfld3) {
	    push @urls, { text => $sfld3, url => $fld856->subfield( 'u' ) };
	} else {
	    push @ebooklinks, { ebooklink => $fld856->subfield( 'u' ) };
	}
    }
    return (\@urls, \@ebooklinks);
}

#---    
1; # so the 'require' or 'use' succeeds


# This might be useful down the road... keep the patron requests in the db, so the libraries can access them there.
#
# Requires a table called 'public_requests', which is exactly the same structure as the 'marc' table
# but with an added 'requestid' field (so we can differentiate between multiple requests made by the same patron
# in the same session.
#
#mysql> describe public_requests;
#+-----------------+--------------+------+-----+-------------------+-------+
#| Field           | Type         | Null | Key | Default           | Extra |
#+-----------------+--------------+------+-----+-------------------+-------+
#| sessionid       | varchar(40)  | YES  |     | NULL              |       |
#| requestid       | int(11)      | YES  |     | NULL              |       |
#| id              | int(11)      | YES  |     | NULL              |       |
#| ts              | timestamp    | NO   |     | CURRENT_TIMESTAMP |       |
#| marc            | blob         | YES  |     | NULL              |       |
#| found_at_server | varchar(200) | YES  |     | NULL              |       |
#| zid             | int(11)      | YES  |     | NULL              |       |
#| title           | varchar(255) | YES  |     | NULL              |       |
#| author          | varchar(255) | YES  |     | NULL              |       |
#| isbn            | varchar(20)  | YES  |     | NULL              |       |
#+-----------------+--------------+------+-----+-------------------+-------+
#
#
#    $content .= "\nFor library use in making this reqest:\n";
#    $content .= "Request number: " . $self->session->param('request_number') . "\n";
#    $content .= "Key:\n" . $self->session->id() . "\n";
#    #...and copy the relevent records to the public_requests table
#    $sql = "INSERT INTO public_requests SELECT sessionid, ? as requestid, id, ts, marc, found_at_server, zid, title, author, isbn FROM marc WHERE sessionid=? AND isbn=?";
#    my $rows = $self->dbh->do( $sql,
#			       undef,
#			       $self->session->param('request_number'),
#			       $self->session->id(),
#			       $isbn
#	);
#    $self->log->debug( "$rows copied to public_requests" );
#
# The Home library would then be able to use the session key and request number to find the request.
#
