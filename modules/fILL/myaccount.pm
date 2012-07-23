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

package fILL::myaccount;
use strict;
use base 'fILLbase';
use Data::Dumper;

#--------------------------------------------------------------------------------
# Define our runmodes
#
sub setup {
    my $self = shift;
    $self->start_mode('myaccount_settings_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'myaccount_settings_form'         => 'myaccount_settings_process',
	'myaccount_library_barcodes_form' => 'myaccount_library_barcodes_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub myaccount_settings_process {
    my $self = shift;
    my $q = $self->query;

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!
    $self->log->debug("username: " . $self->authen->username);
    $self->log->debug("lid: $lid, library: $library");
    my $status;
    my @searchprefs;

    # If the user has clicked the 'update' button, $q->param("lid") will be defined
    # (the user is submitting a change)
    if (defined $q->param("lid")) {

	$self->log->debug("MyAccount:Settings: User " . $self->authen->username . " updating lid [$lid], library [" . $q->param("library") . "]");

	$self->dbh->do("UPDATE libraries SET email_address=?, library=?, mailing_address_line1=?, city=?, province=?, post_code=?, request_email_notification=? WHERE lid=?",
		       undef,
		       $q->param("email_address"),
		       $q->param("library"),
		       $q->param("mailing_address_line1"),
		       $q->param("city"),
		       $q->param("province"),
		       $q->param("post_code"),
		       $q->param("request_email_notification"),
		       $lid
	    );

	$status = "Updated.";
#	$self->_set_header_to_get_fresh_page();

    }

    # Get the form data
    my $SQL_getLibrary = "SELECT lid, name, password, email_address, library, mailing_address_line1, city, province, post_code, request_email_notification FROM libraries WHERE lid=?";
    my $href = $self->dbh->selectrow_hashref(
	$SQL_getLibrary,
	{},
	$lid,
	);
    $self->log->debug("MyAccount:Settings: Edit user lid:$href->{lid}, username:" . $self->authen->username .  ", library:$href->{library}");

    $status = "Editing in process." unless $status;

    my $template = $self->load_tmpl('myaccount/settings.tmpl');
    $template->param(pagetitle => "fILL MyAccount Settings",
		     username     => $self->authen->username,
		     lid          => $lid,
		     library      => $library,
	             status       => $status,
		     editLID      => $href->{lid},
		     editEmail    => $href->{email_address},
		     editLibrary  => $href->{library},
		     editMailingAddressLine1 => $href->{mailing_address_line1},
		     editCity     => $href->{city},
		     editProvince => $href->{province},
		     editPostalCode => $href->{post_code},
		     editRequestEmailNotification => $href->{request_email_notification},
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub myaccount_library_barcodes_process {
    my $self = shift;
    my $q = $self->query;

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('myaccount/library-barcodes.tmpl');	
    $template->param( pagetitle => $self->authen->username . " barcodes from ILS",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
	);
    return $template->output;
    
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
