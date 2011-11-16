package maplin3base;
use strict;
use base 'CGI::Application';
use CGI::Application::Plugin::DBH (qw/dbh_config dbh/);
use CGI::Application::Plugin::Session;
use CGI::Application::Plugin::Authentication;
use CGI::Application::Plugin::Authentication::Driver::DBI;
use CGI::Application::Plugin::Authorization;
use CGI::Application::Plugin::LogDispatch;
use Data::Dumper;

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
    POST_LOGIN_RUNMODE => 'welcome',
    LOGOUT_RUNMODE => 'logged_out',
    LOGIN_FORM => { 
	TITLE => 'Sign in to Maplin',
	COMMENT => 'Reminder: When placing a request please select the library that is the highest Net-Borrower.  This helps make the interlibrary loan workload fair for all libraries.',
	FOCUS_FORM_ONLOAD => 1,
    }
    );

maplin3base->authen->config(%config);
maplin3base->authen->protected_runmodes(':all');



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
           filename => '/opt/maplin3/logs/messages.log',
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
	    TABLES      => [ 'libraries','library_authgroups','authgroups' ],
	    JOIN_ON     => 'libraries.lid = library_authgroups.lid AND library_authgroups.gid = authgroups.gid',
	    CONSTRAINTS => {
		'libraries.name' => '__USERNAME__',
		'authgroups.authorization_group' => '__PARAM_1__',
	    },
	],
	FORBIDDEN_RUNMODE => 'forbidden',
	);

    # protect only runmodes that start with admin_
    $self->authz->authz_runmodes(
#	[qr/^admin_/ => 1],
	qr/^admin_/ => 'admin',
	reports_home_zServers_form => 'reports',
	);

    # common runmodes
    $self->run_modes(
#	'dbtest'        => 'display_db_entries',
#	'emailtest'     => 'send_test_email',

	'welcome'                    => 'welcome_process',
	'logged_out'                 => 'show_logged_out_process',
	'forbidden'                  => 'forbidden_process',
	'environment_form'           => 'environment_process',
	);
}


#--------------------------------------------------------------------------------
# Execute the following before we execute the requested run mode
#
sub cgiapp_prerun {
    my $self = shift;

    # Get a fresh page (not from cache)!
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
                        private
                        no-store
                        no-cache
                        must-revalidate
                        max-age=0
                        post-check=0
                        pre-check=0
                        )),
	);

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

    my $rows_affected = $self->dbh->do("UPDATE libraries SET last_login=NOW() WHERE name=?",
				       undef,
				       $self->authen->username,
	);


    # Open the html template
    # NOTE 1: load_tmpl() is a CGI::Application method, not a HTML::Template method.
    # NOTE 2: Setting the 'cache' flag caches the template if used with mod_perl. 
    my $template = $self->load_tmpl(	    
	                      'welcome.tmpl',
			      cache => 0,
			     );	
    $template->param( pagetitle => 'Maplin-4 Welcome',
		      username => $self->authen->username,
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
	                      'logged_out.tmpl',
			      cache => 1,
			     );	
    $template->param( pagetitle => 'Maplin-4 Logged Out',
		      username => "Logged out. ",
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
    $template->param( pagetitle => 'Maplin-4 Forbidden',
		      username => $self->authen->username,
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

    my $template = $self->load_tmpl('environment/display.tmpl');
    my @loop;
    foreach my $key (keys %ENV) {
	my %row = ( name => $key,
		    value => $ENV{$key},
	    );
	push(@loop, \%row);
    }
    $template->param(pagetitle => 'Maplin-4 Environment',
		     env_variable_loop => \@loop);
    return $template->output;
}


1; # so the 'require' or 'use' succeeds
