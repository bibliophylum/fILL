#
#    fILL - Free/Open-Source Interlibrary Loan management system
#    Copyright (C) 2012   Government of Manitoba
#
#    myaccount.pm is a part of fILL.
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
	'myaccount_test_zserver_form'     => 'myaccount_test_zserver_process',
	'myaccount_acquisitions_form'     => 'myaccount_acquisitions_process',
	'myaccount_patrons_form'          => 'myaccount_patrons_process',	
	);
}



#--------------------------------------------------------------------------------
#
#
sub myaccount_settings_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$symbol,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!
    my $SQL = "SELECT o.oid, o.symbol, o.email_address, o.website, o.org_name, o.mailing_address_line1, o.city, o.province, o.post_code, o.slips_with_barcodes, o.centralized_ill, o.patron_authentication_method, o.lender_internal_notes_enabled, z.server_address, z.server_port, z.database_name, z.enabled, tp.barcode, tp.pin, tp.last_tested, tp.test_result FROM org o left join library_z3950 z on z.oid=o.oid left join library_test_patron tp on tp.oid = o.oid WHERE o.oid=?";
    my $href = $self->dbh->selectrow_hashref($SQL,{},$oid);

    my $zServer_controlled_by_parent = 0;
    my $parent_href;
    my $siblings_aoh = [];
    if (not defined $href->{server_address}) {
	$zServer_controlled_by_parent = 1;
	my @parent_oid = $self->dbh->selectrow_array("select oid from org_members where member_id=?",undef,$oid);
	if (@parent_oid) {
	    $parent_href = $self->dbh->selectrow_hashref("select o.org_name, o.symbol, z.server_address, z.server_port, z.database_name from org o left join library_z3950 z on z.oid=o.oid where o.oid=?", {}, $parent_oid[0]);
	    $siblings_aoh = $self->dbh->selectall_arrayref("select org_name from org where oid in (select member_id from org_members where oid=?)", { Slice => {} }, $parent_oid[0]);
	    #$self->log->debug("siblings:\n" . Dumper($siblings_aoh) . "\n");
	}
    }

    my $logoPath = "/img/fill-contact.jpg";
    my $logoAltText = "Child sitting on the floor of a book store, engrossed in reading";
    my $logoCredit = '<a href="https://www.flickr.com/photos/48439369@N00/2100913578">Tim Pierce</a>';
    if (-f "/opt/fILL/htdocs/img/logos/" . $href->{symbol} . ".png") {
	$logoPath = "/img/logos/" . $href->{symbol} . ".png";
	$logoAltText = $href->{"library"} . " logo";
	$logoCredit = $href->{"library"} . ". Used with permission.";
    }

    my $template = $self->load_tmpl('myaccount/settings.tmpl');
    $template->param(pagetitle     => "fILL MyAccount Settings",
		     username      => $self->authen->username,
		     oid           => $oid,
		     symbol        => $symbol,
		     library       => $href->{org_name},
		     email_address => $href->{email_address},
		     website       => $href->{website},
		     mailing_address_line1 => $href->{mailing_address_line1},
		     city          => $href->{city},
		     province      => $href->{province},
		     post_code     => $href->{post_code},
		     zserver_controlled_by_parent => $zServer_controlled_by_parent,
		     zserver_parent_orgname => $parent_href->{org_name} || ' ',
		     zserver_parent_symbol => $parent_href->{symbol} || ' ',
		     zserver_siblings => $siblings_aoh,
		     z3950_enabled => $href->{enabled},
		     z3950_server_address => $href->{server_address},
		     z3950_server_port    => $href->{server_port},
		     z3950_database_name  => $href->{database_name},
		     my_test_patron_barcode  => $href->{barcode},
		     my_test_patron_pin      => $href->{pin},
		     test_patron_auth_method => $href->{patron_authentication_method},
		     test_patron_last_tested => $href->{last_tested} || "Never.",
		     test_patron_test_result => $href->{test_result},
		     slips_with_barcodes  => $href->{slips_with_barcodes},
		     centralized_ill      => $href->{centralized_ill},
		     lender_internal_notes_enabled => $href->{lender_internal_notes_enabled},
		     logo_path     => $logoPath,
		     logo_alt_text => $logoAltText,
		     logo_credit   => $logoCredit
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub myaccount_library_barcodes_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$symbol,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('myaccount/library-barcodes.tmpl');	
    $template->param( pagetitle => $self->authen->username . " barcodes from ILS",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub myaccount_test_zserver_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$symbol,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!
    my $template = $self->load_tmpl('myaccount/test-zserver.tmpl');
    $template->param(pagetitle => "fILL MyAccount test zServer",
		     username     => $self->authen->username,
		     oid          => $oid,
		     libsym       => $symbol,
		     library      => $library,
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub myaccount_acquisitions_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$symbol,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!
    my $template = $self->load_tmpl('myaccount/acquisitions.tmpl');
    $template->param(pagetitle => "fILL acquisitions list",
		     username     => $self->authen->username,
		     oid          => $oid,
		     library      => $library,
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub myaccount_patrons_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$symbol,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('myaccount/patrons.tmpl');	
    $template->param( pagetitle => "Patrons using public fILL",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
	);
    return $template->output;
    
}

#------------------------------------------------------------------------------------
sub get_library_from_username {
    my $self = shift;
    my $username = shift;
    # Get this user's library id
    my $hr_id = $self->dbh->selectrow_hashref(
	"select o.oid, o.symbol, o.org_name from users u left join org o on (u.oid = o.oid) where u.username=?",
	undef,
	$username
	);
    return ($hr_id->{oid}, $hr_id->{symbol}, $hr_id->{org_name});
}

1; # so the 'require' or 'use' succeeds
