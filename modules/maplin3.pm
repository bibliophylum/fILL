# Maplin3.pm
package maplin3;
use strict;
use base 'CGI::Application';
use CGI::Application::Plugin::DBH (qw/dbh_config dbh/);
use CGI::Application::Plugin::Session;
use CGI::Application::Plugin::Authentication;
use CGI::Application::Plugin::Authentication::Driver::DBI;
use CGI::Application::Plugin::Authorization;
use CGI::Application::Plugin::LogDispatch;
use ZOOM;
use MARC::Record;
use Data::Dumper;

#my %config = (
#    DRIVER         => [ 'Generic', { test => '123',
#				     hmm => '456',
#			} 
#    ],
#    STORE          => 'Session',
#    POST_LOGIN_RUNMODE => 'async',
#    LOGOUT_RUNMODE => 'logged_out',
#    );

my %config = (
    DRIVER         => [ 'DBI',
			TABLE => 'libraries',
			CONSTRAINTS => {
			    'libraries.name' => '__CREDENTIAL_1__',
			    'libraries.password' => '__CREDENTIAL_2__',
			    'libraries.active' => 1
			},

    ],
    STORE          => 'Session',
    POST_LOGIN_RUNMODE => 'search_simple_ajax_form',
    LOGOUT_RUNMODE => 'logged_out',
    );

maplin3->authen->config(%config);
maplin3->authen->protected_runmodes(':all');



