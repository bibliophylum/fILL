package fILL::rotations_admin;
use strict;
use base 'fILLbase';
use GD::Barcode;
use GD::Barcode::Code39;
use MIME::Base64;
use Data::Dumper;


#--------------------------------------------------------------------------------
# Define our runmodes
#
sub setup {
    my $self = shift;
    $self->start_mode('report_received_cnt');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'report_received_cnt' => 'report_received_cnt_process',
	'report_item_circs'   => 'report_item_circs_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub report_received_cnt_process {
    my $self = shift;
    my $q = $self->query;

    my ($lid,$symbol,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('rotations/admin/reports/received_counts.tmpl');	
    $template->param( pagetitle => "Rotations - report on received counts",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub report_item_circs_process {
    my $self = shift;
    my $q = $self->query;

    my ($lid,$symbol,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('rotations/admin/reports/item_circ_counts.tmpl');	
    $template->param( pagetitle => "Rotations - report on item circ counts",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
	);
    return $template->output;
    
}

#-------------------------------------------------------------------------------------------
sub get_library_from_username {
    my $self = shift;
    my $username = shift;
    # Get this user's library id
    my $hr_id = $self->dbh->selectrow_hashref(
	"select l.lid, l.name, l.library from users u left join libraries l on (u.lid = l.lid) where u.username=?",
	undef,
	$username
	);
    return ($hr_id->{lid}, $hr_id->{name}, $hr_id->{library});
}

1; # so the 'require' or 'use' succeeds
