#
#    fILL - Free/Open-Source Interlibrary Loan management system
#    Copyright (C) 2012   Government of Manitoba
#
#    admin.pm is a part of fILL.
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

package fILL::admin;
use strict;
use base 'adminbase';
use Data::Dumper;

#--------------------------------------------------------------------------------
# Define our runmodes
#
sub setup {
    my $self = shift;
    $self->start_mode('welcome');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'authentication'       => 'authentication_process',
	'authentication_tests' => 'authentication_tests_process',
	'spruce_ill'           => 'load_spruce_ill_numbers_process',
	'zserver_test'         => 'zserver_test_process',
	'zserver_pazpar_control' => 'zserver_pazpar_control_process',
	'zserver_settings'     => 'zserver_settings_process',
	'public_featured'      => 'public_featured_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub authentication_process {
    my $self = shift;
    my $q = $self->query;

    my $libraries_aref = $self->dbh->selectall_arrayref("select oid, org_name, case when patron_authentication_method is null then 'none' else patron_authentication_method end as auth_method from org order by org_name", { Slice => {} } );

    my $template = $self->load_tmpl('admin/authentication.tmpl');	
    $template->param( pagetitle => "Authentication methods",
		      library_list => $libraries_aref,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub authentication_tests_process {
    my $self = shift;
    my $q = $self->query;

    my $libraries_aref = $self->dbh->selectall_arrayref("select oid, org_name, case when patron_authentication_method is null then 'none' else patron_authentication_method end as auth_method from org order by org_name", { Slice => {} } );

    my $template = $self->load_tmpl('admin/authentication_tests.tmpl');	
    $template->param( pagetitle => "Authentication tests",
		      library_list => $libraries_aref,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub load_spruce_ill_numbers_process {
    my $self = shift;
    my $q = $self->query;

#    my $libraries_aref = $self->dbh->selectall_arrayref("select symbol,org_name from org order by org_name", { Slice => {} } );

    my $template = $self->load_tmpl('admin/load-untracked-ill.tmpl');	
    $template->param( pagetitle => "Admin - load untracked ILL numbers" );
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub zserver_settings_process {
    my $self = shift;
    my $q = $self->query;

# Do it this way if you want to list all libraries, whether or not they have a zServer:
#    my $libraries_aref = $self->dbh->selectall_arrayref("select o.oid,o.symbol,o.org_name,z.enabled,z.server_address,z.server_port,z.database_name,z.request_syntax,z.elements,z.nativesyntax,z.xslt,z.index_keyword,z.index_author,z.index_title,z.index_subject,z.index_isbn,z.index_issn,z.index_date,z.index_series from org o left join library_z3950 z on z.oid=o.oid order by o.org_name", { Slice => {} } );
    my $libraries_aref = $self->dbh->selectall_arrayref("select o.oid,o.symbol,o.org_name,z.enabled,z.server_address,z.server_port,z.database_name,z.request_syntax,z.elements,z.nativesyntax,z.xslt,z.index_keyword,z.index_author,z.index_title,z.index_subject,z.index_isbn,z.index_issn,z.index_date,z.index_series from library_z3950 z left join org o on z.oid=o.oid order by o.org_name", { Slice => {} } );

    my $template = $self->load_tmpl('admin/zserver-settings.tmpl');	
    $template->param( pagetitle => "zServer settings",
		      library_list => $libraries_aref
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub zserver_pazpar_control_process {
    my $self = shift;
    my $q = $self->query;

    my $libraries_aref = $self->dbh->selectall_arrayref("select symbol,org_name from org order by org_name", { Slice => {} } );

    my $template = $self->load_tmpl('admin/pazpar-control.tmpl');	
    $template->param( pagetitle => "Pazpar control",
		      library_list => $libraries_aref
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub zserver_test_process {
    my $self = shift;
    my $q = $self->query;

    my $libraries_aref = $self->dbh->selectall_arrayref("select symbol,org_name from org order by org_name", { Slice => {} } );

    my $template = $self->load_tmpl('admin/zserver-test.tmpl');	
    $template->param( pagetitle => "Test zServer",
		      library_list => $libraries_aref
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub public_featured_process {
    my $self = shift;
    my $q = $self->query;

    my $template = $self->load_tmpl('admin/public-featured.tmpl');	
    $template->param( pagetitle => "Admin - Public - Featured" );
    return $template->output;
}

1; # so the 'require' or 'use' succeeds
