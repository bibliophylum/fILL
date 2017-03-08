#
#    fILL - Free/Open-Source Interlibrary Loan management system
#    Copyright (C) 2012  Government of Manitoba
#
#    discovery_only_base.pm is a part of fILL.
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

package discovery_only_base;
use strict;
use base 'CGI::Application';
use utf8;
use CGI::Application::Plugin::DBH (qw/dbh_config dbh/);
use CGI::Application::Plugin::Session;
use CGI::Application::Plugin::LogDispatch;
use Digest::SHA;  # (k)ubuntu 12.04 replaces libdigest-sha1-perl with libdigest-sha-perl
use Data::Dumper;
use JSON;

# Setup for UTF-8 mode.
binmode STDOUT, ":utf8:";
$ENV{'PERL_UNICODE'}=1;

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

    $self->dbh->{pg_enable_utf8} = -1;  # *every* string coming back from Pg has 
                                        # utf-8 flag set (db encoding is UTF-8)

    $self->dbh->do("SET client_encoding = 'UTF8'");
    $self->dbh->do("SET TIMEZONE='America/Winnipeg'");

    # Configure the LogDispatch session
    $self->log_config(
      LOG_DISPATCH_MODULES => [ 
        {    module => 'Log::Dispatch::File',
               name => 'messages',
           filename => '/opt/fILL/logs/messages-discovery-only.log',
          min_level => 'debug'
        },
      ],
      APPEND_NEWLINE => 1,
    );

    # common runmodes
    $self->run_modes(
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
sub environment_process {
    my $self = shift;

    my $template = $self->load_tmpl('public/environment.tmpl');
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
