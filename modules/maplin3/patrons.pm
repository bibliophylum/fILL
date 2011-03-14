package maplin3::patrons;
use strict;
use base 'maplin3base';



#--------------------------------------------------------------------------------
# Define our runmodes
#
sub setup {
    my $self = shift;
    $self->start_mode('patrons_verify_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'patrons_verify_form'    => 'patrons_verify_process',
	'patrons_edit_form'      => 'patrons_edit_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub patrons_verify_process {
    my $self = shift;
    my $q = $self->query;
    
    if ($q->param('pid')) {
	my $ok = $self->dbh->do("UPDATE patrons SET verified=1 WHERE pid=?",
				undef,
				$q->param('pid')
	    );
    }
    
    my $library_href = $self->dbh->selectrow_hashref(
	"SELECT lid from libraries WHERE name=?",
	{},
	$self->authen->username,
	);
    $self->log->debug("Patrons: My library lid: [" . $library_href->{lid} . "]");
    
    my $SQL_getUnverifiedPatrons = "SELECT pid, name, card, email_address FROM patrons WHERE home_library_id=? AND verified=0";
    
    # Get the data for the form
    my $aref = $self->dbh->selectall_arrayref(
	$SQL_getUnverifiedPatrons,
	{  Slice => {} },
	$library_href->{lid},
	);
    
    my $template = $self->load_tmpl('patrons/verify.tmpl');
    $template->param(pagetitle => "Maplin-3 Patrons Verify",
		     username     => $self->authen->username,
		     PATRONLOOP   => $aref
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub patrons_edit_process {
    my $self = shift;
    my $q = $self->query;
    
    my $status = "Select a patron to edit.";
    my $in_editing = 0;
    my $new_password = 0;

    my $SQL_getPatron = "SELECT pid,name,card,is_enabled,verified,email_address,home_library_id,ill_requests,last_login,username FROM patrons WHERE pid=?";
    my $patron_href;

    my $library_href = $self->dbh->selectrow_hashref(
	"SELECT lid from libraries WHERE name=?",
	{},
	$self->authen->username,
	);
    $self->log->debug("Patrons: My library lid: [" . $library_href->{lid} . "]");
    
    my $SQL_getPatronsList = "SELECT pid, name, card, email_address, last_login FROM patrons WHERE home_library_id=?";
    
    if ($q->param('sort')) {
	$SQL_getPatronsList .= " ORDER BY $q->param('sort')";
    } else {
	$SQL_getPatronsList .= " ORDER BY name";
    }
    
    # Get the data for the form
    my $aref = $self->dbh->selectall_arrayref(
	$SQL_getPatronsList,
	{  Slice => {} },
	$library_href->{lid},
	);
    
    
    #
    # Actions
    #
    if ($q->param('action') eq 'new_password') {
	$patron_href = $self->dbh->selectrow_hashref( $SQL_getPatron,
						      undef,
						      $q->param('pid')
	    );
	if ($patron_href->{home_library_id} != $library_href->{lid}) {
	    $status = "Edit password error: Invalid library/patron combination.";
	    $patron_href = undef;
	} else {
	    $new_password = 1;
	    $in_editing = 1;
	    $status = "Enter a new password for the user, and click 'Save'";
	}
    }

    if ($q->param('action') eq 'save') {
	# do the saving
	if ($q->param('pid')) {
	    $patron_href = $self->dbh->selectrow_hashref( $SQL_getPatron,
							  undef,
							  $q->param('pid')
		);
	    if ($patron_href->{home_library_id} != $library_href->{lid}) {
		$status = "Save error: Invalid library/patron combination.";
		$patron_href = undef;
	    } else {
		my $SQL_save = "UPDATE patrons SET name=?,card=?,is_enabled=?,verified=?,email_address=? WHERE pid=?";
		
		my $ok = $self->dbh->do( $SQL_save,
					 undef,
					 $q->param('name'),
					 $q->param('card'),
					 $q->param('is_enabled'),
					 $q->param('verified'),
					 $q->param('email_address'),
					 $q->param('pid')
		    );
		
		if ($ok) {
		    if ($q->param('passwd')) {
			$SQL_save = "UPDATE patrons SET password=md5(?) WHERE pid=?";
			my $ok = $self->dbh->do( $SQL_save,
						 undef,
						 $q->param('passwd'),
						 $q->param('pid')
			    );
		    }
		    $status = "Saved. Select a patron to edit.";
		} else {
		    $status = "FIXME: Problem saving patron record.";
		}
	    }
	}
    }
    
    if ($q->param('action') eq 'load') {
	if ($q->param('pid')) {
	    $patron_href = $self->dbh->selectrow_hashref( $SQL_getPatron,
							  undef,
							  $q->param('pid')
		);
	    if ($patron_href->{home_library_id} != $library_href->{lid}) {
		$patron_href = undef;
		$status = "Load error: Invalid library/patron combination.";
	    } else {
		$in_editing = 1;
		$status = "Editing";
	    }
	}
    }
    
    
    
    
    my $template = $self->load_tmpl('patrons/edit.tmpl');
    $template->param(pagetitle => "Maplin-3 Patrons Edit",
		     username      => $self->authen->username,
		     status        => $status,
		     in_editing    => $in_editing,
		     new_password  => $new_password,
		     pid           => $patron_href->{pid},
		     pusername     => $patron_href->{username},
		     name          => $patron_href->{name},
		     card          => $patron_href->{card},
		     is_enabled    => $patron_href->{is_enabled},
		     verified      => $patron_href->{verified},
		     email_address => $patron_href->{email_address},
		     ill_requests  => $patron_href->{ill_requests},
		     last_login    => $patron_href->{last_login},
		     PATRONLOOP    => $aref
	);
    return $template->output;
}



1; # so the 'require' or 'use' succeeds