#--------------------------------------------------------------------------------
#
#
sub cgiapp_init {
    my $self = shift;
    
    # use the same args as DBI->connect();
    #$self->dbh_config($data_source, $username, $auth, \%attr);
    #$self->dbh_config("DBI:mysql:database=maplin;mysql_server_prepare=1",
	#	      "mapapp",
	#	      "maplin3db", 
	#	      {LongReadLen => 65536} 
	#);
    $self->dbh_config("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    );


    # Configure the LogDispatch session
    $self->log_config(
      LOG_DISPATCH_MODULES => [ 
        {    module => 'Log::Dispatch::File',
               name => 'messages',
           filename => '/tmp/messages.log',
          min_level => 'debug'
        },
      ],
      APPEND_NEWLINE => 1,
    );

    # Configure authorization
    $self->authz->config(
    DRIVER => [
	'DBI',
	DBH         => $self->dbh,
	TABLES      => [ 'libraries' ],
#        JOIN_ON     => 'author.authorId = article.authorId',
	CONSTRAINTS => {
	    'libraries.name'    => '__USERNAME__',
	    'libraries.admin'  => '__PARAM_1__',
	},
    ],
    FORBIDDEN_RUNMODE => 'forbidden',
    );

    # protect only runmodes that start with admin_
    $self->authz->authz_runmodes(
	[qr/^admin_/ => 1],
	);

}

#--------------------------------------------------------------------------------
# Define our runmodes
#
sub setup {
    my $self = shift;
#    $self->start_mode('search_simple_ajax_form');
    $self->start_mode('search_simple_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
#	'dbtest'        => 'display_db_entries',
#	'emailtest'     => 'send_test_email',

	'logged_out'                 => 'show_logged_out_process',
	'forbidden'                  => 'forbidden_process',
	'environment_form'           => 'environment_process',

#	'search_simple_ajax_form'    => 'search_simple_ajax_process',
	'search_simple_form'         => 'search_simple_process',
	'search_advanced_form'       => 'search_advanced_process',
	'search_results_form'        => 'search_results_process',
	'show_marc_form'             => 'show_marc_process',
	'request_form'               => 'request_process',
	'send_email_form'            => 'send_email_process',

	'myaccount_settings_form'    => 'myaccount_settings_process',
	'myaccount_status_form'      => 'myaccount_status_process',

	'admin_reports_form'         => 'admin_reports_process',
	'admin_logs_form'            => 'admin_logs_process',
	'admin_config_form'          => 'admin_config_process',
	'admin_config_zServers_form' => 'admin_config_zServers_process',
	'admin_users_form'           => 'admin_users_process',
	'admin_status_form'          => 'admin_status_process',
	);
}

#--------------------------------------------------------------------------------
# Execute the following before we execute the requested run mode
#
sub cgiapp_prerun {
} 

#--------------------------------------------------------------------------------
# Process any fatal errors
#
sub error {
    my $self  = shift;
    my $error = shift;
    return "Hmm... There has been an error: $error";
}

#--------------------------------------------------------------------------------
#
#
sub show_logged_out_process {
    # The application object
    my $self = shift;

    # Open the html template
    # NOTE 1: load_tmpl() is a CGI::Application method, not a HTML::Template method.
    # NOTE 2: Setting the 'cache' flag caches the template if used with mod_perl. 
    my $template = $self->load_tmpl(	    
	                      'logged_out.tmpl',
			      cache => 1,
			     );	
    $template->param( username => $self->authen->username,
		      sessionid => $self->session->id(),
	);

    $self->session->delete();

    # Parse the template
    my $html_output = $template->output;
    return $html_output;
}

#--------------------------------------------------------------------------------
#
#
sub forbidden_process {
    # The application object
    my $self = shift;

    # Open the html template
    my $template = $self->load_tmpl(	    
	                      'forbidden.tmpl',
			      cache => 1,
			     );	
    $template->param( username => $self->authen->username,
		      sessionid => $self->session->id(),
	);

    $self->session->delete();

    # Parse the template
    my $html_output = $template->output;
    return $html_output;
}

#--------------------------------------------------------------------------------
#
#
sub environment_process {
    my $self = shift;

    my $template = $self->load_tmpl('environment/display.tmpl');
    my @loop;
    foreach my $key (keys %ENV) {
	my %row = ( name => $key,
		    value => $ENV{$key},
	    );
	push(@loop, \%row);
    }
    $template->param(env_variable_loop => \@loop);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub myaccount_settings_process {
    my $self = shift;
    my $q = $self->query;

    my $SQL_getUser = "SELECT lid, name, password, email_address, library, mailing_address_line1, mailing_address_line2, mailing_address_line3 FROM libraries WHERE name=?";

    my $status;

    # Get any parameter data (ie - user is submitting a change)
    my $lid = $q->param("lid");
    my $name = $q->param("name");
    my $password = $q->param("password");
    my $email_address = $q->param("email_address");
    my $library = $q->param("library");
    my $mailing_address_line1 = $q->param("mailing_address_line1");
    my $mailing_address_line2 = $q->param("mailing_address_line2");
    my $mailing_address_line3 = $q->param("mailing_address_line3");


    # If the user has clicked the 'update' button, $lid will be defined
    # (the user is submitting a change)
    if (defined $lid) {

	$self->log->debug("MyAccount:Settings: Updating lid [$lid], name [$name]");

	$self->dbh->do("UPDATE libraries SET name=?, password=?, email_address=?, library=?, mailing_address_line1=?, mailing_address_line2=?, mailing_address_line3=? WHERE lid=?",
		       undef,
		       $name,
		       $password,
		       $email_address,
		       $library,
		       $mailing_address_line1,
		       $mailing_address_line2,
		       $mailing_address_line3,
		       $lid
	    );
	$status = "Updated.";
    }

    # Get the form data
    my $href = $self->dbh->selectrow_hashref(
	$SQL_getUser,
	{},
	$self->authen->username,
	);
    $self->log->debug("MyAccount:Settings: Edit user id [" . $href->{lid} . "]");
    
    my %edit;
    $edit{lid}   = $href->{lid};
    $edit{name} = $href->{name};
    $edit{password} = $href->{z3950_connection_string};
    $edit{email_address} = $href->{email_address};
    $edit{library} = $href->{library};
    $edit{mailing_address_line1} = $href->{mailing_address_line1};
    $edit{mailing_address_line2} = $href->{mailing_address_line2};
    $edit{mailing_address_line3} = $href->{mailing_address_line3};
    $self->log->debug("MyAccount:Settings: Edit user lid:$href->{lid}, name:$href->{name}, library:$href->{library}");

    $status = "Editing in process." unless $status;

    my $template = $self->load_tmpl('myaccount/settings.tmpl');
    $template->param(status       => $status,
		     editLID      => $edit{lid},
		     editName     => $edit{name},
		     editPassword => $edit{password},
		     editEmail    => $edit{email_address},
		     editLibrary  => $edit{library},
		     editMailingAddressLine1 => $edit{mailing_address_line1},
		     editMailingAddressLine2 => $edit{mailing_address_line2},
		     editMailingAddressLine3 => $edit{mailing_address_line3}
	);
    return $template->output;
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
sub search_advanced_process {
    my $self = shift;

    # Clear any old search results
    my $sql = "DELETE FROM marc WHERE sessionid=" .
	$self->dbh->quote($self->session->id());

    $self->dbh->do( $sql );

    # Get list of zservers
    my $SQL_getServersList = "SELECT id, name, available FROM zservers";

    my $ar_conn = $self->dbh->selectall_arrayref(
	$SQL_getServersList,
	{ Slice => {} }
	);


    my $template = $self->load_tmpl(	    
	                      'search/advanced.tmpl',
			      cache => 1,
			     );	
    $template->param( username => $self->authen->username,
		      sessionid => $self->session->id(),
		      sql => $sql,
		      zservers => $ar_conn,
	);
    # Parse the template
    my $html_output = $template->output;
    return $html_output;
}


#--------------------------------------------------------------------------------
#
#
sub search_results_process {
    my $self = shift;
    my $q = $self->query;

    my $status = "No status"; # debug

    my $limit;
    my @undo_limits = ();

    my @marc;
    my $marc_aref;
    my %subjects;
    my %titles;
    my %authors;
    my %pubdate;
    my @bibs;

    my $countRecords = 0;
	
    my $connstatus = "";
    my @res = ();

    my $pqf;
    if ($q->param('pqf')) {
	$pqf = $q->param('pqf');
    }
    my $sessionLimits = $self->session->param('limits');

    if ($q->param('newsearch')) {

	$status = "New search";

	if (defined $sessionLimits) {
	    $self->session->clear(["limits"]);
	}

	$self->log->debug($status);

	$pqf = "";
	my @words = split / /, $q->param('title');
	foreach my $word (@words) {
	    my $phrase = "\@attr 1=4 \@attr 2=3 \@attr 4=2 " . $word;
	    if ($pqf) {
		$pqf = "\@and " . $pqf . " " . $phrase;
	    } else {
		$pqf = $phrase;
	    }
	}

	my @z;
	my @r;

	my $SQL = "SELECT id, name, z3950_connection_string, holdings_tag, holdings_location, holdings_callno FROM zservers WHERE available=1";
	if ($q->param('advanced')) {
	    my $ar_ids = $self->dbh->selectall_arrayref(
		"SELECT id FROM zservers WHERE available=1"
		);
	    my $sql_inClause = "";
	    foreach my $ar_id (@$ar_ids) {
		$self->log->debug("id: " . $ar_id->[0]);
		if ($q->param("cb_" . $ar_id->[0])) {
		    $sql_inClause .= $ar_id->[0] . ",";
		}
	    }
	    chop $sql_inClause;
	    $SQL .= " AND id IN ($sql_inClause)";
	}
	$self->log->debug("SQL: $SQL");
	my $ar_conn = $self->dbh->selectall_arrayref(
	    $SQL,
	    { Slice => {} }
	    );


	for (my $i = 0; $i < @$ar_conn; $i++) {
	    $z[$i] = new ZOOM::Connection($ar_conn->[$i]{z3950_connection_string}, 0,
					  async => 1, # asynchronous mode
					  count => 1, # piggyback retrieval count
					  preferredRecordSyntax => "usmarc");
#					  preferredRecordSyntax => "opac");
	    $r[$i] = $z[$i]->search_pqf($pqf);
	}
	
	while ((my $i = ZOOM::event(\@z)) != 0) {
	    my $ev = $z[$i-1]->last_event();
	    if ($ev == ZOOM::Event::ZEND) {
		my $size = $r[$i-1]->size();
	}
	}
	
    
	for (my $i = 0; $i < @$ar_conn; $i++) {
	    push @res, {z3950_connection_string => $ar_conn->[$i]{z3950_connection_string},
			result_count => $r[$i]->size(),
	    };
	}
    
	# do something fun with the records
	my $id = 1;
	for (my $i = 0; $i < @$ar_conn; $i++) {
	    my $size = $r[$i]->size();	
	    
	    for (my $j=1; $j <= $size; $j++) {

		my %bibinfo;


		if ($r[$i]->record($j-1)) {
		    if ($r[$i]->record($j-1)->error()) {
			my($code, $msg, $addinfo, $dset) = $r[$i]->record($j-1)->error();
			# ok, it's a hack so I can see the messages....
			$bibinfo{title} = "[$code] $msg";
			$bibinfo{author} = $addinfo;
			$bibinfo{pubdate} = $dset;
			push @bibs, \%bibinfo;
			
		    } else {

			my $raw = $r[$i]->record($j-1)->raw();

			$self->log->debug("---");
			
			if (defined $raw) {
			    if (length($raw) > 5) {
				if (length($raw) < substr($raw,0,5)) {
				    $self->log->debug("Length of record in leader is a lie: [$raw]");
				} else {

				    $self->log->debug("About to eval the new_from_usmarc conversion....");
				    eval {
					no warnings;
					local $SIG{'__DIE__'};
					my $marc = new_from_usmarc MARC::Record($raw); 
				    };
				    $self->log->debug("...conversion eval'd.");
				    if ($@) {
					# record blew up
					$self->log->debug("Record blew up");
					$bibinfo{title} = "Error in record";
					$bibinfo{author} = $@;
					push @bibs, \%bibinfo;
				    } else {
					# can successfully convert to MARC::Record
					$self->log->debug("Able to convert record.");
					my $marc = new_from_usmarc MARC::Record($raw); 
					$self->log->debug("Title was: " . $marc->title());
					
					$self->dbh->do("INSERT INTO marc (sessionid, id, marc, zid, debug_found_at_server) VALUES (?,?,?,?,?)",
						       undef,
						       $self->session->id(),
						       $id,
						       $marc->as_usmarc(),
						       $ar_conn->[$i]{id},
						       $ar_conn->[$i]{name}
					    );
					
					$countRecords++;

					$self->log->debug("id: $id");
					
					$bibinfo{id} = $id;
					$bibinfo{title} = $marc->title();
					$bibinfo{author} = $marc->author();
					$bibinfo{pubdate} = $marc->publication_date();
					$bibinfo{pubdate} =~ s/\D*(\d\d\d\d).*/$1/;
					$bibinfo{debug_found_at_server} = $ar_conn->[$i]{name};
					
					push @marc, $marc;
					$self->log->debug("array entry: ". $#marc);
					$titles{ $marc->title() } = $#marc;
					$authors{ $marc->author() } = $#marc;
					my $pd = $marc->publication_date();
					$pd =~ s/\D*(\d\d\d\d).*/$1/;
					$pubdate{ $pd } = $#marc;
					
					my @subjlist = $marc->field("6..");
					my @bibsubjects;
					foreach my $subj (@subjlist) {
					    $subjects{ $subj->subfield('a') } = $#marc;
					    push @bibsubjects, { subject => $subj->subfield('a') };
					}
					$bibinfo{search_results_subjects} = \@bibsubjects;
					
					my $holdings_tag      = $ar_conn->[$i]{holdings_tag};
					my $holdings_location = $ar_conn->[$i]{holdings_location};
					my $holdings_callno   = $ar_conn->[$i]{holdings_callno};
					my @holdings = $marc->field($holdings_tag);
					my @bibholdings;
					foreach my $holding (@holdings) {
					    push @bibholdings, { zid       => $ar_conn->[$i]{id},
								 record_id => $id,
								 location  => $holding->subfield($holdings_location),
								 callno    => $holding->subfield($holdings_callno)
					    };
					}
					$bibinfo{holdings} = \@bibholdings;
					
					push @bibs, \%bibinfo;
					$self->log->debug("bib array entry: " . $#bibs);
					
					$id++;
				    }
				}
			    } else {
				$self->log->debug("Not a real record: [$raw]");
			    }
			}
		    }
		}
	    }
	}
	$self->log->debug(Dumper(\@bibs));

    } else {
	#
	# Not a new search, so load previous results from db
	#

	$status = "Existing search";

	# limits are of the form "s:subject phrase" or "a:author name"
	$limit = $q->param("limit");
	if (defined $limit) {
	    $sessionLimits .= "/$limit";
	}
	my $unlimit = $q->param("unlimit");
	if (defined $unlimit) {
	    if (defined $sessionLimits) {
		$sessionLimits =~ s/\/$unlimit//;
	    }
	}

	$self->session->param('limits',$sessionLimits);

	$self->log->debug("Status : $status");
	$self->log->debug("Limits : [$sessionLimits]") if $sessionLimits;
	$self->log->debug("Unlimit: [$unlimit]") if $unlimit;

	my $ar_zservers = $self->dbh->selectall_arrayref(
	    "SELECT id, holdings_tag, holdings_location, holdings_callno FROM zservers",
	    { Slice => {} }
	    );

	my $sql = "SELECT id, marc, zid, debug_found_at_server FROM marc WHERE sessionid=" .
	    $self->dbh->quote($self->session->id());
	$self->log->debug($sql);
	# returns an array of arrays?  Ah.  1 array per row.
	$marc_aref = $self->dbh->selectall_arrayref($sql);

	$self->log->debug("Total of " . @$marc_aref . " rows from db");
	$status .= "  Total of " . @$marc_aref . " rows from db";

	my $i = 0;
	foreach my $row_array (@$marc_aref) {
	    my $rec_id = $row_array->[0];
	    my $marc_string = $row_array->[1];
	    my $marcrec = new_from_usmarc MARC::Record($marc_string);
	    my $zid = $row_array->[2];

#	    $self->log->debug("Checking title [" . $marc->title() . "]");
	    if ($self->_limitCheckOK($marcrec, $sessionLimits)) {
		$countRecords++;

		my %bibinfo;
		$bibinfo{id} = $rec_id;
		$bibinfo{title} = $marcrec->title();
		$bibinfo{author} = $marcrec->author();
		$bibinfo{pubdate} = $marcrec->publication_date();
		$bibinfo{pubdate} =~ s/\D*(\d\d\d\d).*/$1/;
		$bibinfo{debug_found_at_server} = $row_array->[3];

		push @marc, $marcrec;
		$titles{ $marcrec->title() } = $i;		
		$authors{ $marcrec->author() } = $i;
		my $pd = $marcrec->publication_date();
		$pd =~ s/\D*(\d\d\d\d).*/$1/;
		$pubdate{ $pd } = $i;
		my @subjlist = $marcrec->field("6..");
		my @bibsubjects;
		foreach my $subj (@subjlist) {
		    $subjects{ $subj->subfield('a') } = $i;
		    push @bibsubjects, { subject => $subj->subfield('a') };
		}
		$bibinfo{search_results_subjects} = \@bibsubjects;

		my $holdings_tag;
		my $holdings_location;
		my $holdings_callno;
		# Find the array element (hash) where zid matches {id}
		foreach my $href (@$ar_zservers) {
		    if ($href->{id} == $zid) {
			$holdings_tag      = $href->{holdings_tag};
			$holdings_location = $href->{holdings_location};
			$holdings_callno   = $href->{holdings_callno};
			last;
		    }
		}
		if (defined($holdings_tag)) {
		    my @holdings = $marcrec->field($holdings_tag);
		    my @bibholdings;
		    foreach my $holding (@holdings) {
			push @bibholdings, { zid       => $zid,
					     record_id => $rec_id,
					     location  => $holding->subfield($holdings_location),
					     callno    => $holding->subfield($holdings_callno)
			};
		    }
		    $bibinfo{holdings} = \@bibholdings;
		}

		push @bibs, \%bibinfo;
		$i++;
	    }
	}

	my $sl = $sessionLimits;
	$sl =~ s/^\/(.*)/$1/;
	my @undo = split /\//,$sl;
	foreach my $undo_limit (@undo) {
	    push @undo_limits, { undo_limit => $undo_limit,
				 unlimit => $undo_limit,
	    };
	}

    }
	
    my @authors;
    foreach my $key (sort keys %authors) {
	push @authors, { author => $key,
			 a_limit => "a:$key",
	};
    }
    
    my @pubdate;
    foreach my $key (reverse sort keys %pubdate) {
	push @pubdate, { pubdate => $key,
			 pd_limit => "pd:$key",
	};
    }
    
    my @subjects;
    foreach my $key (sort keys %subjects) {
	push @subjects, { subject => $key,
			  s_limit => "s:$key",
	};
    }

    # Parse the template
    my $template = $self->load_tmpl('search/results.tmpl');
    $template->param(PQFSTRING => $pqf,
#		     STATUS => $connstatus,
		     STATUS => $status,
		     COUNT  => $countRecords,
		     LIMITS => $sessionLimits,
		     UNDO_LIMITS => \@undo_limits,
#		     RESLOOP => \@res,
		     SUBJECTS => \@subjects,
		     AUTHORS => \@authors,
		     PUBDATES => \@pubdate,
		     BIBS => \@bibs,
	);
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
    $template->param( marc => $marc->as_formatted() );

    # Parse the template
    my $html_output = $template->output;
    return $html_output;
}

#--------------------------------------------------------------------------------
#
#
sub request_process {
    my $self = shift;
    my $q         = $self->query;
    my $zid       = $q->param("zid");
    my $record_id = $q->param("id");
    my $loc       = $q->param("loc");
    my $callno    = $q->param("callno");

    my $from = "From: plslib1\@mts.net\n";

    my $sql = "SELECT email_address, library, mailing_address_line1, mailing_address_line2, mailing_address_line3 FROM libraries WHERE name=";
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

    $sql = "SELECT email_address FROM locations WHERE zid=";
    $sql .= $zid . " AND location=";
    $sql .= $self->dbh->quote($loc);
    $self->log->debug($sql);
    $aref = $self->dbh->selectrow_arrayref($sql);
    my $to = "To: " . $aref->[0] if ($aref);
    if (not defined($aref)) {
	# if there is no matching location, use the zserver's (generic) email address
	$sql = "SELECT email_address FROM zservers WHERE id=";
	$sql .= $zid;
	$aref = $self->dbh->selectrow_arrayref($sql);
	$to = $aref->[0];
    }

    $sql = "SELECT marc FROM marc WHERE sessionid=";
    $sql .= $self->dbh->quote($self->session->id());
    $sql .= " AND id=$record_id";
    my $marc_aref = $self->dbh->selectrow_arrayref($sql);
    my $marc_string = $marc_aref->[0];
    my $marc = new_from_usmarc MARC::Record($marc_string);
    my $subject = "Subject: ILL Request: " . $marc->title() . "\n";

    my $content = "This is an automatically generated request from MAPLIN-3\n\n";
    $content .= "Title: " . $marc->title() . "\n";
    $content .= "Author: " . $marc->author() . "\n";
    $content .= "Location: " . $loc . "\n";
    $content .= "Call #: " . $callno . "\n";

    my $template = $self->load_tmpl('search/request.tmpl');

    $template->param(FROM => $from,
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
		     SENT    => 0
	);

    return $template->output;
}



#--------------------------------------------------------------------------------
# Almost exactly like request_process....
#
sub send_email_process {
    my $self = shift;
    my $q         = $self->query;
    my $zid       = $q->param("zid");
    my $record_id = $q->param("id");
    my $loc       = $q->param("loc");
    my $callno    = $q->param("callno");
    my $patron    = $q->param("patron");

    my $from = "From: plslib1\@mts.net\n";

    my $sql = "SELECT email_address, library, mailing_address_line1, mailing_address_line2, mailing_address_line3 FROM libraries WHERE name=";
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

    $sql = "SELECT email_address FROM locations WHERE zid=";
    $sql .= $zid . " AND location=";
    $sql .= $self->dbh->quote($loc);
    $self->log->debug($sql);
    $aref = $self->dbh->selectrow_arrayref($sql);
    my $to = "To: " . $aref->[0] . "\n" if ($aref);
    if (not defined($aref)) {
	# if there is no matching location, use the zserver's (generic) email address
	$sql = "SELECT email_address FROM zservers WHERE id=";
	$sql .= $zid;
	$aref = $self->dbh->selectrow_arrayref($sql);
	$to = "To: " . $aref->[0] . "\n";
    }
    $self->log->debug("To address is [" . $to . "]");

    $sql = "SELECT marc FROM marc WHERE sessionid=";
    $sql .= $self->dbh->quote($self->session->id());
    $sql .= " AND id=$record_id";
    my $marc_aref = $self->dbh->selectrow_arrayref($sql);
    my $marc_string = $marc_aref->[0];
    my $marc = new_from_usmarc MARC::Record($marc_string);
    my $subject = "Subject: ILL Request: " . $marc->title() . "\n";

    my $content = "This is an automatically generated request from MAPLIN-3\n\n";
    $content .= "Title: " . $marc->title() . "\n";
    $content .= "Author: " . $marc->author() . "\n";
    $content .= "Location: " . $loc . "\n";
    $content .= "Call #: " . $callno . "\n";
    $content .= "\nPatron: " . $patron . "\n";
    $content .= "\n$library\n$mail1\n$mail2\n$mail3\n";

    my $sendmail = "/usr/sbin/sendmail -t";
    open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
    print SENDMAIL $from;
    print SENDMAIL $reply_to;
    print SENDMAIL $to;
    print SENDMAIL $cc;
    print SENDMAIL $subject;
    print SENDMAIL "Content-type: text/plain\n\n";
    print SENDMAIL $content;
    close(SENDMAIL);
    
    my $template = $self->load_tmpl('search/request.tmpl');

    $template->param(FROM => $from,
		     TO => $to,
		     CC => $cc,
		     REPLY_TO => $reply_to,
		     SUBJECT => $subject,
		     CONTENT => $content,
		     PATRON  => $patron,
		     LIBRARY => $library,
		     MAIL1   => $mail1,
		     MAIL2   => $mail2,
		     MAIL3   => $mail3,
		     ZID     => $zid,
		     RECORD_ID => $record_id,
		     LOC       => $loc,
		     CALLNO    => $callno,
		     SENT    => 1
	);

    return $template->output;
}



#--------------------------------------------------------------------------------
#
#
sub send_test_email {
    my $self = shift;

    my $sql = "SELECT name, active, email_address FROM libraries";
    $sql .= " WHERE name=" . $self->dbh->quote($self->authen->username);

    $self->log->debug($sql);

    my $ar_user = $self->dbh->selectall_arrayref(
	$sql,
	{ Slice => {} }
	);

    my $template = $self->load_tmpl(	    
	                      'test_email.tmpl',
			      cache => 1,
			     );	
    # Fill in some parameters
#    $template->param(ZINFO => [
#			 { name => "hmm", conn => $conn },
#		     ]
#	);

    my $sendmail = "/usr/sbin/sendmail -t";
    my $reply_to = "Reply-to: David.A.Christensen\@gmail.com\n";
    my $subject  = "Subject: Hmm.\n";
#    my $to       = "To: plslib1\@mts.net\n";
    my $to       = "To: " . $ar_user->[0]{email_address} . "\n";
    my $cc       = "Cc: David.A.Christensen\@gmail.com\n";
    my $from     = "From: plslib1\@mts.net\n";
    my $content  = "This is a test.\n";
    $content .= "Name: " . $ar_user->[0]{name} . "\n";
    $content .= "Status: " . $ar_user->[0]{active} . "\n";
    $content .= "[$sql]\n";

    open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
    print SENDMAIL $from;
    print SENDMAIL $reply_to;
    print SENDMAIL $subject;
    print SENDMAIL $to;
    print SENDMAIL $cc;
    print SENDMAIL "Content-type: text/plain\n\n";
    print SENDMAIL $content;
    close(SENDMAIL);
    
    $template->param(FROM => $from,
		     TO => $to,
		     CC => $cc,
		     REPLY_TO => $reply_to,
		     SUBJECT => $subject,
		     CONTENT => $content
	);

    # Parse the template
    my $html_output = $template->output;
    return $html_output;
}


#--------------------------------------------------------------------------------
#
#
sub _limitCheckOK {
    my $self = shift;
    my ($marc, $sessionLimits) = @_;

#    $self->log->debug("_limitCheckOk: sessionLimits [$sessionLimits]");
#    $self->log->debug("_limitCheckOk: Checking title [" . $marc->title() . "]");

    $sessionLimits =~ s/^\/(.*)/$1/;  # chew off the leading "/"
    my @limits = split /\//,$sessionLimits;
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



#================================================================================
# Admin
#================================================================================

#--------------------------------------------------------------------------------
#
#
sub admin_reports_process {
    my $self = shift;

    my $template = $self->load_tmpl('admin/reports.tmpl');
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub admin_logs_process {
    my $self = shift;
    my $q = $self->query;

    my $log = $q->param("log");
    $log = "No log chosen" unless ($log);

    my $tail;

    if ($log eq "access.log") {
	$tail = `tail -n 20 /maplin3/logs/access.log`;
    } elsif ($log eq "error.log") {
	$tail = `tail -n 20 /maplin3/logs/error.log`;
    }

    my $template = $self->load_tmpl('admin/logs.tmpl');

    $template->param(log => $log,
		     tail => $tail
	);

    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub admin_config_process {
    my $self = shift;

    my $template = $self->load_tmpl('admin/config.tmpl');
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub admin_config_zServers_process {
    my $self = shift;
    my $q = $self->query;

    my $SQL_getServersList = "SELECT id, name, z3950_connection_string, email_address, available, holdings_tag, holdings_location, holdings_callno, holdings_avail FROM zservers";

    my $status = "Select a zServer to edit...";

    my $ar_conn = $self->dbh->selectall_arrayref(
	$SQL_getServersList,
	{ Slice => {} }
	);

    my %edit;

    my $zSelected = $q->param("z");
    my $id = $q->param("id");
    my $name = $q->param("name");
    my $z3950_connection_string = $q->param("z3950_connection_string");
    my $new_zServer = $q->param("new_zServer");
    my $delete_id = $q->param("delete_id");

    if (defined $zSelected) {

	# User has chosen a new zServer from the list

	$self->log->debug("Admin:Config:zServers: Edit server id [$zSelected]");

	# Find the array element (hash) where zSelected matches {id}
	foreach my $href (@$ar_conn) {
	    if ($href->{id} == $zSelected) {
		$edit{zid}         = $href->{id};
		$edit{target_name} = $href->{name};
		$edit{target_conn} = $href->{z3950_connection_string};
		$edit{target_email} = $href->{email_address};
		$edit{target_avail} = $href->{available};
		$edit{target_holdings_tag} = $href->{holdings_tag};
		$edit{target_holdings_callno} = $href->{holdings_callno};
		$edit{target_holdings_location} = $href->{holdings_location};
		$edit{target_holdings_avail} = $href->{holdings_avail};
		$self->log->debug("Admin:Config:zServers: Edit server id:$href->{id}, name:$href->{name}, z3950_connection_string:$href->{z3950_connection_string}");
		last;
	    }
	}

	$status = "Editing in process.";

    } elsif (defined $new_zServer) {

	$self->log->debug("Admin:Config:zServers: New server name [$name], conn [$z3950_connection_string]");

	$self->dbh->do("INSERT INTO zservers (name, z3950_connection_string, available) VALUES (?,?,?)",
		       undef,
		       $name,
		       $z3950_connection_string,
		       0
	    );

	$status = "Added.  Select a zServer to edit...";

	# Get the zServers list again.
	$ar_conn = $self->dbh->selectall_arrayref(
	    $SQL_getServersList,
	    { Slice => {} }
	    );

    } elsif (defined $delete_id) {

	$self->log->debug("Admin:Config:zServers: Delete zServer id [$delete_id]");

	$self->dbh->do("DELETE FROM zservers WHERE id=?",
		       undef,
		       $delete_id
	    );

	$status = "Deleted.  Select a zServer to edit...";

	# Get the zServers list again.
	$ar_conn = $self->dbh->selectall_arrayref(
	    $SQL_getServersList,
	    { Slice => {} }
	    );

    } elsif (defined $id) {

	my $email_address = $q->param('email_address');
	my $available = $q->param('available');
	my $holdings_tag = $q->param('holdings_tag');
	my $holdings_location = $q->param('holdings_location');
	my $holdings_callno = $q->param('holdings_callno');
	my $holdings_avail = $q->param('holdings_avail');
	$self->log->debug("Admin:Config:zServers: Updating id [$id], name [$name], conn [$z3950_connection_string]");

	my $SQL = "UPDATE zservers SET name=?, z3950_connection_string=?, email_address=?, available=?, holdings_tag=?, holdings_location=?, holdings_callno=?, holdings_avail=? WHERE id=?";

	$self->dbh->do($SQL,
		       undef,
		       $name,
		       $z3950_connection_string,
		       $email_address,
		       $available,
		       $holdings_tag,
		       $holdings_location,
		       $holdings_callno,
		       $holdings_avail,
		       $id
	    );

	$status = "Updated.  Select a zServer to edit...";

	# Get the zServers list again.
	$ar_conn = $self->dbh->selectall_arrayref(
	    $SQL_getServersList,
	    { Slice => {} }
	    );
    }

    my @sorted_connections = sort { $a->{name} cmp $b->{name} } @$ar_conn;

    my $template = $self->load_tmpl('admin/config/zServers.tmpl');
    $template->param(zServers             => \@sorted_connections,
		     status               => $status,
		     editID               => $edit{zid},
		     editName             => $edit{target_name},
		     editConn             => $edit{target_conn},
		     editEmail            => $edit{target_email},
		     editAvailable        => $edit{target_avail},
		     editHoldingsTag      => $edit{target_holdings_tag},
		     editHoldingsLocation => $edit{target_holdings_location},
		     editHoldingsCallno   => $edit{target_holdings_callno},
		     editHoldingsAvail    => $edit{target_holdings_avail},
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub admin_users_process {
    my $self = shift;
    my $q = $self->query;

    my $SQL_getUsersList = "SELECT lid, name, password, active, email_address, admin, library, mailing_address_line1, mailing_address_line2, mailing_address_line3 FROM libraries";

    my $status = "Select a user to edit...";

    my $ar_conn = $self->dbh->selectall_arrayref(
	$SQL_getUsersList,
	{ Slice => {} }
	);

    my %edit;

    my $userSelected = $q->param("u");
    my $lid = $q->param("lid");
    my $name = $q->param("name");
    my $password = $q->param("password");
    my $active = $q->param("active");
    my $email_address = $q->param("email_address");
    my $admin = $q->param("admin");
    my $library = $q->param("library");
    my $mailing_address_line1 = $q->param("mailing_address_line1");
    my $mailing_address_line2 = $q->param("mailing_address_line2");
    my $mailing_address_line3 = $q->param("mailing_address_line3");
    my $new_user = $q->param("new_user");
    my $delete_id = $q->param("delete_id");

    if (defined $userSelected) {

	# User has chosen a new user to edit from the list

	$self->log->debug("Admin:Users: Edit user id [$userSelected]");

	# Find the array element (hash) where userSelected matches {lid}
	foreach my $href (@$ar_conn) {
	    if ($href->{lid} == $userSelected) {
		$edit{lid}   = $href->{lid};
		$edit{name} = $href->{name};
		$edit{password} = $href->{z3950_connection_string};
		$edit{email_address} = $href->{email_address};
		$edit{active} = $href->{active};
		$edit{admin} = $href->{admin};
		$edit{library} = $href->{library};
		$edit{mailing_address_line1} = $href->{mailing_address_line1};
		$edit{mailing_address_line2} = $href->{mailing_address_line2};
		$edit{mailing_address_line3} = $href->{mailing_address_line3};
		$self->log->debug("Admin:Users: Edit user lid:$href->{lid}, name:$href->{name}, library:$href->{library}");
		last;
	    }
	}

	$status = "Editing in process.";

    } elsif (defined $new_user) {

	$self->log->debug("Admin:Users: New user name [$name]");

	$self->dbh->do("INSERT INTO libraries (name, password, active) VALUES (?,?,?)",
		       undef,
		       $name,
		       $password,
		       0
	    );

	$status = "Added.  Select a user to edit...";

	# Get the users list again.
	$ar_conn = $self->dbh->selectall_arrayref(
	    $SQL_getUsersList,
	    { Slice => {} }
	    );

    } elsif (defined $delete_id) {

	$self->log->debug("Admin:Users: Delete user lid [$delete_id]");

	$self->dbh->do("DELETE FROM libraries WHERE lid=?",
		       undef,
		       $delete_id
	    );

	$status = "Deleted.  Select a user to edit...";

	# Get the users list again.
	$ar_conn = $self->dbh->selectall_arrayref(
	    $SQL_getUsersList,
	    { Slice => {} }
	    );

    } elsif (defined $lid) {

	$self->log->debug("Admin:Users: Updating lid [$lid], name [$name]");

	$self->dbh->do("UPDATE libraries SET name=?, password=?, active=?, email_address=?, admin=?, library=?, mailing_address_line1=?, mailing_address_line2=?, mailing_address_line3=? WHERE lid=?",
		       undef,
		       $name,
		       $password,
		       $active,
		       $email_address,
		       $admin,
		       $library,
		       $mailing_address_line1,
		       $mailing_address_line2,
		       $mailing_address_line3,
		       $lid
	    );

	$status = "Updated.  Select a user to edit...";

	# Get the users list again.
	$ar_conn = $self->dbh->selectall_arrayref(
	    $SQL_getUsersList,
	    { Slice => {} }
	    );
    }

    my @sorted_users = sort { $a->{name} cmp $b->{name} } @$ar_conn;

    my $template = $self->load_tmpl('admin/libraries.tmpl');
    $template->param(users        => \@sorted_users,
		     status       => $status,
		     editLID      => $edit{lid},
		     editName     => $edit{name},
		     editPassword => $edit{password},
		     editEmail    => $edit{email_address},
		     editActive   => $edit{active},
		     editAdmin    => $edit{admin},
		     editLibrary  => $edit{library},
		     editMailingAddressLine1 => $edit{mailing_address_line1},
		     editMailingAddressLine2 => $edit{mailing_address_line2},
		     editMailingAddressLine3 => $edit{mailing_address_line3}
	);
    return $template->output;
}



1; # so the 'require' or 'use' succeeds
