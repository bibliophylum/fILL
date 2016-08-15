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
#use Biblio::SIP2::Client;
use Biblio::Authentication::SIP2;
use Biblio::Authentication::Biblionet;
use Biblio::Authentication::FollettDestiny;
use Biblio::Authentication::L4U;
use Biblio::Authentication::L4U_API;
use Biblio::Authentication::TLC;
use Biblio::Authentication::Dummy;   # for testing
use Biblio::Authentication::TempNorthNorfolk;   # Dummy clone
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
	CREDENTIALS => ['authen_username','authen_password','authen_barcode','authen_pin','authen_oid'],
	DRIVER => [ 
	    [ 'Generic', sub { return $self->externallyAuthenticate( @_ ); } ],
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
sub createPatronRecordIfRequired {
    my $self = shift;
    my ($oid, $barcode) = @_;

    my $pid;

    # authenticated user.  Is there a fILL patron record?
    my $href = $self->dbh->selectrow_hashref(
	"select pid from patrons where home_library_id=? and card=?",
	undef,
	$oid,
	$barcode
	);
    if (defined $href) {
	# fILL patron record exists
	$pid = $href->{pid};

    } else {
	# from bin/register-sip2-patron.cgi:
	my $SR = new String::Random;
	my $pass = $SR->randregex('[\w]{75}'); # generate a random-ish string for a password that will never be used.
	# note that we don't store user name for externally-authenticated patrons;
	# use barcode instead.
	# patron name is stored in session (so it can be displayed on user's
	# pages), and only valid while session is active
	my $rows_affected = $self->dbh->do("INSERT INTO patrons (is_externally_authenticated, username, password, home_library_id, name, card, is_verified) VALUES (?,?,md5(?),?,?,?,?)", undef, 
					   1,
					   $barcode,
					   $pass,
					   $oid,
					   $barcode,
					   $barcode,
					   1
	    );
	my $href = $self->dbh->selectrow_hashref(
	    "select pid from patrons where home_library_id=? and card=?",
	    undef,
	    $oid,
	    $barcode
	    );
	$pid = $href->{pid};
    }
    return $pid;
}

#--------------------------------------------------------------------------------
#
#
sub externallyAuthenticate {
    my $self = shift;
    my ($username, $password, $barcode, $pin, $oid) = @_;  # username and password should be undefined if this is a sip2 authen

    #$self->log->debug( "externallyAuthenticate....\n" );
    my $pname;
    # is this a SIP2 library?
    my $lib_href = $self->dbh->selectrow_hashref("select patron_authentication_method, org_name from org where oid=?", undef, $oid);

    #$self->log->debug( "externallyAuthenticate: $barcode, $pin, $oid\n" );
    if ($lib_href->{patron_authentication_method} eq 'sip2') {
	#$self->log->debug( "externallyAuthenticate using sip2\n" );
	$pname = $self->checkSip2($username, $password, $barcode, $pin, $oid);

    } else {
	$pname = $self->checkNonSip2($username, $password, $barcode, $pin, $oid, 
	    $lib_href->{patron_authentication_method});
    }

    if ($pname) {
	my $pid = $self->createPatronRecordIfRequired( $oid, $barcode );
	$self->session->param('fILL-card',$barcode);
	$self->session->param('fILL-pid',$pid);
	$self->session->param('fILL-oid',$oid);
	$self->session->param('fILL-library', $lib_href->{'library'}); 
	$self->session->param('fILL-is_enabled',1); # if they authenticated, they're enabled
    }
    $self->log->debug( "externallyAuthenticate returned [$pname] using auth method [" . $lib_href->{patron_authentication_method} . "]\n" );
    return $pname;
}

#--------------------------------------------------------------------------------
#
#
sub checkSip2 {
    my $self = shift;
    my ($username, $password, $barcode, $pin, $oid) = @_;  # username and password should be undefined if this is a sip2 authen

#    $self->log->debug( "checkSip2:\n" . Dumper(@_) . "\n" );

    my $SQL = "select host,port,terminator,sip_server_login,sip_server_password,validate_using_info from library_sip2 where oid=?";
    my $href = $self->dbh->selectrow_hashref($SQL,undef,$oid);

#    $self->log->debug( "returned from DBI:\n" . Dumper($href) );

    if (defined $href) {
	# need to translate from postgresql field name to SIP2 field name
	if ($href->{terminator}) {
	    $href->{msgTerminator} = $href->{terminator};
	}
    } else {
	# no SIP2 server, so bail
	return undef;
    }

#    $self->log->debug( "attempting to authenticate user...\n" );
    $href->{debug} = 0;
    my $authenticator = Biblio::Authentication::SIP2->new( %$href );
    my $authorized_href = $authenticator->verifyPatron($barcode,$pin);

#    $self->log->debug( "authorized:\n" . Dumper($authorized_href) . "\n");

    $self->session->param('fILL-auth-screenmessage',$authorized_href->{'screenmessage'});
    return $authorized_href->{'patronname'};
}

#--------------------------------------------------------------------------------
#
#
sub checkNonSip2 {
    my $self = shift;
    my ($username, $password, $barcode, $pin, $oid, $authmethod) = @_;

    $self->log->debug( "checkNonSip2:\n" . Dumper(@_) . "\n" );

    my $SQL = "select url from library_nonsip2 where oid=? and auth_type=?";
    my $href = $self->dbh->selectrow_hashref($SQL,undef,$oid,$authmethod);

    $self->log->debug( "returned from DBI:\n" . Dumper($href) );

    if (!defined $href) {
	$self->session->param(
	    'fILL-auth-screenmessage',
	    "Unable to determine authentication method.  Please contact your library."
	    );
	return undef;
    }

    my $authenticator;
    if ($authmethod eq 'Biblionet') {
	$authenticator = Biblio::Authentication::Biblionet->new( %$href );

    } elsif ($authmethod eq 'FollettDestiny') {
	$authenticator = Biblio::Authentication::FollettDestiny->new( %$href );

    } elsif ($authmethod eq 'L4U') {
	$authenticator = Biblio::Authentication::L4U->new( %$href );

    } elsif ($authmethod eq 'L4U_API') {
	$authenticator = Biblio::Authentication::L4U_API->new( %$href );

    } elsif ($authmethod eq 'TLC') {
	$authenticator = Biblio::Authentication::TLC->new( %$href );

    } elsif ($authmethod eq 'Dummy') {
	$authenticator = Biblio::Authentication::Dummy->new( %$href );

    } elsif ($authmethod eq 'TempNorthNorfolk') {
	$authenticator = Biblio::Authentication::TempNorthNorfolk->new( %$href );
    }

    if (!defined $authenticator) {
	$self->session->param(
	    'fILL-auth-screenmessage',
	    "Unable to determine authentication method.  Please contact your library."
	    );
	return undef;
    }

    my $authorized_href = $authenticator->verifyPatron($barcode,$pin);

#    $self->log->debug( "authorized:\n" . Dumper($authorized_href) . "\n");

    $self->session->param('fILL-auth-screenmessage',$authorized_href->{'screenmessage'});
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
    my $self = shift;

    my ($pid, $oid,$library,$is_enabled) = $self->get_patron_and_library();  # do error checking!

    my $rows_affected;
    $rows_affected = $self->dbh->do(
	"UPDATE patrons SET last_login=NOW() WHERE pid=?",
	undef,
	$pid,
	);
}

#--------------------------------------------------------------------------------
#
#
sub show_logged_out_process {
    # The application object
    my $self = shift;

    my $template = $self->load_tmpl(	    
	'public/logged_out.tmpl',
	cache => 1,
	);
    $template->param( pagetitle => 'fILL Logged Out',
		      username => "Logged out. ",
		      barcode => '',
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
		      barcode => $self->session->param("fILL-card"),
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
sub get_patron_and_library {
    my $self = shift;

    #$self->log->debug("get patron and library\n");

    # Get this user's library id
    my $hr_id;
    if ($self->session->param('fILL-pid') 
	 && $self->session->param('fILL-oid') 
	 && $self->session->param('fILL-library') 
	 && $self->session->param('fILL-is_enabled')
	) {
	
	my %patron = (
	    'pid' => $self->session->param('fILL-pid'),
	    'home_library_id' => $self->session->param('fILL-oid'),
	    'library' => $self->session->param('fILL-library'),
	    'is_enabled' => $self->session->param('fILL-is_enabled'),
	    );
	$hr_id = \%patron;
	
    } else {

	if ($self->session->param('fILL-card')) {
	    #$self->log->debug("session param fILL-card exists: " . $self->session->param('fILL-card') . "\n");
	    
	    # The session parameter 'fILL-card' will be set if this is an externally 
	    # authenticated  user; Patron name is not stored in the database.
	    $hr_id = $self->dbh->selectrow_hashref(
		"select p.pid, p.home_library_id, o.org_name, p.is_enabled from patrons p left join org o on (p.home_library_id = o.oid) where p.card=?",
		undef,
		$self->session->param('fILL-card')
		);
	} else {
	    #$self->log->debug("session param fILL-card DOES NOT exist\n");
	    $hr_id = $self->dbh->selectrow_hashref(
		"select p.pid, p.home_library_id, o.org_name, p.is_enabled from patrons p left join org o on (p.home_library_id = o.oid) where p.username=?",
		undef,
		$self->authen->username
		);
	}

	# set the session parameters so we don't have to hit the database again
	$self->session->param('fILL-pid',$hr_id->{pid}); 
	$self->session->param('fILL-oid',$hr_id->{home_library_id}); 
	$self->session->param('fILL-library',$hr_id->{org_name}); 
	$self->session->param('fILL-is_enabled',$hr_id->{is_enabled});
    }
    #$self->log->debug( Dumper( $hr_id ) );
    return ($hr_id->{pid}, $hr_id->{home_library_id}, $hr_id->{org_name}, $hr_id->{is_enabled});

}

#--------------------------------------------------------------------------------
# This is what RENDER_LOGIN uses to get the html login form.
#
sub login_foo {
    my $self = shift;

    my $loginText_href;
# Hmm.  User not logged in yet, so no session params...
#    my $oid = $self->session->param('fILL-oid');
# How about cookies?
    my $oid = $self->query->cookie('fILL-oid');
    if ($oid) {
	# is this a SIP2 library?
	my $lib_href = $self->dbh->selectrow_hashref("select patron_authentication_method from org where oid=?", undef, $oid);

	if ($lib_href->{patron_authentication_method} eq 'sip2') {
	    $loginText_href = $self->dbh->selectrow_hashref("select login_text, barcode_label_text, pin_label_text from library_sip2 where oid=?", undef, $oid);
	    
	} else {
	    $loginText_href = $self->dbh->selectrow_hashref("select login_text, barcode_label_text, pin_label_text from library_nonsip2 where oid=?", undef, $oid);
	}
    } else {
	$loginText_href = { 
	    "login_text" => "Log in using your library barcode and PIN",
	    "barcode_label_text" => "Library card number",
	    "pin_label_text" => "PIN number"
	};
    }

    my $lang = $self->determine_language_to_use();

    my $screenmessage = $self->session->param('fILL-auth-screenmessage');
    $self->session_delete; # toast any old session info
    my $template = $self->load_tmpl('public/login.tmpl');
    $template->param( 
	lang => $lang,
	pagetitle => 'fILL public login',
	template => 'public/login.tmpl',
	login_text => $loginText_href->{"login_text"},
	barcode_label_text => $loginText_href->{"barcode_label_text"},
	pin_label_text => $loginText_href->{"pin_label_text"},
	screenmessage => $screenmessage,
	);
    return $template->output;
}

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

#--------------------------------------------------------------------------------
#
# A requested language (from the url, language=??) overrides a preferred-
# language cookie (and changes to cookie to match).
# Default to English if no requested/preferred language.
#
sub determine_language_to_use {
    my $self = shift;
    my $q = $self->query;

    my $requestedLanguage;
    my $parmLanguage = $q->param("language");
    if (($parmLanguage) && ($parmLanguage =~ /^(en|fr)$/)) {
	$requestedLanguage = $parmLanguage;
    }
    
    my $preferredLanguage;
    my $cookieLanguage = $q->cookie('fILL-language');
    if (($cookieLanguage) && ($cookieLanguage =~ /^(en|fr)$/)) {
	$preferredLanguage = $cookieLanguage;
    }

    my $lang = $requestedLanguage || $preferredLanguage || "en";

    # set cookie client-side
    if ($requestedLanguage) {
	$self->header_props(
	    -cookie  =>  $q->cookie(
		 -expires =>  '+1y',
		 -name    =>  'fILL-language',
		 -path    =>  '/',
		 -value   =>  $lang
	    ),
	    );
    }
    
    return $lang;
}


1; # so the 'require' or 'use' succeeds
