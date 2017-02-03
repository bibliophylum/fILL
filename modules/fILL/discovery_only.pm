#    fILL - Free/Open-Source Interlibrary Loan management system
#    Copyright (C) 2012  Government of Manitoba
#
#    discovery_only.pm is part of fILL.
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

package fILL::discovery_only;
use warnings;
use strict;
use base 'discovery_only_base';
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
    $self->start_mode('discovery_only_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'discovery_only_form'         => 'discovery_only_process',
	'about_form'                  => 'about_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub discovery_only_process {
    my $self = shift;
    my $q = $self->query;

    #$self->log->debug("in discovery_only_process\n");

    # pull the form's parameter named "query", so we can stuff it into the search template
    # (so the search page can automatically do the search)
    my $query = $q->param("query") || '';

    my $lang = $self->determine_language_to_use();

    my $template;
    my $templateFile = 'discovery/discovery-only.tmpl';
    $template = $self->load_tmpl( $templateFile );
    $template->param( lang => $lang,
		      pagetitle => "fILL Discovery",
		      template => $templateFile,
		      query => $query,
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub about_process {
    my $self = shift;
    my $q = $self->query;

    my $lang = $self->determine_language_to_use();

    my $template;
    $template = $self->load_tmpl('discovery/about.tmpl');
    $template->param( lang => $lang,
		      pagetitle => 'About fILL',
		      template => 'discovery/about.tmpl',
	);

    return $template->output;
}



1; # so the 'require' or 'use' succeeds
