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
    $self->stream_file( "/opt/maplin3/restricted_docs/$docname",2048);
    
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

