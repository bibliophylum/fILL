package publicbase;
use strict;
use base 'CGI::Application';
use CGI::Application::Plugin::DBH (qw/dbh_config dbh/);
use CGI::Application::Plugin::Session;
use CGI::Application::Plugin::LogDispatch;
use CGI::Application::Plugin::Authentication;
use Data::Dumper;

my %config = (
    DRIVER         => [ 'DBI',
			TABLE => 'patrons',
			CONSTRAINTS => {
			    'patrons.username' => '__CREDENTIAL_1__',
			    'MD5:patrons.password' => '__CREDENTIAL_2__',
			    'patrons.is_enabled' => 1
			},

    ],
    STORE          => 'Session',
    LOGIN_RUNMODE  => 'loginFOO',
    POST_LOGIN_RUNMODE => 'welcome',
    LOGOUT_RUNMODE => 'logged_out',
    );

publicbase->authen->config(%config);
#publicbase->authen->protected_runmodes(':all');
# protect everything but the self-registration form:
publicbase->authen->protected_runmodes(qr/^(?!registration_)/);

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
           filename => '/opt/maplin3/logs/messages_public.log',
          min_level => 'debug'
        },
      ],
      APPEND_NEWLINE => 1,
    );

    # common runmodes
    $self->run_modes(
	'loginFOO'                   => 'login_foo',
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

#    # from the CGI::Application::Plugin::Session docs:
#    my $self = shift;
#    # Redirect to login in necessary
#    unless ( $self->session->param('~logged-in') ) {
#	$self->prerun_mode('login');
#	#$self->prerun_mode('patron_identification');
#    }

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

    my $rows_affected = $self->dbh->do("UPDATE patrons SET last_login=NOW() WHERE username=?",
				       undef,
				       $self->authen->username,
	);


    # Open the html template
    # NOTE 1: load_tmpl() is a CGI::Application method, not a HTML::Template method.
    # NOTE 2: Setting the 'cache' flag caches the template if used with mod_perl. 
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
	                      'public/logged_out.tmpl',
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
	                      'forbidden.tmpl',
			      cache => 1,
			     );	
    $template->param(USERNAME => $self->authen->username);

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
    $template->param(USERNAME => $self->authen->username,
		     env_variable_loop => \@loop
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
# This is what RENDER_LOGIN uses to get the html login form.
#
sub login_foo {
    my $self = shift;
    $self->session_delete; # toast any old session info
    my $template = $self->load_tmpl('public/login.tmpl');
    return $template->output;
}

1; # so the 'require' or 'use' succeeds
