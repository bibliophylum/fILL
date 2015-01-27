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
	'some_admin_form'         => 'some_admin_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub some_admin_process {
    my $self = shift;
    my $q = $self->query;

    my $template = $self->load_tmpl('admin/admin.tmpl');	
    $template->param( pagetitle => "Some admin page",
		      username => $self->authen->username,
	);
    return $template->output;
    
}

1; # so the 'require' or 'use' succeeds
