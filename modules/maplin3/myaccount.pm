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

package maplin3::myaccount;
use strict;
use base 'maplin3base';
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
	'myaccount_settings_form'    => 'myaccount_settings_process',
	'myaccount_library_barcodes_form' => 'myaccount_library_barcodes_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub myaccount_settings_process {
    my $self = shift;
    my $q = $self->query;

    my $SQL_getUser = "SELECT lid, name, password, email_address, library, mailing_address_line1, mailing_address_line2, mailing_address_line3 FROM libraries WHERE name=?";

    my $status;
    my @searchprefs;

    # Get any parameter data (ie - user is submitting a change)
    my $lid = $q->param("lid");
    my $name = $q->param("name");
    my $password = $q->param("password");
    my $email_address = $q->param("email_address");
    my $library = $q->param("library");
    my $mailing_address_line1 = $q->param("mailing_address_line1");
    my $mailing_address_line2 = $q->param("mailing_address_line2");
    my $mailing_address_line3 = $q->param("mailing_address_line3");

    # If the user has clicked the 'update' button, $lid will be defined
    # (the user is submitting a change)
    if (defined $lid) {

	$self->log->debug("MyAccount:Settings: Updating lid [$lid], name [$name]");

	$self->dbh->do("UPDATE libraries SET name=?, password=?, email_address=?, library=?, mailing_address_line1=?, mailing_address_line2=?, mailing_address_line3=? WHERE lid=?",
		       undef,
		       $name,
		       $password,
		       $email_address,
		       $library,
		       $mailing_address_line1,
		       $mailing_address_line2,
		       $mailing_address_line3,
		       $lid
	    );

	$status = "Updated.";
#	$self->_set_header_to_get_fresh_page();

    }

    # Get the form data
    my $href = $self->dbh->selectrow_hashref(
	$SQL_getUser,
	{},
	$self->authen->username,
	);
    $self->log->debug("MyAccount:Settings: Edit user lid:$href->{lid}, name:$href->{name}, library:$href->{library}");

    $status = "Editing in process." unless $status;

    my $template = $self->load_tmpl('myaccount/settings.tmpl');
    $template->param(pagetitle => "Maplin-4 MyAccount Settings",
		     username     => $self->authen->username,
	             status       => $status,
		     editLID      => $href->{lid},
		     editName     => $href->{name},
		     editPassword => $href->{password},
		     editEmail    => $href->{email_address},
		     editLibrary  => $href->{library},
		     editMailingAddressLine1 => $href->{mailing_address_line1},
		     editMailingAddressLine2 => $href->{mailing_address_line2},
		     editMailingAddressLine3 => $href->{mailing_address_line3},
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub myaccount_library_barcodes_process {
    my $self = shift;
    my $q = $self->query;

    my $lid = get_lid_from_symbol($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('myaccount/library-barcodes.tmpl');	
    $template->param( pagetitle => $self->authen->username . " barcodes from ILS",
		      username => $self->authen->username,
		      lid => $lid,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------------------
sub get_lid_from_symbol {
    my $self = shift;
    my $symbol = shift;
    # Get this user's (requester's) library id
    my $hr_id = $self->dbh->selectrow_hashref(
	"SELECT lid FROM libraries WHERE name=?",
	undef,
	$symbol
	);
    my $requester = $hr_id->{lid};
    return $requester;
}


1; # so the 'require' or 'use' succeeds

#		     atstart => $href->{'atstart'},
