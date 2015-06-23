package fILL::rotations;
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

    my ($oid,$symbol,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl(	    
	                      'rotations/receiving.tmpl',
			      cache => 1,
			     );	
    $template->param( username => $self->authen->username,
#		      sessionid => $self->session->id(),
		      oid => $oid,
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

    my ($oid,$symbol, $library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $hr_id = $self->dbh->selectrow_hashref(
	"select symbol, org_name from rotations_order ro left join org o on o.oid=ro.to_oid where ro.from_oid=?",
	undef,
	$oid
	);
    my $reminder = "Reminder: You are sending these books to " . $hr_id->{org_name} . " (" . $hr_id->{symbol} . ")";

    my $template = $self->load_tmpl('rotations/enter_stats.tmpl');	
    $template->param( pagetitle => "Rotations - enter stats",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
		      reminder => $reminder,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub current_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$symbol,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('rotations/at_my_library.tmpl');	
    $template->param( pagetitle => "Rotations - at my library",
		      username => $self->authen->username,
		      oid => $oid,
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

    my ($oid,$symbol,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    $self->log->info("in holdings_setup_process" . Dumper($q));

    if ($q->param('oid')) {
	$self->log->info("data passed in");
	# update
	my $cnt = $self->dbh->selectrow_arrayref("select count(oid) from rotations_lib_holdings_fields where oid=?", undef, $oid);
	if ((defined $cnt) && ($cnt->[0] > 0)) {
	    $self->log->info("existing record, updating");
	    my $retval = $self->dbh->do("update rotations_lib_holdings_fields set holdings_field=?, barcode_subfield=?, callno_subfield=?, library_subfield=?, library_default=?, location_subfield=?, location_default=?, collection_subfield=?, collection_default=? where oid=?",
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
					$oid
		);
	    die "update returned undef!" unless $retval;
	} else {
	    $self->log->info("new record, inserting");
	    my $retval = $self->dbh->do("insert into rotations_lib_holdings_fields (oid, holdings_field, barcode_subfield, callno_subfield, library_subfield, library_default, location_subfield, location_default, collection_subfield, collection_default) values (?,?,?,?,?,?,?,?,?,?)",
					undef,
					$oid,
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
	"select holdings_field, barcode_subfield, callno_subfield, library_subfield, library_default, location_subfield, location_default, collection_subfield, collection_default from rotations_lib_holdings_fields where oid=?",
	undef,
	$oid
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
		      oid => $oid,
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

#-------------------------------------------------------------------------------------------
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
