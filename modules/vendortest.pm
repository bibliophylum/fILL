package vendortest;
use strict;
use base 'CGI::Application';
use CGI::Application::Plugin::DBH (qw/dbh_config dbh/);
use CGI::Application::Plugin::Session;
use CGI::Application::Plugin::Authentication;
#use CGI::Application::Plugin::Authentication::Driver::DBI;
#use CGI::Application::Plugin::Authorization;
use CGI::Application::Plugin::LogDispatch;
use ZOOM;
use MARC::Record;
use Data::Dumper;

my %config = (
    DRIVER => 'Dummy',
    STORE          => 'Session',
    POST_LOGIN_RUNMODE => 'vendortest_test_zserver_form',
    LOGOUT_RUNMODE => 'logged_out',
    );
#my %config = (
#    DRIVER => [ 'Generic', { L4U => 'L4U' } ],
#    STORE          => 'Session',
#    POST_LOGIN_RUNMODE => 'vendortest_test_zserver_form',
#    LOGOUT_RUNMODE => 'logged_out',
#    );
#my %config = (
#    DRIVER         => [ 'DBI',
#			TABLE => 'vendor',
#			CONSTRAINTS => {
#			    'vendor.name' => '__CREDENTIAL_1__',
#			    'vendor.password' => '__CREDENTIAL_2__',
#			    'vendor.active' => 1
#			},
#
#    ],
#    STORE          => 'Session',
#    POST_LOGIN_RUNMODE => 'vendortest_test_zserver_form',
#    LOGOUT_RUNMODE => 'logged_out',
#    );
vendortest->authen->config(%config);
vendortest->authen->protected_runmodes(':all');



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

#    # Configure authorization
#    $self->authz->config(
#    DRIVER => [
#	'DBI',
#	DBH         => $self->dbh,
#	TABLES      => [ 'vendor' ],
##        JOIN_ON     => 'author.authorId = article.authorId',
#	CONSTRAINTS => {
#	    'vendor.name'    => '__USERNAME__',
##	    'users.admin'  => '__PARAM_1__',
#	},
#    ],
#    FORBIDDEN_RUNMODE => 'forbidden',
#    );
#
#    # protect only runmodes that start with vendortest_
#    $self->authz->authz_runmodes(
#	qr/^vendortest_/ => 1,
#	);
}

