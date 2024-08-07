#
#    fILL - Free/Open-Source Interlibrary Loan management system
#    Copyright (C) 2012  Government of Manitoba
#
#    fILLbase.pm is a part of fILL.
#
#    fILL is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    fILL is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

package fILLbase;
use strict;
use base 'CGI::Application';
use CGI::Application::Plugin::DBH (qw/dbh_config dbh/);
use CGI::Application::Plugin::Session;
use CGI::Application::Plugin::Authentication;
use CGI::Application::Plugin::Authentication::Driver::DBI;
use CGI::Application::Plugin::Authorization;
use CGI::Application::Plugin::LogDispatch;
use Digest::SHA;  # (k)ubuntu 12.04 replaces libdigest-sha1-perl with libdigest-sha-perl
use Data::Dumper;

#{SHA}||encode(digest('mvbb','sha1'),'base64')

my %config = (
    DRIVER         => [ 'DBI',
			TABLE => 'users',
			CONSTRAINTS => {
			    'users.username' => '__CREDENTIAL_1__',
			    'MD5:users.password' => '__CREDENTIAL_2__'
			},

    ],
    STORE          => 'Session',
    POST_LOGIN_RUNMODE => 'welcome',
    LOGOUT_RUNMODE => 'logged_out',
    LOGIN_RUNMODE => 'login',
    );

fILLbase->authen->config(%config);
fILLbase->authen->protected_runmodes(':all');



#--------------------------------------------------------------------------------
#
#
sub cgiapp_init {
    my $self = shift;
    
    # use the same args as DBI->connect();
    $self->dbh_config("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    );

    $self->dbh->do("SET TIMEZONE='America/Winnipeg'");

    # Configure the LogDispatch session
    $self->log_config(
      LOG_DISPATCH_MODULES => [ 
        {    module => 'Log::Dispatch::File',
               name => 'messages',
           filename => '/opt/fILL/logs/messages.log',
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
	    TABLES      => [ 'org','library_authgroups','authgroups' ],
	    JOIN_ON     => 'org.oid = library_authgroups.oid AND library_authgroups.gid = authgroups.gid',
	    CONSTRAINTS => {
		'org.symbol' => '__USERNAME__',
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

	'login'                      => 'login_process',
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
	# postgres is in UTF-8
	-charset => 'UTF-8',
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

    my ($oid,$symbol,$library,$lib_status) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $rows_affected = $self->dbh->do("UPDATE org SET last_login=NOW() WHERE oid=?",
				       undef,
				       $oid,
	);


    # Open the html template
    # NOTE 1: load_tmpl() is a CGI::Application method, not a HTML::Template method.
    # NOTE 2: Setting the 'cache' flag caches the template if used with mod_perl. 
    my $template = $self->load_tmpl(	    
	                      'welcome.tmpl',
			      cache => 0,
			     );	
    $template->param( pagetitle => 'fILL Welcome',
		      username => $self->authen->username,
		      sessionid => $self->session->id(),
		      oid => $oid,
		      library => $library,
		      libsym => $symbol,   # needed for z39.50 connectivity check
		      lib_status => $lib_status,
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

    # Open the html template
    # NOTE 1: load_tmpl() is a CGI::Application method, not a HTML::Template method.
    # NOTE 2: Setting the 'cache' flag caches the template if used with mod_perl. 
    my $template = $self->load_tmpl(	    
	                      'logged_out.tmpl',
			      cache => 1,
			     );	
    $template->param( pagetitle => 'fILL Logged Out',
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
    $template->param( pagetitle => 'fILL Forbidden',
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
sub login_process {
    my $self = shift;
    $self->session_delete; # toast any old session info
    my $template = $self->load_tmpl('login.tmpl',cache => 0);	
    $template->param( pagetitle => 'Log in to fILL');
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub environment_process {
    my $self = shift;

    my $template = $self->load_tmpl('environment/display.tmpl');
    my @loop;
    foreach my $key (sort keys %ENV) {
	my %row = ( name => $key,
		    value => $ENV{$key},
	    );
	push(@loop, \%row);
    }
    $template->param(pagetitle => 'fILL Environment',
		     http_user_agent => $ENV{'HTTP_USER_AGENT'},
		     env_variable_loop => \@loop);
    return $template->output;
}


#--------------------------------------------------------------------------------------------
sub get_library_from_username {
    my $self = shift;
    my $username = shift;
    # Get this user's library id
    my $hr_id = $self->dbh->selectrow_hashref(
	"select o.oid, o.symbol, o.org_name, o.lib_status from users u left join org o on (u.oid = o.oid) where u.username=?",
	undef,
	$username
	);
    $self->log->debug( Dumper( $hr_id ) );
    return ($hr_id->{oid}, $hr_id->{symbol}, $hr_id->{org_name}, $hr_id->{lib_status});
}


1; # so the 'require' or 'use' succeeds
