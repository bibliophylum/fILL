#
#    fILL - Free/Open-Source Interlibrary Loan management system
#    Copyright (C) 2011  Government of Manitoba
#
#    training.pm is a part of fILL.
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

package fILL::training;
use strict;
use base 'fILLbase';
use CGI::Application::Plugin::Stream (qw/stream_file/);
use Data::Dumper;
#use fILL::stats;
#use fILL::charts;

#--------------------------------------------------------------------------------
# Define our runmodes
#
sub setup {
    my $self = shift;
    $self->start_mode('training_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'training_form'           => 'training_process',
	'training_docs_form'      => 'training_docs_process',
	'training_vids_form'      => 'training_vids_process',
	'send_pdf'                => 'send_pdf',
	);
}

#--------------------------------------------------------------------------------
#
#
sub training_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('training/training.tmpl');
    $template->param(pagetitle => "fILL training",
		     username  => $self->authen->username,
		     oid       => $oid,
#		     library   => $library,
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub training_docs_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('training/docs.tmpl');
    $template->param(pagetitle => "fILL training documents",
		     username  => $self->authen->username,
		     oid       => $oid,
#		     library   => $library,
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub training_vids_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('training/vids.tmpl');
    $template->param(pagetitle => "fILL training videos",
		     username  => $self->authen->username,
		     oid       => $oid,
#		     library   => $library,
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


#----------------------------------------------------------------------------------
sub get_library_from_username {
    my $self = shift;
    my $username = shift;
    # Get this user's library id
    my $hr_id = $self->dbh->selectrow_hashref(
	"select o.oid, o.org_name from users u left join org o on (u.oid = o.oid) where u.username=?",
	undef,
	$username
	);
    return ($hr_id->{oid}, $hr_id->{org_name});
}


1; # so the 'require' or 'use' succeeds

