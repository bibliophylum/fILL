package maplin3::info;
use strict;
use base 'maplin3base';
use CGI::Application::Plugin::Stream (qw/stream_file/);
use ZOOM;
use Net::Ping;

#--------------------------------------------------------------------------------
# Define our runmodes
#
sub setup {
    my $self = shift;
    $self->start_mode('info_contacts_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'info_contacts_form'   => 'info_contacts_process',
	'info_documents_form'  => 'info_documents_process',
	'info_feeds_form'      => 'info_feeds_process',
	'send_pdf'             => 'send_pdf',
	'test_my_zserver_form' => 'test_my_zserver_process',
	'info_all_zservers_form'    => 'info_all_zservers_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub info_contacts_process {
    my $self = shift;
    my $q = $self->query;

    my $SQL_getUser = "SELECT name, email_address, library, mailing_address_line1, mailing_address_line2, mailing_address_line3 from libraries WHERE active=1 ORDER BY library";

    # Get any parameter data (ie - user is submitting a change)
    my $sort = $q->param("sort");

    # Get the form data
    my $aref = $self->dbh->selectall_arrayref(
	$SQL_getUser,
	{ Slice => {} }
	);
    
    my $template = $self->load_tmpl('info/contacts.tmpl');
    $template->param(pagetitle => "Maplin-3 Info Contacts",
		     username  => $self->authen->username,
		     libraries => $aref);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub info_documents_process {
    my $self = shift;

    my $template = $self->load_tmpl('info/documents.tmpl');
    $template->param(pagetitle => "Maplin-3 Info Documents",
		     username => $self->authen->username);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub info_feeds_process {
    my $self = shift;

    my $template = $self->load_tmpl('info/feeds.tmpl');
    $template->param(pagetitle => "Maplin-3 Info Feeds",
		     username => $self->authen->username);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub send_pdf {
    my $self = shift;
    my $q = $self->query;

    my $docname = $q->param("doc");
    $self->header_add( -attachment => $docname );    
    $self->stream_file( "/opt/maplin3/restricted_docs/$docname",2048);
    
#    $self->header_type('none'); # let's you set your own headers
#    $self->header_props(
#	-content-type         => 'application/pdf',
#	-content-disposition  => "inline; filename=$docname"
#  );
#
#  return "Download $docname";

    return;
} 


#--------------------------------------------------------------------------------
#
#
sub test_my_zserver_process {
    my $self = shift;
    my $q = $self->query;

    my $zserver_href;
    my %status;
    my $showserver = 0;

    my @zserver_data = ();  # trick HTML:Template into using a hash....
    my @status_data = ();

    $status{show} = 0;
    $status{stage} = "Ready to begin test";
    $status{error} = "Ok.";
    $status{timeout} = "30";
    $status{search_terms} = "";
    $status{search_string} = "";
    $status{result_count} = 0;

    if ($q->param('getStatus')) {
    
	# Need the user's zserver info
	$zserver_href = $self->dbh->selectrow_hashref( "SELECT id, zservers.name as name, z3950_connection_string, zservers.email_address as email_address, available, holdings_tag, holdings_location, holdings_callno, holdings_avail, holdings_collection, holdings_due, iselectronicresource, iswebresource, isstandardresource,isdatabase,preferredrecordsyntax FROM zservers, library_zserver, libraries WHERE (zservers.id = library_zserver.zid) AND (library_zserver.lid = libraries.lid) AND (libraries.name=?)", {}, $self->authen->username);

	if ($zserver_href) {
	    $showserver = 1;

	    $zserver_href->{holdings_tag} =~ s/ //g if ($zserver_href->{holdings_tag});
	    $zserver_href->{holdings_location} =~ s/ //g if ($zserver_href->{holdings_location});
	    $zserver_href->{holdings_callno} =~ s/ //g if ($zserver_href->{holdings_callno});
	    $zserver_href->{holdings_collection} =~ s/ //g if ($zserver_href->{holdings_collection});
	    $zserver_href->{holdings_avail} =~ s/ //g if ($zserver_href->{holdings_avail});
	    $zserver_href->{holdings_due} =~ s/ //g if ($zserver_href->{holdings_due});
	    push( @zserver_data, $zserver_href );
	    
	    $status{stage} = "Attempting to open a connection and search your system";
	    $status{show} = 1;

	    # Check if the z39.50 port is open on the remote machine
	    my $host = $zserver_href->{z3950_connection_string};
	    $host =~ s/^(.*):.*$/$1/;
	    my $port = $zserver_href->{z3950_connection_string};
	    $port =~ s/^.*:(.*)\/.*$/$1/;
	    my $porttester = Net::Ping->new("tcp");
	    $porttester->port_number($port);
	    if ($porttester->ping($host)) {
		$status{porttest} = "$host is reachable on port $port.";
	    } else {
		$status{porttest} = "$host is NOT reachable on port $port.";
	    }
	    $porttester->close();

	    eval {
		my $optionset = new ZOOM::Options();
		$optionset->option(implementationName => "Maplin connection tester");
		$optionset->option(preferredRecordSyntax => "usmarc");
		$optionset->option(async => 0);
		$optionset->option(count => 1);
		$optionset->option(timeout => 30);
		my $conn = create ZOOM::Connection($optionset);
		$conn->connect($zserver_href->{z3950_connection_string}, 0);
		
		$status{search_terms} = "title keyword 'dinosaur'";
		$status{search_string} = '@attr 1=4 dinosaur';
		my $resultset = $conn->search_pqf('@attr 1=4 dinosaur');
		my $n = $resultset->size();
		$status{result_count} = $n;
	    };	
	    if ($@) {
		$status{error} = $@->render;
	    } else {
		my $ip = $zserver_href->{z3950_connection_string};
		$ip =~ s/^(.*):.*$/$1/;
		$status{error} = "Connected to $ip";
	    }

	} else {
	    $status{stage} = "Hmm.  You don't seem to have a zServer registered on Maplin.  Please contact us with your z39.50 connection information, and we'll add you.";
	}

    }
    push( @status_data, \%status );
    my $template = $self->load_tmpl('info/myzserverstatus.tmpl');
    $template->param(
	pagetitle => "Maplin-3 Info My zServer Status",
	username => $self->authen->username,
	showserver => $showserver,
	zserver => \@zserver_data, 
	status => \@status_data
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub info_all_zservers_process_DEPRECATED {
    my $self = shift;
    my $q = $self->query;

    my $SQL_getUser = "SELECT name, alive, available from zservers WHERE isstandardresource=1 ORDER BY name";

    # Get the form data
    my $aref = $self->dbh->selectall_arrayref(
	$SQL_getUser,
	{ Slice => {} }
	);
    
    my $template = $self->load_tmpl('info/allzservers.tmpl');
    $template->param(pagetitle => "Maplin-3 Info All zServers Status",
		     username => $self->authen->username,
		     zservers => $aref);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub info_all_zservers_process {
    my $self = shift;
    my $q = $self->query;

    my @status;

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
    $year += 1900;
    $mon += 1;
    my $current_time = sprintf("%4d-%02d-%02d %02d:%02d:%02d ", $year,$mon,$mday,$hour,$min,$sec);
    my $test_description = "This test involves searching each zServer's title index for the keyword 'dinosaur'.";

    if ($q->param('do_test')) {
	
	# Get list of available servers from db
	my $SQL = "SELECT id, name, z3950_connection_string, email_address, alive, available, ils FROM zservers WHERE isstandardresource=1 ORDER BY name";
	my $ar_conn = $self->dbh->selectall_arrayref( $SQL, { Slice => {} } );
	
	# Test each zserver
	for (my $i = 0; $i < @$ar_conn; $i++) {
	    my %libstatus;
	    $libstatus{ name } = $ar_conn->[$i]{name};
	    $libstatus{ available } = $ar_conn->[$i]{available};
	    $libstatus{ alive } = $ar_conn->[$i]{alive};
	    $libstatus{ ils } = $ar_conn->[$i]{ils};
	    
	    my $n;
	    
	    if ($ar_conn->[$i]{available}) {
		eval {
		    my $optionset = new ZOOM::Options();
		    $optionset->option(implementationName => "Maplin connection tester");
		    $optionset->option(preferredRecordSyntax => "usmarc");
		    $optionset->option(async => 0);
		    $optionset->option(count => 1);
		    $optionset->option(timeout => 30);
		    my $conn = create ZOOM::Connection($optionset);
		    $conn->connect($ar_conn->[$i]{z3950_connection_string}, 0);

		    $libstatus{ serverImplementationName } = $conn->option("serverImplementationName");
		    
		    my $resultset = $conn->search_pqf('@attr 1=4 dinosaur');
		    $n = $resultset->size();
		};
		if ($@) {
		    $libstatus{ msg } = $@->render();		
		    $libstatus{ count } = 0;
		    $libstatus{ alive } = 0;
		} else {
		    $libstatus{ count } = $n;
		    if ($n == 0) {
			$libstatus{ msg } = "Can connect, but returns 0 records.";
		    } else {
			$libstatus{ msg } = "ok";
		    }
		}
		
	    } else {
		$libstatus{ msg } = "Library has marked itself unavailable.";
		$libstatus{ count } = 0;
	    }
	    push @status, \%libstatus;
	}
    }

    my $template = $self->load_tmpl('info/allzservers.tmpl');
    $template->param(pagetitle => "Maplin-3 Info All zServers Status",
		     username => $self->authen->username,
		     test_description => $test_description,
		     current_time => $current_time,
		     do_test => $q->param('do_test') ? 1 : 0,
		     status => \@status,
	);
    return $template->output;
}

1; # so the 'require' or 'use' succeeds

