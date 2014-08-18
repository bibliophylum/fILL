#    fILL - Free/Open-Source Interlibrary Loan management system
#    Copyright (C) 2012  Government of Manitoba
#
#    lightning.pm is part of fILL.
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

package fILL::public;
use warnings;
use strict;
use base 'publicbase';
use GD::Barcode;
use GD::Barcode::Code39;
use MIME::Base64;
use Clone qw(clone);
use Encode;
use Text::Unidecode;
use Data::Dumper;
#use Fcntl qw(LOCK_EX LOCK_NB);

my %SPRUCE_TO_MAPLIN = (
    'MWPL' => 'MWPL',
    'MAOW' => 'MAOW',        # Altona
    'MMIOW' => 'MMIOW',      # Miami
    'MMOW' => 'MMOW',        # Morden
    'MWOW' => 'MWOW',        # Winkler
    'BOISSEVAIN' => 'MBOM',
    'MANITOU' => 'MMA',
    'STEROSE' => 'MSTR',
    'AB' => 'MWP',
    'MWP' => 'MWP',
    'MSTOS' => 'MSTOS',      # Stonewall
    'MTSIR' => 'MTSIR',      # Teulon
    'MMCA' => 'MMCA',        # McAuley
    'MVE' => 'MVE',          # Virden
    'ME' => 'ME',            # Elkhorn
    'MS' => 'MS',            # Somerset
    'MSOG' => 'MSOG',        # Glenwood and Souris
    'MDB' => 'MDB',          # Bren Del Win
    'MPLP' => 'MPLP',        # Portage
    'MSSC' => 'MSSC',        # Shilo
    'MEC' => 'MEC',
    'MNH' => 'MNH',
    'MSRH' => 'UCN',         # University College of the North
    'MTK' => 'MTK',          #   libraries and campuses
    'MTPK' => 'MTPK',
    'MWMW' => 'UCN',
    'MRD' => 'MRD',          # Russell
    'MBI' => 'MBI',          # Binscarth
    'MSCL' => 'MSCL',        # St.Claude
    );

my %WESTERN_MB_TO_MAPLIN = (
    'Brandon Public Library' => 'MBW',
    'Neepawa Public Library' => 'MNW',
    'Carberry / North Cypress Library' => 'MCNC',
    'Glenboro / South Cypress Library' => 'MGW',
    'Hartney / Cameron Library' => 'MHW',
    );

#--------------------------------------------------------------------------------
# Define our runmodes
#
sub setup {
    my $self = shift;
    $self->start_mode('search_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'search_form'              => 'search_process',
	'registration_form'        => 'registration_process',
	'myaccount_form'           => 'myaccount_process',
	'current_form'             => 'current_process',
	'about_form'               => 'about_process',
	'faq_form'				   => 'faq_process',
	'contact_form'             => 'contact_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub search_process {
    my $self = shift;
    my $q = $self->query;

    my $query = $q->param("query") || '';
    $self->log->debug( "search_process parm:\n" . Dumper($query) );

    my ($pid,$lid,$library,$is_enabled) = get_patron_from_username($self, $self->authen->username);  # do error checking!

    my $template;
    if ($is_enabled) {
	$template = $self->load_tmpl('public/search.tmpl');
    } else {
	$template = $self->load_tmpl('public/not-enabled.tmpl');
    }
    $template->param( pagetitle => "fILL Public Search",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
		      query => $query,
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub myaccount_process {
    my $self = shift;
    my $q = $self->query;

    my ($pid,$lid,$library,$is_enabled) = get_patron_from_username($self, $self->authen->username);  # do error checking!

    my $SQL = "select pid, name, card, username, is_enabled from patrons where home_library_id=? and pid=?";
    my $href = $self->dbh->selectrow_hashref( $SQL, { Slice => {} }, $lid, $pid );

    my $template = $self->load_tmpl('public/myaccount.tmpl');	
    $template->param( pagetitle => "fILL patron account",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
		      pid => $pid,
		      name => $href->{name},
		      is_enabled => ($href->{is_enabled} ? "Active" : "Disabled by your library")
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub current_process {
    my $self = shift;
    my $q = $self->query;

    my ($pid,$lid,$library,$is_enabled) = get_patron_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('public/current.tmpl');	
    $template->param( pagetitle => "Current interlibrary loans",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
		      pid => $pid
	);
    return $template->output;
    
}


#--------------------------------------------------------------------------------
#
#
sub about_process {
    my $self = shift;
    my $q = $self->query;

    my ($pid,$lid,$library,$is_enabled) = get_patron_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('public/about.tmpl');	
    $template->param( pagetitle => "About fILL",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
#		      pid => $pid
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub faq_process {
    my $self = shift;
    my $q = $self->query;

    my ($pid,$lid,$library,$is_enabled) = get_patron_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('public/faq.tmpl');	
    $template->param( pagetitle => "FAQ fILL",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
#		      pid => $pid
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub contact_process {
    my $self = shift;
    my $q = $self->query;

    my ($pid,$lid,$library,$is_enabled) = get_patron_from_username($self, $self->authen->username);  # do error checking!

    my $hr_lib = $self->dbh->selectrow_hashref(
	"select library, email_address, mailing_address_line1, mailing_address_line2, mailing_address_line3, city, province, post_code, phone from libraries where lid=?",
	undef,
	$lid
	);
    
    my $template = $self->load_tmpl('public/contact.tmpl');	
    $template->param( pagetitle => "Contact",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
		      email_address => $hr_lib->{email_address},
		      mailing_address_line1 => $hr_lib->{mailing_address_line1},
		      mailing_address_line2 => $hr_lib->{mailing_address_line2},
		      mailing_address_line3 => $hr_lib->{mailing_address_line3},
		      city => $hr_lib->{city},
		      province => $hr_lib->{province},
		      post_code => $hr_lib->{post_code},
		      phone => $hr_lib->{phone}
#		      pid => $pid
	);
    return $template->output;
}


#----------------------------------------------------------------------------------------
sub get_patron_from_username {
    my $self = shift;
    my $username = shift;
    # Get this user's library id
    my $hr_id = $self->dbh->selectrow_hashref(
	"select p.pid, p.home_library_id, l.library, p.is_enabled from patrons p left join libraries l on (l.lid = p.home_library_id) where p.username=?",
	undef,
	$username
	);
    return ($hr_id->{pid}, $hr_id->{home_library_id}, $hr_id->{library}, $hr_id->{is_enabled});
}

#--------------------------------------------------------------------------------
#
# Patron self-registration
#
sub registration_process {
    my $self = shift;
    my $template = $self->load_tmpl('public/registration.tmpl');
    return $template->output;
}


#--------------------------------------------------------------------------------
#
# Patron self-registration
#
sub registration_process_DEPRECATED {
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
#    $template->param(USERNAME => 'Not yet registered.',
    $template->param(ASK_REGION => defined($region) ? 0 : 1,
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


1; # so the 'require' or 'use' succeeds
