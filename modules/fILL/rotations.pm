package fILL::rotations;
use strict;
use base 'fILLbase';
use Data::Dumper;


#--------------------------------------------------------------------------------
# Define our runmodes
#
sub setup {
    my $self = shift;
    $self->start_mode('receive_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'receive_form'        => 'receive_process',
	'circstats_form'      => 'circstats_process',
	'current_form'        => 'current_process',
	'holdings_setup_form' => 'holdings_setup_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub receive_process {
    my $self = shift;
    my $q = $self->query;

#    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!
    my ($lid,$symbol,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl(	    
	                      'rotations/receiving.tmpl',
			      cache => 1,
			     );	
    $template->param( username => $self->authen->username,
#		      sessionid => $self->session->id(),
		      lid => $lid,
		      library => $library,
	);
    # Parse the template
    my $html_output = $template->output;
    return $html_output;
}

#--------------------------------------------------------------------------------
#
#
sub circstats_process {
    my $self = shift;
    my $q = $self->query;

    my ($lid,$symbol, $library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('rotations/enter_stats.tmpl');	
    $template->param( pagetitle => "Rotations - enter stats",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub current_process {
    my $self = shift;
    my $q = $self->query;

    my ($lid,$symbol,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('rotations/at_my_library.tmpl');	
    $template->param( pagetitle => "Rotations - at my library",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub holdings_setup_process {
    my $self = shift;
    my $q = $self->query;

    my ($lid,$symbol,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    $self->log->info("in holdings_setup_process" . Dumper($q));

    if ($q->param('lid')) {
	$self->log->info("data passed in");
	# update
	my $cnt = $self->dbh->selectrow_arrayref("select count(lid) from rotations_lib_holdings_fields where lid=?", undef, $lid);
	if ((defined $cnt) && ($cnt->[0] > 0)) {
	    $self->log->info("existing record, updating");
	    my $retval = $self->dbh->do("update rotations_lib_holdings_fields set holdings_field=?, barcode_subfield=?, callno_subfield=?, library_subfield=?, library_default=?, location_subfield=?, location_default=?, collection_subfield=?, collection_default=? where lid=?",
					undef,
					$q->param('holdings_field'),
					$q->param('barcode_subfield'),
					$q->param('callno_subfield'),
					$q->param('library_subfield'),
					$q->param('library_default'),
					$q->param('location_subfield'),
					$q->param('location_default'),
					$q->param('collection_subfield'),
					$q->param('collection_default'),
					$lid
		);
	    die "update returned undef!" unless $retval;
	} else {
	    $self->log->info("new record, inserting");
	    my $retval = $self->dbh->do("insert into rotations_lib_holdings_fields (lid, holdings_field, barcode_subfield, callno_subfield, library_subfield, library_default, location_subfield, location_default, collection_subfield, collection_default) values (?,?,?,?,?,?,?,?,?,?)",
					undef,
					$lid,
					$q->param('holdings_field'),
					$q->param('barcode_subfield'),
					$q->param('callno_subfield'),
					$q->param('library_subfield'),
					$q->param('library_default'),
					$q->param('location_subfield'),
					$q->param('location_default'),
					$q->param('collection_subfield'),
					$q->param('collection_default')
		);
	    die "update returned undef!" unless $retval;
	}
    }

    my $currentSettings = $self->dbh->selectrow_hashref(
	"select holdings_field, barcode_subfield, callno_subfield, library_subfield, library_default, location_subfield, location_default, collection_subfield, collection_default from rotations_lib_holdings_fields where lid=?",
	undef,
	$lid
	);
    if (defined $currentSettings) {
	$currentSettings->{library_default} = $symbol unless (defined $currentSettings->{library_default});
    } else {
	$currentSettings->{holdings_field} = "949";
	$currentSettings->{barcode_subfield} = 'b';
	$currentSettings->{callno_subfield} = 'd';
	$currentSettings->{library_subfield} = 'a';
	$currentSettings->{library_default} = $symbol;
	$currentSettings->{location_subfield} = 'l';
	$currentSettings->{location_default} = $symbol;
	$currentSettings->{collection_subfield} = 'c';
	$currentSettings->{collection_default} = "Stacks";
    }

    my $template = $self->load_tmpl('rotations/holdings_settings.tmpl');	
    $template->param( pagetitle => "Rotations - Holdings setup",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
		      holdings_field => $currentSettings->{holdings_field},
		      barcode_subfield => $currentSettings->{barcode_subfield},
		      callno_subfield => $currentSettings->{callno_subfield},
		      library_subfield => $currentSettings->{library_subfield},
		      library_default => $currentSettings->{library_default},
		      location_subfield => $currentSettings->{location_subfield},
		      location_default => $currentSettings->{location_default},
		      collection_subfield => $currentSettings->{collection_subfield},
		      collection_default => $currentSettings->{collection_default}
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------------------
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
