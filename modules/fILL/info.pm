#
#    fILL - Free/Open-Source Interlibrary Loan management system
#    Copyright (C) 2011  Government of Manitoba
#
#    info.pm is a part of fILL.
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

package fILL::info;
use strict;
use base 'fILLbase';
use CGI::Application::Plugin::Stream (qw/stream_file/);

#--------------------------------------------------------------------------------
# Define our runmodes
#
sub setup {
    my $self = shift;
    $self->start_mode('info_contacts_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'info_contacts_form'      => 'info_contacts_process',
	'info_documents_form'     => 'info_documents_process',
	'info_reports_form'       => 'info_reports_process',
	'info_report-folder_form' => 'info_reportfolder_process',
	'info_feeds_form'         => 'info_feeds_process',
	'send_pdf'                => 'send_pdf',
	'send_report_output'      => 'send_report_output',
	);
}

#--------------------------------------------------------------------------------
#
#
sub info_contacts_process {
    my $self = shift;
    my $q = $self->query;

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $SQL_getLibrary = "SELECT name, phone, email_address, library, mailing_address_line1, mailing_address_line2, mailing_address_line3 from libraries WHERE active=1 ORDER BY library";

    # Get any parameter data (ie - user is submitting a change)
    my $sort = $q->param("sort");

    # Get the form data
    my $aref = $self->dbh->selectall_arrayref(
	$SQL_getLibrary,
	{ Slice => {} }
	);
    
    my $template = $self->load_tmpl('info/contacts.tmpl');
    $template->param(pagetitle => "fILL Info Contacts",
		     username  => $self->authen->username,
		     lid       => $lid,
		     library   => $library,
		     libraries => $aref);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub info_documents_process {
    my $self = shift;

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('info/documents.tmpl');
    $template->param(pagetitle => "fILL Info Documents",
		     username => $self->authen->username,
	             lid => $lid,
		     library => $library,
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub info_reports_process {
    my $self = shift;

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('info/reports.tmpl');
    $template->param(pagetitle => "fILL Info Reports",
		     username => $self->authen->username,
	             lid => $lid,
		     library => $library,
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub info_reportfolder_process {
    my $self = shift;

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('info/report-folder.tmpl');
    $template->param(pagetitle => "fILL Info Reports-folder",
		     username => $self->authen->username,
	             lid => $lid,
		     library => $library,
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub info_feeds_process {
    my $self = shift;

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('info/feeds.tmpl');
    $template->param(pagetitle => "fILL Info Feeds",
		     username => $self->authen->username,
	             lid => $lid,
		     library => $library,
	);
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

#--------------------------------------------------------------------------------
#
#
sub send_report_output {
    my $self = shift;
    my $q = $self->query;

    my $docname = $q->param("doc");
    $self->header_add( -attachment => $docname );    
    $self->stream_file( "/opt/fILL/report-output/$docname",2048);
    
    return;
} 

#--------------------------------------------------------------------------------------------
sub get_library_from_username {
    my $self = shift;
    my $username = shift;
    # Get this user's library id
    my $hr_id = $self->dbh->selectrow_hashref(
	"select l.lid, l.library from users u left join libraries l on (u.lid = l.lid) where u.username=?",
	undef,
	$username
	);
    return ($hr_id->{lid}, $hr_id->{library});
}


1; # so the 'require' or 'use' succeeds

