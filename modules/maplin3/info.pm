#
#    fILL - Free/Open-Source Interlibrary Loan management system
#    Copyright (C) 2011  David A. Christensen
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

package maplin3::info;
use strict;
use base 'maplin3base';
use CGI::Application::Plugin::Stream (qw/stream_file/);
use ZOOM;
use Net::Ping;

#--------------------------------------------------------------------------------
# Define our runmodes
#
sub setup {
    my $self = shift;
    $self->start_mode('info_contacts_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'info_contacts_form'   => 'info_contacts_process',
	'info_documents_form'  => 'info_documents_process',
	'info_feeds_form'      => 'info_feeds_process',
	'send_pdf'             => 'send_pdf',
	);
}

#--------------------------------------------------------------------------------
#
#
sub info_contacts_process {
    my $self = shift;
    my $q = $self->query;

    my $SQL_getUser = "SELECT name, email_address, library, mailing_address_line1, mailing_address_line2, mailing_address_line3 from libraries WHERE active=1 ORDER BY library";

    # Get any parameter data (ie - user is submitting a change)
    my $sort = $q->param("sort");

    # Get the form data
    my $aref = $self->dbh->selectall_arrayref(
	$SQL_getUser,
	{ Slice => {} }
	);
    
    my $template = $self->load_tmpl('info/contacts.tmpl');
    $template->param(pagetitle => "Maplin-4 Info Contacts",
		     username  => $self->authen->username,
		     libraries => $aref);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub info_documents_process {
    my $self = shift;

    my $template = $self->load_tmpl('info/documents.tmpl');
    $template->param(pagetitle => "Maplin-4 Info Documents",
		     username => $self->authen->username);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub info_feeds_process {
    my $self = shift;

    my $template = $self->load_tmpl('info/feeds.tmpl');
    $template->param(pagetitle => "Maplin-4 Info Feeds",
		     username => $self->authen->username);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub send_pdf {
    my $self = shift;
    my $q = $self->query;

    my $docname = $q->param("doc");
    $self->header_add( -attachment => $docname );    
    $self->stream_file( "/opt/fILL/restricted_docs/$docname",2048);
    
#    $self->header_type('none'); # let's you set your own headers
#    $self->header_props(
#	-content-type         => 'application/pdf',
#	-content-disposition  => "inline; filename=$docname"
#  );
#
#  return "Download $docname";

    return;
} 


1; # so the 'require' or 'use' succeeds