#--------------------------------------------------------------------------------
# Define our runmodes
#
sub setup {
    my $self = shift;
    $self->start_mode('vendortest_test_zserver_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'welcome'                      => 'welcome_process',
	'logged_out'                   => 'show_logged_out_process',
	'forbidden'                    => 'forbidden_process',
	'environment_form'             => 'environment_process',
	'vendortest_test_zserver_form' => 'vendortest_test_zserver_process',
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
sub welcome_process {
    # The application object
    my $self = shift;

#    my $rows_affected = $self->dbh->do("UPDATE users SET last_login=NOW() WHERE name=?",
#				       undef,
#				       $self->authen->username,
#	);


    # Open the html template
    # NOTE 1: load_tmpl() is a CGI::Application method, not a HTML::Template method.
    # NOTE 2: Setting the 'cache' flag caches the template if used with mod_perl. 
    my $template = $self->load_tmpl(	    
	                      'vendortest/welcome.tmpl',
			      cache => 0,
			     );	
    $template->param( username => $self->authen->username,
		      sessionid => $self->session->id(),
	);

    # Parse the template
    my $html_output = $template->output;
    return $html_output;
}

#--------------------------------------------------------------------------------
#
#
sub show_logged_out_process {
    # The application object
    my $self = shift;

    #
    # Do some housekeeping
    #
    # Clear any old search results
    $self->dbh->do("DELETE FROM marc WHERE sessionid=?",undef,$self->session->id());
    # Clear any status results
    $self->dbh->do("DELETE FROM status_check WHERE sessionid=?",undef,$self->session->id());

    # Open the html template
    # NOTE 1: load_tmpl() is a CGI::Application method, not a HTML::Template method.
    # NOTE 2: Setting the 'cache' flag caches the template if used with mod_perl. 
    my $template = $self->load_tmpl(	    
	                      'vendortest/logged_out.tmpl',
			      cache => 1,
			     );	
    $template->param( username => "Logged out. ",
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
	'vendortest/forbidden.tmpl',
#	'vendortest/welcome.tmpl',
	cache => 1,
	);	
    $template->param( username => $self->authen->username,
		      sessionid => $self->session->id(),
	);

    # This would log the user out....
    # $self->session->delete();

    # Parse the template
    my $html_output = $template->output;
    return $html_output;
}

#--------------------------------------------------------------------------------
#
#
sub environment_process {
    my $self = shift;

    my $template = $self->load_tmpl('vendortest/display.tmpl');
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
sub vendortest_test_zserver_process {
    my $self = shift;
    my $q = $self->query;

    my $test_results = "";

    my $target = $q->param("target");
    my $conn   = $q->param("conn") || $target;
    my $prs    = $q->param("prs") || "usmarc";
    my $es     = $q->param("es") || "f";
    my $pqf    = $q->param("pqf");

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
	$test_results = _test_zserver($conn, $prs, $es, $pqf);
    }

    my $template = $self->load_tmpl('vendortest/vendortest.tmpl');
    $template->param(username => $self->authen->username,
		     zservers => $ar_conn,
		     conn => $conn,
		     pqf => $pqf,
		     test_results => $test_results,
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
# INTERNAL
# parameter: "xxx.xxx.xxx.xxx:port/dbname"
# parameter: preferred record syntax (eg: "usmarc", "opac")
# parameter: pqf string
#
sub _test_zserver {
    my $connection_string = shift;
    my $preferredRecordSyntax = shift;
    my $elementSet = shift;
    my $pqf = shift;

    $preferredRecordSyntax = "usmarc" unless ($preferredRecordSyntax);
    $elementSet = "f" unless ($elementSet);
    $pqf = '@attr 1=4 "duck hunting"' unless ($pqf);

    my $s = "";
    my $conn;
    
    my $rs;
    my $n;

    $s .= "\n--[ Connection ]-------\n";
    $s .= "$connection_string\n";
    $s .= "preferredRecordSyntax set to: $preferredRecordSyntax\n";
    $s .= "elementSet set to: $elementSet\n";

    eval {
	$s .= "\n--[ Z39.50 test ]------\n";
	$conn = new ZOOM::Connection($connection_string);
	$s .= "server is '" . $conn->option("serverImplementationName") . "'\n";
#	$conn->option(preferredRecordSyntax => "usmarc");
#       $conn->option(preferredRecordSyntax => "opac");
	$conn->option(preferredRecordSyntax => $preferredRecordSyntax);
	$conn->option(elementSetName => $elementSet);
    };
    if ($@) {
	$s .= "Error " . $@->code() . ": " . $@->message() . "\n";
	
    } else {
	eval {
	    $s .= "\n--[ search ]----\n";
	    $s .= "$pqf\n";
	    $rs = $conn->search_pqf($pqf);
	    $n = $rs->size();
	    $s .= "$n record(s) found.\n";
	    if ($n > 0) {
		$s .= "-[Record #0 (1st record)]--\n";
		$s .= $rs->record(0)->render();
	    }
	    if ($n > 1) {
		$s .= "-[Record #1 (2nd record)]--\n";
		$s .= $rs->record(1)->render();
	    }
	    if ($n > 2) {
		$s .= "-[Record #2 (3rd record)]--\n";
		$s .= $rs->record(2)->render();
	    }
	};
	if ($@) {
	    $s .= "Error " . $@->code() . ": " . $@->message() . "\n";
	}
    }
    return $s;
}


1; # so the 'require' or 'use' succeeds
