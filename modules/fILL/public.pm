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
use JSON;
use CGI::Cookie;

#--------------------------------------------------------------------------------
# Define our runmodes
#
sub setup {
    my $self = shift;
    $self->start_mode('search_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'test_form'                => 'test_process',
	'search_form'              => 'search_process',
	'registration_form'        => 'registration_process',
	'myaccount_form'           => 'myaccount_process',
	'current_form'             => 'current_process',
	'about_form'               => 'about_process',
	'help_form'                => 'help_process',	
	'faq_form'		   => 'faq_process',
	'contact_form'             => 'contact_process',
	);
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


#--------------------------------------------------------------------------------
#
#
sub test_process {
    my $self = shift;
    my $q = $self->query;

    my ($pid,$oid,$library,$is_enabled) = $self->get_patron_and_library();  # do error checking!
    my $lang = $self->determine_language_to_use();

    my $template;
    $template = $self->load_tmpl('public/test2.tmpl');
    $template->param( lang => $lang,
		      pagetitle => "fILL test",
		      template => 'public/test.tmpl',
		      username => $self->authen->username,
		      barcode => $self->session->param("fILL-card"),
		      oid => $oid,
		      library => $library,
	);

    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub search_process {
    my $self = shift;
    my $q = $self->query;

    $self->log->debug("in search_process\n");

    # pull the form's parameter named "query", so we can stuff it into the search template
    # (so the search page can automatically do the search)
    my $query = $q->param("query") || '';
    $self->log->debug( "search_process parm:\n" . Dumper($query) );

    my ($pid,$oid,$library,$is_enabled) = $self->get_patron_and_library();  # do error checking!

    my $template;
    if ($is_enabled) {
	$template = $self->load_tmpl('public/search.tmpl');
    } else {
	$template = $self->load_tmpl('public/not-enabled.tmpl');
    }
    $template->param( pagetitle => "fILL Public Search",
		      username => $self->authen->username,
		      barcode => $self->session->param("fILL-card"),
		      oid => $oid,
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

    my ($pid,$oid,$library,$is_enabled) = $self->get_patron_and_library();  # do error checking!

    my $SQL = "select pid, name, card, username, is_enabled from patrons where home_library_id=? and pid=?";
    my $href = $self->dbh->selectrow_hashref( $SQL, { Slice => {} }, $oid, $pid );

    my $template = $self->load_tmpl('public/myaccount.tmpl');	
    $template->param( pagetitle => "fILL patron account",
		      username => $self->authen->username,
		      barcode => $self->session->param("fILL-card"),
		      oid => $oid,
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

    my ($pid,$oid,$library,$is_enabled) = $self->get_patron_and_library();  # do error checking!

    my $template = $self->load_tmpl('public/current.tmpl');	
    $template->param( pagetitle => "Current interlibrary loans",
		      username => $self->authen->username,
		      barcode => $self->session->param("fILL-card"),
		      oid => $oid,
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

    my ($pid,$oid,$library,$is_enabled) = $self->get_patron_and_library();  # do error checking!
    my $lang = $self->determine_language_to_use();

    my $template;
    $template = $self->load_tmpl('public/about.tmpl');
    $template->param( lang => $lang,
		      pagetitle => 'About fILL',
		      template => 'public/about.tmpl',
		      username => $self->authen->username,
		      barcode => $self->session->param("fILL-card"),
		      oid => $oid,
		      library => $library,
	);

    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub help_process {
    my $self = shift;
    my $q = $self->query;

    my ($pid,$oid,$library,$is_enabled) = $self->get_patron_and_library();  # do error checking!

    my $template = $self->load_tmpl('public/help.tmpl');	
    $template->param( pagetitle => "Help fILL",
		      username => $self->authen->username,
		      barcode => $self->session->param("fILL-card"),
		      oid => $oid,
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

    my ($pid,$oid,$library,$is_enabled) = $self->get_patron_and_library();  # do error checking!

    my $template = $self->load_tmpl('public/faq.tmpl');	
    $template->param( pagetitle => "FAQ fILL",
		      username => $self->authen->username,
		      barcode => $self->session->param("fILL-card"),
		      oid => $oid,
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

    my ($pid,$oid,$library,$is_enabled) = $self->get_patron_and_library();  # do error checking!

    my $hr_lib = $self->dbh->selectrow_hashref(
	"select org_name, email_address, website, mailing_address_line1, mailing_address_line2, mailing_address_line3, city, province, post_code, phone, symbol from org where oid=?",
	undef,
	$oid
	);

    my $logoPath = "/img/fill-contact.jpg";
    my $logoAltText = "Child sitting on the floor of a book store, engrossed in reading";
    my $logoCredit = '<a href="https://www.flickr.com/photos/48439369@N00/2100913578">Tim Pierce</a>';
    if (-f "/opt/fILL/htdocs/img/logos/" . $hr_lib->{symbol} . ".png") {
	$logoPath = "/img/logos/" . $hr_lib->{symbol} . ".png";
	$logoAltText = $hr_lib->{org_name} . " logo";
	$logoCredit = $hr_lib->{org_name} . ". Used with permission.";
    }
    $self->log->debug( "contact logo:\n" . Dumper($hr_lib) . "\npath: $logoPath\nalt: $logoAltText\ncredit: $logoCredit\n" );
    
    my $template = $self->load_tmpl('public/contact.tmpl');	
    $template->param( pagetitle => "Contact",
		      username => $self->authen->username,
		      barcode => $self->session->param("fILL-card"),
		      oid => $oid,
		      library => $library,
		      email_address => $hr_lib->{email_address},
		      website => $hr_lib->{website},
		      mailing_address_line1 => $hr_lib->{mailing_address_line1},
		      mailing_address_line2 => $hr_lib->{mailing_address_line2},
#		      mailing_address_line3 => $hr_lib->{mailing_address_line3},   # redundant; info is in city/province/post_code.  Removed from template.
		      city => $hr_lib->{city},
		      province => $hr_lib->{province},
		      post_code => $hr_lib->{post_code},
		      phone => $hr_lib->{phone},
		      logo_path => $logoPath,
		      logo_alt_text => $logoAltText,
		      logo_credit => $logoCredit
#		      pid => $pid
	);
    return $template->output;
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


1; # so the 'require' or 'use' succeeds
