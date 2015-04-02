#
#    fILL - Free/Open-Source Interlibrary Loan management system
#    Copyright (C) 2012  Government of Manitoba
#
#    publicbase.pm is a part of fILL.
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

package publicbase;
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
use JSON;
use Biblio::SIP2::Client;
use String::Random;
#use IPC::System::Simple qw(capture $EXITVAL EXIT_ANY);
#use Capture::Tiny ':all';

#{SHA}||encode(digest('mvbb','sha1'),'base64')


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
           filename => '/opt/fILL/logs/messages-public.log',
          min_level => 'debug'
        },
      ],
      APPEND_NEWLINE => 1,
    );

    # configure authentication
    $self->authen->config(
	CREDENTIALS => ['authen_username','authen_password','authen_barcode','authen_pin','authen_lid'],
	DRIVER => [ 
	    [ 'Generic', sub { return $self->sip2Authenticate( @_ ); } ],
	    [ 'DBI',
	      TABLE => 'patrons',
	      CONSTRAINTS => {
		  'patrons.username' => '__CREDENTIAL_1__',
		  'MD5:patrons.password' => '__CREDENTIAL_2__',
#	      'patrons.is_enabled' => 1
	      },
	    ],
	],
	STORE          => 'Session',
	LOGIN_RUNMODE  => 'loginFOO',
	POST_LOGIN_CALLBACK => \&update_login_date,
	POST_LOGIN_RUNMODE => 'search_form',
	LOGOUT_RUNMODE => 'logged_out',
	# force re-authentication if idle for more than 30 minutes
	LOGIN_SESSION_TIMEOUT => '30m',
	);
    #publicbase->authen->protected_runmodes(':all');
    # protect everything but the self-registration form:
    $self->authen->protected_runmodes(qr/^(?!registration_)/);


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
	'loginFOO'                   => 'login_foo',
	'welcome'                    => 'welcome_process',
	'logged_out'                 => 'show_logged_out_process',
	'forbidden'                  => 'forbidden_process',
	'environment_form'           => 'environment_process',
	);

}


#--------------------------------------------------------------------------------
#
#
sub sip2Authenticate {
    my $self = shift;
    my ($username, $password, $barcode, $pin, $lid) = @_;  # username and password should be undefined if this is a sip2 authen

    my $pname = $self->checkSip2($username, $password, $barcode, $pin, $lid);
    if ($pname) {
	# authenticated user.  Is there a fILL patron record?
	my $href = $self->dbh->selectrow_hashref(
	    "select pid from patrons where home_library_id=? and card=?",
	    undef,
	    $lid,
	    $barcode
	    );
	if (defined $href) {
	    # fILL patron record exists
	    # patron's name and username are set to their barcode on logout;
	    # set them here to the patron's name as returned by the SIP2 server.
	    # This will allow display of the patron's name (to themselves) while
	    # they're logged in.  
	    my $rows_affected = $self->dbh->do("update patrons set username=?, name=? where pid=?", undef, $pname, $pname, $href->{"pid"});

	} else {
	    # from bin/register-sip2-patron.cgi:
	    my $SR = new String::Random;
	    my $pass = $SR->randregex('[\w]{75}'); # generate a random-ish string for a password that will never be used.

	    my $rows_affected = $self->dbh->do("INSERT INTO patrons (is_sip2, username, password, home_library_id, name, card, is_verified) VALUES (?,?,md5(?),?,?,?,?)", undef, 
					       1,
					       $pname,
					       $pass,
					       $lid,
					       $pname,
					       $barcode,
					       1
		);
	}
    }
    return $pname;
}

#--------------------------------------------------------------------------------
#
#
sub checkSip2 {
    # from sip2-authenticate.cgi
    my $self = shift;
    my ($username, $password, $barcode, $pin, $lid) = @_;  # username and password should be undefined if this is a sip2 authen

    $self->log->debug( "checkSip2:\n" . Dumper(@_) . "\n" );

    my $SQL = "select host,port,terminator,sip_server_login,sip_server_password,validate_using_info from library_sip2 where lid=?";
    my $href = $self->dbh->selectrow_hashref($SQL,undef,$lid);

    $self->log->debug( "returned from DBI:\n" . Dumper($href) );

    if (defined $href) {
	# need to translate from postgresql field name to SIP2 field name
	if ($href->{terminator}) {
	    $href->{msgTerminator} = $href->{terminator};
	}
    } else {
	# no SIP2 server, so bail
	return undef;
    }

#    $self->log->debug("creating bsc\n");
    my $bsc = Biblio::SIP2::Client->new( %$href );
    $bsc->connect();
    my $authorized_href = $bsc->verifyPatron($barcode,$pin);

    $bsc->disconnect();
#    $self->log->debug("done with bsc\n");
#    $self->log->debug( "authorized:\n" . Dumper($authorized_href) . "\n");

    return $authorized_href->{'patronname'};
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
sub update_login_date {
    # The application object
    my $self = shift;

    my ($pid, $lid,$library) = get_patron_from_username($self, $self->authen->username);  # do error checking!

    my $rows_affected = $self->dbh->do("UPDATE patrons SET last_login=NOW() WHERE username=?",
				       undef,
				       $self->authen->username,
	);

#    # Open the html template
#    # NOTE 1: load_tmpl() is a CGI::Application method, not a HTML::Template method.
#    # NOTE 2: Setting the 'cache' flag caches the template if used with mod_perl. 
#    my $template = $self->load_tmpl(	    
#	                      'public/welcome.tmpl',
#			      cache => 0,
#			     );	
#    $template->param( pagetitle => 'Public fILL Welcome',
#		      username => $self->authen->username,
#		      sessionid => $self->session->id(),
#		      lid => $lid,
#		      library => $library,
#	);
#
#    # Parse the template
#    my $html_output = $template->output;
#    return $html_output;

}

#--------------------------------------------------------------------------------
#
#
sub show_logged_out_process {
    # The application object
    my $self = shift;

    # Gah.  At this point, $self->authen->username is undef.

#    # When SIP2 user logs out, set the username and patron name to their barcode so
#    # the system isn't storing names (for privacy reasons).
#    my ($pid, $lid,$library) = get_patron_from_username($self, $self->authen->username);  # do error checking!
#    my $href = $self->dbh->selectrow_hashref("select is_sip2 from patrons where pid=?",	undef, $pid);
#    if (defined $href) {
#	if ($href->{"is_sip2"}) {
#	    my $rows_affected = $self->dbh->do("update patrons set username=card, name=card where pid=?", undef, $pid);
#	}
#    }

    my $template = $self->load_tmpl(	    
	'public/logged_out.tmpl',
	cache => 1,
	);
    $template->param( pagetitle => 'fILL Logged Out',
		      username => "Logged out. ",
		      sessionid => $self->session->id(),
#		      pid => $pid,
#		      is_sip2 => $href->{"is_sip2"},
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
sub environment_process {
    my $self = shift;

    my $template = $self->load_tmpl('public/environment.tmpl');
    my @loop;
    foreach my $key (keys %ENV) {
	my %row = ( name => $key,
		    value => $ENV{$key},
	    );
	push(@loop, \%row);
    }
    $template->param(pagetitle => 'fILL Environment',
		     env_variable_loop => \@loop);
    return $template->output;
}


#--------------------------------------------------------------------------------
sub get_patron_from_username {
    my $self = shift;
    my $username = shift;
    # Get this user's library id
    my $hr_id = $self->dbh->selectrow_hashref(
	"select p.pid, p.home_library_id, l.library from patrons p left join libraries l on (p.home_library_id = l.lid) where p.username=?",
	undef,
	$username
	);
    $self->log->debug( Dumper( $hr_id ) );
    return ($hr_id->{pid}, $hr_id->{home_library_id}, $hr_id->{library});
}

#--------------------------------------------------------------------------------
# This is what RENDER_LOGIN uses to get the html login form.
#
sub login_foo {
    my $self = shift;
    $self->session_delete; # toast any old session info
    my $template = $self->load_tmpl('public/login.tmpl');
    $template->param( pagetitle => 'fILL public login' );
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
#sub login_process {
#    my $self = shift;
#    my $template = $self->load_tmpl(	    
#	                      'login.tmpl',
#			      cache => 0,
#			     );	
#    $template->param( pagetitle => 'Log in to fILL',
#	);
#
#    # Parse the template
#    my $html_output = $template->output;
#    return $html_output;
#}

#---------------------------------------------------------------
# for debugging...
#---------------------------------------------------------------
sub print_parsed_response {
    my $self = shift;
    my $parsed = shift;

    $self->log->debug( "Fixed:\n");
    my $href = $parsed->{'fixed'};
    foreach my $key (keys %$href) { 
	$self->log->debug( "$key\t"); 
	if (ref( $href->{$key} ) eq "ARRAY") {
	    $self->log->debug( "\n");
	    foreach my $elem (@{$href->{$key}}) {
		$elem =~ s/\r//;
		$self->log->debug( "\t$elem\n");
	    }
	} else {
	    $href->{$key} =~ s/\r//;
	    $self->log->debug( "[" . $href->{$key} . "]\n"); 
	}
    }

    $self->log->debug( "Variable:\n");
    $href = $parsed->{'variable'};
    foreach my $key (keys %$href) { 
	$self->log->debug( "$key\t"); 
	if (ref( $href->{$key} ) eq "ARRAY") {
	    $self->log->debug( "\n");
	    foreach my $elem (@{$href->{$key}}) {
		$elem =~ s/\r//;
		$self->log->debug( "\t$elem\n");
	    }
	} else {
	    $href->{$key} =~ s/\r//;
	    $self->log->debug( "[" . $href->{$key} . "]\n" ); 
	}
    }
}


1; # so the 'require' or 'use' succeeds
