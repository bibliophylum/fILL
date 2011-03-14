package maplin3::admin;
use strict;
use base 'maplin3base';
use ZOOM;
use MARC::Record;
use POSIX qw(strftime);
use DateTime;
use Data::Dumper;
use GD;
use GD::Graph;
use GD::Graph::lines;
use GD::Graph::pie;

#--------------------------------------------------------------------------------
# Define our runmodes
#
sub setup {
    my $self = shift;
    $self->start_mode('admin_reports_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'admin_reports_form'                 => 'admin_reports_process',
	'admin_logs_form'                    => 'admin_logs_process',
	'admin_config_form'                  => 'admin_config_process',
	'admin_config_zServers_form'         => 'admin_config_zServers_process',
	'admin_config_zServer_edit_form'     => 'admin_config_zServer_edit_process',
	'admin_config_zServer_add_form'      => 'admin_config_zServer_add_process',
	'admin_config_zServer_NotForLoan_form' => 'admin_config_zServer_NotForLoan_process',
	'admin_config_zServer_owners_form'   => 'admin_config_zServer_owners_process',
	'admin_users_form'                   => 'admin_users_process',
	'admin_actions_form'                 => 'admin_actions_process',
	'admin_test_zserver_form'            => 'admin_test_zserver_process',
	'admin_status_form'                  => 'admin_status_process',
	'admin_CDT_select_form'              => 'admin_CDT_select_process',
	'admin_CDT_pull_form'                => 'admin_CDT_pull_process',
	'admin_CDT_select_unclaimed_form'    => 'admin_CDT_select_unclaimed_process',
	'admin_CDT_unclaimed_pull_form'      => 'admin_CDT_unclaimed_pull_process',
	'admin_reports_CDT_totals_form'      => 'admin_reports_CDT_totals_process',
#	'admin_status_check_form'            => 'admin_status_check_process',
	'admin_reports_ILL_stats_form'       => 'admin_reports_ILL_stats_process',
	'admin_reports_ILL_requests_form'    => 'admin_reports_ILL_requests_process',
	'admin_reports_ILL_graphs_form'      => 'admin_reports_ILL_graphs_process',
	'admin_reports_ILL_pie_form'         => 'admin_reports_ILL_pie_process',
	'admin_reports_zServers_down_form'   => 'admin_reports_zServers_down_process',
	'reports_home_zServers_form'         => 'reports_home_zServers_process',
	'admin_reports_last_logins_form'     => 'admin_reports_last_logins_process',
	'admin_reports_never_logged_in_form' => 'admin_reports_never_logged_in_process',
	'admin_reports_table_stats_form'     => 'admin_reports_table_stats_process',
	'admin_CDT_find_form'                => 'admin_CDT_find_process',
	'admin_CDT_ClaimByBarcode_form'      => 'admin_CDT_ClaimByBarcode_process',
	'admin_actions_clear_old_data_form'  => 'admin_actions_clear_old_data_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub admin_reports_process {
    my $self = shift;

    my $template = $self->load_tmpl('admin/reports.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin Reports',
		     username => $self->authen->username);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub admin_logs_process {
    my $self = shift;
    my $q = $self->query;

    my $log = $q->param("log");
    $log = "No log chosen" unless ($log);

    opendir(DIR, '/opt/maplin3/logs') || die "can't opendir /opt/maplin3/logs: $!";
    my @accessLogs = grep { /^access.log/ && -f "/opt/maplin3/logs/$_" } readdir(DIR);
    rewinddir(DIR);
    my @errorLogs = grep { /^error.log/ && -f "/opt/maplin3/logs/$_" } readdir(DIR);
    closedir DIR;

    # turn them into hashes for the template loops
    my @loopAccess = ();
    while (@accessLogs) {
	my %row_data;
	$row_data{filename} = shift @accessLogs;
	push(@loopAccess, \%row_data);
    }
    my @loopAccessSorted = sort {$a->{filename} cmp $b->{filename}} @loopAccess;

    my @loopError = ();
    while (@errorLogs) {
	my %row_data;
	$row_data{filename} = shift @errorLogs;
	$self->log->debug("$row_data{filename}");
	push(@loopError, \%row_data);
    }
    my @loopErrorSorted = sort {$a->{filename} cmp $b->{filename}} @loopError;

    my $tail;

    if (($log =~ /^access.log/) || ($log =~ /^error.log/)) {
	$tail = `tail -n 40 /opt/maplin3/logs/$log`;
    }

    my $template = $self->load_tmpl('admin/logs.tmpl');

    $template->param(pagetitle => 'Maplin-3 Admin Logs',
		     username => $self->authen->username,
		     log => $log,
		     accessLogs => \@loopAccessSorted,
		     errorLogs => \@loopErrorSorted,
		     tail => $tail
	);

    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub admin_config_process {
    my $self = shift;

    my $template = $self->load_tmpl('admin/config.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin Config',
		     username => $self->authen->username);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub admin_config_zServers_process {
    my $self = shift;
    my $q = $self->query;

    if (($q->param('enable')) && ($q->param('id'))) {
	my $SQL = "UPDATE zservers SET available=1 WHERE id=?";

	$self->dbh->do($SQL,
		       undef,
		       $q->param('id')
	    );

    }

    if (($q->param('disable')) && ($q->param('id'))) {
	my $SQL = "UPDATE zservers SET available=0 WHERE id=?";

	$self->dbh->do($SQL,
		       undef,
		       $q->param('id')
	    );

    }

    if ($q->param('add')) {
	#
	# We get here from the zServer_add.tmpl
	#
	my $TypeOfResource = $q->param('tor');
	my $isStd = ($TypeOfResource =~ /std/) ? 1 : 0;
	my $isEle = ($TypeOfResource =~ /ele/) ? 1 : 0;
	my $isWeb = ($TypeOfResource =~ /web/) ? 1 : 0;
	my $isDat = ($TypeOfResource =~ /dat/) ? 1 : 0;

	my $available = $q->param('available') || 0;
	my $handles_holdings_improperly = $q->param('handles_holdings_improperly') || 0;

	my $SQL = "INSERT INTO zservers (name, z3950_connection_string, email_address, available, holdings_tag, holdings_location, holdings_collection, holdings_callno, holdings_avail, holdings_due, handles_holdings_improperly, ils, isstandardresource, iselectronicresource, iswebresource, isdatabase) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

	$self->dbh->do($SQL,
		       undef,
		       $q->param('name'),
		       $q->param('z3950_connection_string'),
		       $q->param('email_address'),
		       ($available =~ /[ 0]/) ? 0 : 1,
		       $q->param('holdings_tag'),
		       $q->param('holdings_location'),
		       $q->param('holdings_collection'),
		       $q->param('holdings_callno'),
		       $q->param('holdings_avail'),
		       $q->param('holdings_due'),
		       ($handles_holdings_improperly =~ /[ 0]/) ? 0 : 1,
		       $q->param('ils'),
		       $isStd, $isEle, $isWeb, $isDat,
	    );



    }

    if ($q->param('delete')) {
	$self->dbh->do("DELETE FROM zservers WHERE id=?",
		       undef,
		       $q->param('id')
	    );

    }

    my $SQL_getServersList = "SELECT id, name, z3950_connection_string, email_address, available, holdings_tag, holdings_location, holdings_collection, holdings_callno, holdings_avail, holdings_due, handles_holdings_improperly FROM zservers";

    my $ar_conn = $self->dbh->selectall_arrayref(
	$SQL_getServersList,
	{ Slice => {} }
	);

    my @sorted_connections = sort { $a->{name} cmp $b->{name} } @$ar_conn;

    my $template = $self->load_tmpl('admin/config/zServers.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin Config zServers',
		     username => $self->authen->username,
		     zServers => \@sorted_connections,
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub admin_config_zServer_edit_process {
    my $self = shift;
    my $q = $self->query;
    my $hr_conn;

    # are we updating?
    if ($q->param('update')) {

	my $TypeOfResource = $q->param('tor');
	my $isStd = ($TypeOfResource =~ /std/) ? 1 : 0;
	my $isEle = ($TypeOfResource =~ /ele/) ? 1 : 0;
	my $isWeb = ($TypeOfResource =~ /web/) ? 1 : 0;
	my $isDat = ($TypeOfResource =~ /dat/) ? 1 : 0;

	my $available = $q->param('available') || 0;
	my $handles_holdings_improperly = $q->param('handles_holdings_improperly') || 0;

	my $SQL = "UPDATE zservers SET name=?, z3950_connection_string=?, email_address=?, available=?, holdings_tag=?, holdings_location=?, holdings_collection=?, holdings_callno=?, holdings_avail=?, holdings_due=?, handles_holdings_improperly=?, ils=?, isstandardresource=?, iselectronicresource=?, iswebresource=?, isdatabase=? WHERE id=?";

	$self->dbh->do($SQL,
		       undef,
		       $q->param('name'),
		       $q->param('z3950_connection_string'),
		       $q->param('email_address'),
		       ($available =~ /[ 0]/) ? 0 : 1,
		       $q->param('holdings_tag'),
		       $q->param('holdings_location'),
		       $q->param('holdings_collection'),
		       $q->param('holdings_callno'),
		       $q->param('holdings_avail'),
		       $q->param('holdings_due'),
		       ($handles_holdings_improperly =~ /[ 0]/) ? 0 : 1,
		       $q->param('ils'),
		       $isStd, $isEle, $isWeb, $isDat,
		       $q->param('id')
	    );

	my $rows = $self->dbh->do("UPDATE library_zserver SET lid=? WHERE zid=(SELECT id FROM zservers WHERE name=?)",
				  undef,
				  $q->param('owner_lid'),
				  $q->param('name')
	    );
	if ($rows == "0E0") {
	    $self->dbh->do("INSERT INTO library_zserver (lid, zid) VALUES (?,(SELECT id FROM zservers WHERE name=?))",
				  undef,
				  $q->param('owner_lid'),
				  $q->param('name')
	    );
	}

    }


    if ($q->param('id')) {

	my $SQL_getServer = "SELECT id, name, z3950_connection_string, email_address, available, holdings_tag, holdings_location, holdings_collection, holdings_callno, holdings_avail, holdings_due, handles_holdings_improperly, ils, isstandardresource, iselectronicresource, iswebresource, isdatabase FROM zservers WHERE id=?";
	
	$hr_conn = $self->dbh->selectrow_hashref(
	    $SQL_getServer,
	    undef,
	    $q->param('id'),
	    );
    }

    # get list for possible owners
    my $SQL_possible_owners = "SELECT lid, library FROM libraries ORDER BY library";
    my $possible_owners = $self->dbh->selectall_arrayref( $SQL_possible_owners,
							  { Slice => {} }
	);

    # get current owner
    my $owner = $self->dbh->selectrow_hashref(
	"SELECT lid FROM library_zserver WHERE zid=?",
	undef,
	$q->param('id'),
	);
    foreach my $possible (@$possible_owners) {
	if ($possible->{lid} == $owner->{lid}) {
	    $possible->{isowner} = 1;
	} else {
	    $possible->{isowner} = 0;
	}
    }

    my $template = $self->load_tmpl('admin/config/zServer_edit.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin Config zServer Edit',
		     username => $self->authen->username,
		     id                      => $hr_conn->{id},
		     name                    => $hr_conn->{name},
		     z3950_connection_string => $hr_conn->{z3950_connection_string},
		     email_address           => $hr_conn->{email_address},
		     available               => $hr_conn->{available},
		     holdings_tag            => $hr_conn->{holdings_tag},
		     holdings_location       => $hr_conn->{holdings_location},
		     holdings_collection     => $hr_conn->{holdings_collection},
		     holdings_callno         => $hr_conn->{holdings_callno},
		     holdings_avail          => $hr_conn->{holdings_avail},
		     holdings_due            => $hr_conn->{holdings_due},
		     handles_holdings_improperly => $hr_conn->{handles_holdings_improperly},
		     ils                     => $hr_conn->{ils},
		     isstandardresource      => $hr_conn->{isstandardresource},
		     iswebresource           => $hr_conn->{iswebresource},
		     iselectronicresource    => $hr_conn->{iselectronicresource},
		     isdatabase              => $hr_conn->{isdatabase},
		     possible_owners         => $possible_owners,
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub admin_config_zServer_add_process {
    my $self = shift;
    my $q = $self->query;
    my $hr_conn;

    my $template = $self->load_tmpl('admin/config/zServer_add.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin Config zServer Add',
		     username => $self->authen->username,
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub admin_config_zServer_NotForLoan_process {
    my $self = shift;
    my $q = $self->query;
    my $ar_nfl;

    if ($q->param('zid')) {

	if ($q->param('add')) {
	    if ($q->param('tag') && $q->param('subfield') && $q->param('text')) {
		my $SQL = "INSERT INTO notforloan (zid,tag,subfield,text,atstart) VALUES (?,?,?,?,?)";
		
		$self->dbh->do($SQL,
			       undef,
			       $q->param('zid'),
			       $q->param('tag'),
			       $q->param('subfield'),
			       $q->param('text'),
			       $q->param('atstart') ? 1 : 0,
		    );
	    } elsif ($q->param('tag') && $q->param('text') && ($q->param('tag') lt '010')) {
		my $SQL = "INSERT INTO notforloan (zid,tag,text,atstart) VALUES (?,?,?,?)";
		
		$self->dbh->do($SQL,
			       undef,
			       $q->param('zid'),
			       $q->param('tag'),
			       $q->param('text'),
			       $q->param('atstart') ? 1 : 0,
		    );
	    }
	}

	if ($q->param('delete')) {
	    if ($q->param('tag') && $q->param('subfield') && $q->param('text')) {
		my $SQL = "DELETE FROM notforloan WHERE zid=? and tag=? and subfield=? and text=? LIMIT 1";
		
		$self->dbh->do($SQL,
			       undef,
			       $q->param('zid'),
			       $q->param('tag'),
			       $q->param('subfield'),
			       $q->param('text'),
		    );
	    } elsif ($q->param('tag') && $q->param('text') && ($q->param('tag') lt '010')) {
		my $SQL = "DELETE FROM notforloan WHERE zid=? and tag=? and text=? LIMIT 1";
		
		$self->dbh->do($SQL,
			       undef,
			       $q->param('zid'),
			       $q->param('tag'),
			       $q->param('text'),
		    );
	    }
	}


	
	$ar_nfl = $self->dbh->selectall_arrayref(
	    "SELECT zid, tag, subfield, text, atstart FROM notforloan WHERE zid=?",
	    { Slice => {} },
	    $q->param('zid'),
	    );
    }

    my $template = $self->load_tmpl('admin/config/zServer_NotForLoan.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin Config zServer NotForLoan',
		     username => $self->authen->username,
		     notforloan => $ar_nfl,
		     zserver => $q->param('zid'),
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub admin_config_zServer_owners_process {
    my $self = shift;
    my $q = $self->query;

    if (($q->param('setowner')) && ($q->param('setOwnerForZserver'))) {
	my $rv = $self->dbh->do("UPDATE user_zserver SET lid=? WHERE zserver_id=?",
				undef,
				$q->param('setowner'),
				$q->param('setOwnerForZserver')
	    );
	if (($rv == 0) || ($rv == 0E0)) {
	    # no rows updated... need to insert
	    $self->dbh->do("INSERT INTO user_zserver (lid,zserver_id) VALUES (?,?)",
			   undef,
			   $q->param('setowner'),
			   $q->param('setOwnerForZserver')
		);
	    
	}

    }

    my $SQL_getServersList = "SELECT z.id, z.name, ut.lid FROM zservers z left join user_zserver ut on z.id = ut.zserver_id";

    my $ar_zServers = $self->dbh->selectall_arrayref(
	$SQL_getServersList,
	{ Slice => {} }
	);

    my @sorted_zServers = sort { $a->{name} cmp $b->{name} } @$ar_zServers;

    my $ar_users = $self->dbh->selectall_arrayref(
	"SELECT lid as user_id, library as user_library from libraries ORDER by library",
	{ Slice => {} }
	);
    
    foreach my $zServer (@sorted_zServers) {
	if ($zServer->{lid}) {
	    my $ar_Owner = $self->dbh->selectrow_hashref(
		"SELECT name, library from libraries WHERE lid=?",
		undef,
		$zServer->{lid}
		);
	    $zServer->{owner} = $ar_Owner->{name};
	    $zServer->{library} = $ar_Owner->{library};
	} else {
	    $zServer->{owner} = "---";
	    $zServer->{library} = "Not assigned.";
	}

	# and the users arrayref
	$zServer->{users} = $ar_users;
    }


    my $template = $self->load_tmpl('admin/config/zServer_owners.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin Config zServer Owners',
		     username => $self->authen->username,
		     zServers => \@sorted_zServers,
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub admin_users_process {
    my $self = shift;
    my $q = $self->query;

    my $SQL_getUsersList = "SELECT lid, name, password, active, email_address, admin, library, mailing_address_line1, mailing_address_line2, mailing_address_line3, ILL_sent, home_zserver_id, home_zserver_location from libraries";

    my $status = "Select a user to edit...";

    my $ar_conn = $self->dbh->selectall_arrayref(
	$SQL_getUsersList,
	{ Slice => {} }
	);

    my %edit;

    my $userSelected = $q->param("u");
    my $lid = $q->param("lid");
    my $name = $q->param("name");
    my $password = $q->param("password");
    my $active = $q->param("active");
    my $email_address = $q->param("email_address");
    my $admin = $q->param("admin");
    my $library = $q->param("library");
    my $mailing_address_line1 = $q->param("mailing_address_line1");
    my $mailing_address_line2 = $q->param("mailing_address_line2");
    my $mailing_address_line3 = $q->param("mailing_address_line3");
    my $home_zserver_id = $q->param("home_zserver_id");
    my $home_zserver_location = $q->param("home_zserver_location");
    my $new_user = $q->param("new_user");
    my $delete_id = $q->param("delete_id");

    if (defined $userSelected) {

	# User has chosen a new user to edit from the list

	$self->log->debug("Admin:Users: Edit user id [$userSelected]");

	# Find the array element (hash) where userSelected matches {lid}
	foreach my $href (@$ar_conn) {
	    if ($href->{lid} == $userSelected) {
		$edit{lid}   = $href->{lid};
		$edit{name} = $href->{name};
		$edit{password} = $href->{password};
		$edit{email_address} = $href->{email_address};
		$edit{active} = $href->{active};
		$edit{admin} = $href->{admin};
		$edit{library} = $href->{library};
		$edit{mailing_address_line1} = $href->{mailing_address_line1};
		$edit{mailing_address_line2} = $href->{mailing_address_line2};
		$edit{mailing_address_line3} = $href->{mailing_address_line3};
		$edit{home_zserver_id} = $href->{home_zserver_id};
		$edit{home_zserver_location} = $href->{home_zserver_location};
		$self->log->debug("Admin:Users: Edit user lid:$href->{lid}, name:$href->{name}, library:$href->{library}");
		last;
	    }
	}

	$status = "Editing in process.";

    } elsif (defined $new_user) {

	$self->log->debug("Admin:Users: New user name [$name]");

	$self->dbh->do("INSERT INTO libraries (name, password, active) VALUES (?,?,?)",
		       undef,
		       $name,
		       $password,
		       0
	    );

	$status = "Added.  Select a user to edit...";

	# Get the users list again.
	$ar_conn = $self->dbh->selectall_arrayref(
	    $SQL_getUsersList,
	    { Slice => {} }
	    );

    } elsif (defined $delete_id) {

	$self->log->debug("Admin:Users: Delete user lid [$delete_id]");

	$self->dbh->do("DELETE from libraries WHERE lid=?",
		       undef,
		       $delete_id
	    );

	$status = "Deleted.  Select a user to edit...";

	# Get the users list again.
	$ar_conn = $self->dbh->selectall_arrayref(
	    $SQL_getUsersList,
	    { Slice => {} }
	    );

    } elsif (defined $lid) {

	$self->log->debug("Admin:Users: Updating lid [$lid], name [$name]");

	$self->dbh->do("UPDATE libraries SET name=?, password=?, active=?, email_address=?, admin=?, library=?, mailing_address_line1=?, mailing_address_line2=?, mailing_address_line3=?, home_zserver_id=?, home_zserver_location=? WHERE lid=?",
		       undef,
		       $name,
		       $password,
		       $active,
		       $email_address,
		       $admin,
		       $library,
		       $mailing_address_line1,
		       $mailing_address_line2,
		       $mailing_address_line3,
		       $home_zserver_id,
		       $home_zserver_location,
		       $lid
	    );

	$status = "Updated.  Select a user to edit...";

	# Get the users list again.
	$ar_conn = $self->dbh->selectall_arrayref(
	    $SQL_getUsersList,
	    { Slice => {} }
	    );
    }

    my @sorted_users = sort { $a->{name} cmp $b->{name} } @$ar_conn;

    my $template = $self->load_tmpl('admin/libraries.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin Users',
		     username => $self->authen->username,
		     users        => \@sorted_users,
		     status       => $status,
		     editLID      => $edit{lid},
		     editName     => $edit{name},
		     editPassword => $edit{password},
		     editEmail    => $edit{email_address},
		     editActive   => $edit{active},
		     editAdmin    => $edit{admin},
		     editLibrary  => $edit{library},
		     editMailingAddressLine1 => $edit{mailing_address_line1},
		     editMailingAddressLine2 => $edit{mailing_address_line2},
		     editMailingAddressLine3 => $edit{mailing_address_line3},
		     editHomeZserverID       => $edit{home_zserver_id},
		     editHomeZserverLocation => $edit{home_zserver_location}
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub admin_actions_process {
    my $self = shift;

    my $template = $self->load_tmpl('admin/actions.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin Actions',
		     username => $self->authen->username);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub admin_test_zserver_process {
    my $self = shift;
    my $q = $self->query;

    my $test_results = "";

    my $zserver = $q->param("zserver");
    my $conn   = $q->param("conn") || $zserver;
    my $prs    = $q->param("prs") || "usmarc";
    my $es     = $q->param("es") || "f";
    my $pqf    = $q->param("pqf");
    my $usr    = $q->param("usr");
    my $pwd    = $q->param("pwd");
    my $scan   = $q->param("scan") || 0;

    my %bib1;
    $bib1{attr_use} = $q->param("use");
    $bib1{attr_relation} = $q->param("relation");
    $bib1{attr_position} = $q->param("position");
    $bib1{attr_structure} = $q->param("structure");
    $bib1{attr_truncation} = $q->param("truncation");
    $bib1{attr_completeness} = $q->param("completeness");
    $bib1{terms} = $q->param("terms");
    if (($bib1{attr_use}) && ($bib1{terms})) {
	$pqf = "\@attr 1=" . $bib1{attr_use};
	if ($bib1{attr_relation}) {
	    $pqf .= " \@attr 2=" . $bib1{attr_relation};
	}
	if ($bib1{attr_position}) {
	    $pqf .= " \@attr 3=" . $bib1{attr_position};
	}
	if ($bib1{attr_structure}) {
	    $pqf .= " \@attr 4=" . $bib1{attr_structure};
	}
	if ($bib1{attr_truncation}) {
	    $pqf .= " \@attr 5=" . $bib1{attr_truncation};
	}
	if ($bib1{attr_completeness}) {
	    $pqf .= " \@attr 6=" . $bib1{attr_completeness};
	}
	$pqf .= " \"$bib1{terms}\"";
    }

    my $ar_conn = $self->dbh->selectall_arrayref(
	"SELECT name, z3950_connection_string FROM zservers ORDER BY name",
	{ Slice => {} }
	);

    if ($conn) {
	$test_results = _test_zserver($conn, $prs, $es, $pqf, $usr, $pwd, $scan);
    }

    my $template = $self->load_tmpl('admin/test_zserver.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin Test zServer',
		     username => $self->authen->username,
		     zservers => $ar_conn,
		     conn => $conn,
		     pqf => $pqf,
		     test_results => $test_results,
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
# INTERNAL
# parameter: "xxx.xxx.xxx.xxx:port/dbname"
# parameter: preferred record syntax (eg: "usmarc", "opac")
# parameter: pqf string
#
sub _test_zserver {
    my $connection_string = shift;
    my $preferredRecordSyntax = shift;
    my $elementSet = shift;
    my $pqf = shift;
    my $usr = shift;
    my $pwd = shift;
    my $scan = shift;

    $preferredRecordSyntax = "usmarc" unless ($preferredRecordSyntax);
    $elementSet = "f" unless ($elementSet);
    $pqf = '@attr 1=4 "duck hunting"' unless ($pqf);

    my $s = "";
    my $conn;
    
    my $rs;
    my $n;

    $s .= "\n--[ Connection ]-------\n";
    $s .= "$connection_string\n";
    $s .= "preferredRecordSyntax set to: $preferredRecordSyntax\n";

    eval {
	my $o1 = new ZOOM::Options(); $o1->option(user => $usr);
	my $o2 = new ZOOM::Options(); $o2->option(password => $pwd);
	my $otmp = new ZOOM::Options($o1, $o2);

	my $o3 = new ZOOM::Options(); $o3->option(preferredRecordSyntax => $preferredRecordSyntax);
	my $otmp2 = new ZOOM::Options($otmp, $o3);

	my $o4 = new ZOOM::Options(); $o4->option(elementSetName => $elementSet);
	my $opts = new ZOOM::Options($otmp2, $o4);
	$conn = create ZOOM::Connection($opts);
	$conn->connect($connection_string); # Uses the specified username and password
    };

#    eval {
#	$s .= "\n--[ Z39.50 test ]------\n";
#	$conn = new ZOOM::Connection($connection_string);
#	$s .= "server is '" . $conn->option("serverImplementationName") . "'\n";
##	$conn->option(preferredRecordSyntax => "usmarc");
##       $conn->option(preferredRecordSyntax => "opac");
#	$conn->option(preferredRecordSyntax => $preferredRecordSyntax);
#	$conn->option(elementSetName => $elementSet);
#    };
    if ($@) {
	$s .= "Error " . $@->code() . ": " . $@->message() . "\n";
	
    } else {

	if ($scan) {
	    # scan
	    eval {

		$s .= "\n--[ scan ]----\n";
		$s .= "$pqf\n";
		my $ss = $conn->scan_pqf($pqf);
		$n = $ss->size();
		$s .= "$n term(s) found.\n";
		for my $i (1 .. $n) {
		    $s .=  "\t--[Term #" . $i . " (" . ($i - 1) . "th term)]--\n";
		    my ($term, $occurrences) = $ss->term($i-1);
		    my ($displayTerm, $occurrences2) = $ss->display_term($i-1);
		    $s .=  "\t\t[$term]($occurrences): $displayTerm\n";
		}
	    };
	    if ($@) {
		$s .= "Error " . $@->code() . ": " . $@->message() . "\n";
	    }
	} else {
        # search
	    eval {
		$s .= "\n--[ search ]----\n";
		$s .= "$pqf\n";
		$rs = $conn->search_pqf($pqf);
		$n = $rs->size();
		$s .= "$n record(s) found.\n";
		
		$n = 10 if ($n > 10); # let's be reasonable
		
		if ($n > 0) {
		    $rs->records(0, $n, 0); # prefetch
		    
		    my $x = 0;
		    while ($x < $n) {
			
			$s .= "\n\n-[Record $x]--\n";
			$s .= $rs->record($x)->render();
			$s .= "\nRAW DATA:\n";
			$s .= $rs->record($x)->raw();
			
			$x++;
		    }
		}
	    };
	    if ($@) {
		$s .= "Error " . $@->code() . ": " . $@->message() . "\n";
	    }
	}
    }
    return $s;
}

#--------------------------------------------------------------------------------
#
#
sub admin_status_process {
    my $self = shift;
    my $q = $self->query;

    my $template = $self->load_tmpl('admin/status.tmpl');

    if ($q->param('session')) { # returning to pick up session data
	# this is the <meta http-equiv=refresh content=3> bit
	my $session = $q->param('session');

	my @ar_status = @{ $self->dbh->selectall_arrayref("select s.sessionid, s.zid, s.event, s.msg, z.name from status_check s, zservers z where s.zid = z.id and s.sessionid=? order by z.name",
						       { Slice => {} },
						       $session
			       ) };

	my $is_still_processing = 0;
	foreach my $href (@ar_status) {
	    $is_still_processing = 1 if (($href->{event} != 10) && ($href->{event} != 4));
	}
	if ($is_still_processing) {
	    my $url="admin.cgi?rm=admin_status_form&session=$session";
	    $self->header_props( -refresh => "3; URL=$url" );
	}

	$template->param(status => \@ar_status);
	return $template->output;

    } elsif ($q->param('newcheck')) {
	# start the external process
	my $session = $self->dbh->quote($self->session->id());

	# clear the status_check table
	$self->dbh->do("DELETE FROM status_check WHERE sessionid=?",
		       undef,
		       $session
	    );

	if (my $pid = fork) {            # parent does
	    my $url="admin.cgi?rm=admin_status_form&session=$session";
	    $self->header_props( -refresh => "1; URL=$url" );
	    return $template->output;

	} elsif (defined $pid) {         # child does
	    close STDOUT;                # so parent can go on

	    {
		#Stop the annoying (and log-filling)
		#"Name "maplin3::zsearch::F" used only once: possible typo"
		no warnings;
		#local $^W = 0;
		
		unless (open F, "-|") {
		    open STDERR, ">&=1";
		    exec "/opt/maplin3/externals/adminStatusCheck.pl", $session;
		    die "Cannot execute /opt/maplin3/externals/adminStatusCheck.pl";
		}
		# do some stuff
#	        # buf will contain STDOUT/STDERR of the command exec'd
#	        my $buf = "";
#	        while (<F>) {
#		    $buf .= $_;
#	        }
#	        # do something with buf, if you like :-)

		# In our case, we just want to let adminStatusCheck.pl go off
		# and do it's thing. (It updates the db table status_check,
		# and we really don't want to wait for it - parent is checking
		# the db and refreshing itself)
	    }
	    exit 0;
	} else {
	    die "Cannot fork: $!";
	}

    } else {
	$template->param(pagetitle => 'Maplin-3 Admin Status',
			 username => $self->authen->username);
	return $template->output;
    }
}

#--------------------------------------------------------------------------------
#
#
sub admin_CDT_select_process {
    my $self = shift;
    my $q = $self->query;

    #     0    1    2     3     4    5     6     7     8
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year += 1900;
    $mon += 1;

    my $date_start = $q->param('date_start') || sprintf("%4d-%02d-%02d",$year,$mon,$mday-1);
    my $date_end   = $q->param('date_end') || sprintf("%4d-%02d-%02d",$year,$mon,$mday);

    my $ar_libraries = $self->dbh->selectall_arrayref(
	"SELECT DISTINCT claimed_by FROM zerocirc ORDER BY claimed_by",
	{ Slice => {} }
	);

    my $template = $self->load_tmpl('admin/CDT_select.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin CDT Select',
		     username => $self->authen->username,
		     date_start => $date_start,
		     date_end => $date_end,
		     libraries => $ar_libraries,
	             );
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub admin_CDT_pull_process {
    my $self = shift;
    my $q = $self->query;

    my $library = $q->param('library') || "All libraries";
    $self->log->debug("admin_CDT_pull_process: library [$library]");

    #     0    1    2     3     4    5     6     7     8
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year += 1900;
    $mon += 1;

    my $date_start = $q->param('date_start') || sprintf("%4d-%02d-%02d",$year,$mon,$mday-1);
    my $date_end   = $q->param('date_end') || sprintf("%4d-%02d-%02d",$year,$mon,$mday);

    my @dummy_list = ();
    my $ar_pullList = \@dummy_list;

    my $SQL = "SELECT claimed_by, collection, callno, author, title, pubdate, barcode FROM zerocirc";
    if ($library ne "All libraries") {
	$SQL .= " WHERE claimed_by=? AND (claimed_timestamp >= ? AND claimed_timestamp < ?) ORDER BY claimed_by, collection, callno, author, title";
	$ar_pullList = $self->dbh->selectall_arrayref(
	    $SQL,
	    { Slice => {} },
	    $library,
	    $date_start,
	    $date_end,
	    );
    } else {
	$SQL .= " WHERE claimed_by is not null AND (claimed_timestamp >= ? AND claimed_timestamp < ?) ORDER BY claimed_by, collection, callno, author, title";
	$ar_pullList = $self->dbh->selectall_arrayref(
	    $SQL,
	    { Slice => {} },
	    $date_start,
	    $date_end,
	    );
    }

    my $template = $self->load_tmpl('admin/CDT_pull.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin CDT Pull',
		     username => $self->authen->username,
		     library => $library,
		     date_start => $date_start,
		     date_end => $date_end,
		     num_items => $#{ @$ar_pullList } + 1,
		     pull_list => $ar_pullList
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub admin_CDT_select_unclaimed_process {
    my $self = shift;
    my $q = $self->query;

#    my $ar_collections = $self->dbh->selectall_arrayref(
#	"SELECT DISTINCT collection FROM zerocirc ORDER BY collection",
#	{ Slice => {} }
#	);

    my @ar_coll = ( {collection => 'Easy'},
		    {collection => 'Fiction'},
		    {collection => 'Junior'},
		    {collection => 'Junior Fiction'},
		    {collection => 'Non-Fiction/Teen Non-Fiction'},
		    {collection => 'Teen Fiction'}
	);
    my $ar_collections = \@ar_coll;

    my $template = $self->load_tmpl('admin/CDT_select_unclaimed.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin CDT Select unclaimed',
		     username => $self->authen->username,
		     collections => $ar_collections,
	             );
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub admin_CDT_unclaimed_pull_process {
    my $self = shift;
    my $q = $self->query;

    my $pd = $q->param('pd') || '1995';
    my $coll = $q->param('collection');
    $self->log->debug("admin_CDT_unclaimed_pull_process: collection [$coll]");

    my $collection = "All collections";
    $collection = "E" if ($coll eq "Easy");
    $collection = "F" if ($coll eq "Fiction");
    $collection = "J" if ($coll eq "Junior");
    $collection = "JF" if ($coll eq "Junior Fiction");
    $collection = "TF" if ($coll eq "Teen Fiction");
    $collection = "NF" if ($coll eq "Non-Fiction/Teen Non-Fiction");

    my @dummy_list = ();
    my $ar_pullList = \@dummy_list;

    my $SQL = "SELECT collection, callno, author, title, pubdate, barcode FROM zerocirc";
    if ($collection ne "All collections") {
	if ($collection ne "NF") {
	    $SQL .= " WHERE (claimed_by is null AND collection=? AND left(pubdate,4) >= ?)";
	    $SQL .= " ORDER BY callno, author, title";
	    $ar_pullList = $self->dbh->selectall_arrayref(
		$SQL,
		{ Slice => {} },
		$collection,
		$pd,
		);
	} else {
	    # Combine NF and T lists
	    $SQL .= " WHERE (claimed_by is null AND (collection=? or collection=?) AND left(pubdate,4) >= ?)";
	    $SQL .= " ORDER BY callno, author, title";
	    $ar_pullList = $self->dbh->selectall_arrayref(
		$SQL,
		{ Slice => {} },
		'NF', 'T',
		$pd,
		);
	}
    } else {
	$SQL .= " WHERE claimed_by is null AND left(pubdate,4) >= ? ORDER BY collection, callno, author, title";
	$ar_pullList = $self->dbh->selectall_arrayref(
	    $SQL,
	    { Slice => {} },
	    $pd,
	    );
    }

    my $template = $self->load_tmpl('admin/CDT_unclaimed.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin CDT unclaimed',
		     username => $self->authen->username,
		     collection => $collection,
		     num_items => $#{ @$ar_pullList } + 1,
		     pull_list => $ar_pullList
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub admin_reports_CDT_totals_process {
    my $self = shift;

    my $hr_counts = $self->dbh->selectrow_hashref(
	"select count(*) as count from zerocirc where claimed_by is not null",
	);

    my $ar_counts_by_library = $self->dbh->selectall_arrayref(
	"select claimed_by, count(*) as count from zerocirc where claimed_by is not null group by claimed_by",
	{ Slice => {} },
	);

    my $hr_counts_by_collection_claimed = $self->dbh->selectall_hashref(
	"select collection, count(*) as claimed from zerocirc where claimed_by is not null group by collection",
	'collection',
	);

    my $hr_counts_by_collection_totals = $self->dbh->selectall_hashref(
	"select collection, count(*) as total from zerocirc group by collection",
	'collection',
	);

    my @counts_by_collection = ();
    my $sum_claimed = 0;
    my $sum_totals = 0;

    foreach my $coll (sort keys %$hr_counts_by_collection_totals) {
	my %row_data;
	$row_data{collection} = $coll;
	$row_data{claimed} = $hr_counts_by_collection_claimed->{$coll}{claimed} || 0;
	$row_data{total}   = $hr_counts_by_collection_totals->{$coll}{total};
	$row_data{percent} = sprintf("%3.1f",($row_data{claimed} / $row_data{total}) * 100);

	$sum_claimed += $row_data{claimed};
	$sum_totals  += $row_data{total};
	push(@counts_by_collection, \%row_data);
    }
    push(@counts_by_collection, { collection => "Total",
				  claimed => $sum_claimed,
				  total => $sum_totals,
				  percent => sprintf("%3.1f",($sum_claimed / $sum_totals) * 100),
	 });

    my $template = $self->load_tmpl('admin/reports/CDT_totals.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin Reports CDT totals',
		     username => $self->authen->username,
		     total_claimed => $hr_counts->{count},
		     by_library => $ar_counts_by_library,
		     by_collection => \@counts_by_collection,
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
#sub admin_status_check_process {
#    my $self = shift;
#    my $q = $self->query;
#    my $template = $self->load_tmpl('admin/status_check.tmpl');
#    $template->param( events => \@events,
#	);
#    return $template->output;
#}

#--------------------------------------------------------------------------------
#
#
sub admin_reports_ILL_stats_process {
    my $self = shift;

    my $hr_sum_of_sent = $self->dbh->selectrow_hashref(
	"select sum(ILL_sent) as sent from libraries",
	);

    my $ar_user = $self->dbh->selectall_arrayref(
#	"select name, ILL_sent from libraries where ILL_sent > 0 ORDER BY name",
	"select libraries.name, libraries.library, libraries.ILL_sent, zservers.name as home from libraries, zservers where (libraries.home_zserver_id = zservers.id) and (libraries.ILL_sent > 0) ORDER BY libraries.name",
	{ Slice => {} },
	);

    my $hr_sum_of_received = $self->dbh->selectrow_hashref(
	"select sum(ILL_received) as received from zservers",
	);

    my $ar_zservers = $self->dbh->selectall_arrayref(
	"select id, name, ILL_received from zservers ORDER BY name",
	{ Slice => {} },
	);

    my $ar_locations = $self->dbh->selectall_arrayref(
	"select zservers.name as zserver, zservers.ill_received as zserver_count, locations.location as loc, locations.ill_received as loc_count from zservers left join locations on zservers.id = locations.zid order by zservers.name, locations.location",
	{ Slice => {} },
	);

    my $ar_net = $self->dbh->selectall_arrayref(
	"select zservers.name as zserver, coalesce(zservers.ill_received, 0) as received_by_this_system, coalesce(sum(libraries.ill_sent),0) as sent_by_users_of_this_system, (coalesce(zservers.ill_received,0) - coalesce(sum(libraries.ill_sent),0)) as net from zservers left join libraries on zservers.id = libraries.home_zserver_id group by zservers.name, zservers.ill_received",
	{ Slice => {} },
	);
    my $net_received;
    my $net_sent;
    foreach my $row (@$ar_net) {
	$net_received += $row->{received_by_this_system};
	$net_sent += $row->{sent_by_users_of_this_system};
    }
    push @$ar_net, { zserver => " Total", 
		     received_by_this_system => $net_received,
		     sent_by_users_of_this_system => $net_sent,
		     net => $net_received - $net_sent
    };


#
#   [ { zserver => zservers.name,
#       zserver_count => zservers.ILL_received,
#       locations => [
#                     { location => locations.location,
#                       count    => locations.ILL_received,
#                     },
#                     { location => locations.location,
#                       count    => locations.ILL_received,
#                     },
#                    ],
#     },
#   ]
#

    my @z;
    my $curr_zserver = "";
    my @locs;
    my %zrec;
    my $firsttime = 1;
    foreach my $row (@$ar_locations) {
#	$self->log->debug("\n---------------------\n", Dumper($row));
	my %loc_hash = ();

	if ($row->{zserver} ne $curr_zserver) {
	    if ($firsttime) {
		$firsttime = 0;
	    } else {
		$zrec{locations} = [ @locs ];
#		#$self->log->debug("\n---------------------\n", Dumper(%zrec));
		push @z, { %zrec };
		%zrec = ();
		@locs = ();
	    }
	    $curr_zserver = $row->{zserver};
	    $zrec{zserver} = $row->{zserver};
	    $zrec{zserver_count} = $row->{zserver_count};
	}

	$loc_hash{loc} = $row->{loc};
	$loc_hash{loc_count} = $row->{loc_count};
#	$self->log->debug("\n---------------------\n", Dumper(\%loc_hash));
	push @locs, \%loc_hash;
    }
    $zrec{locations} = [ @locs ];
#    $self->log->debug("\n---------------------\n", Dumper(\%zrec));
    push @z, { %zrec };
    $self->log->debug(Dumper(@z));

    my $template = $self->load_tmpl('admin/reports/ILL_stats.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin Reports ILL stats',
		     username => $self->authen->username,
		     sent => $hr_sum_of_sent->{sent},
		     by_user => $ar_user,
		     received => $hr_sum_of_received->{received},
#		     by_zserver => $ar_zservers,
		     by_location => $ar_locations,
		     details => \@z,
		     net => $ar_net,
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub admin_reports_ILL_requests_process {
    my $self = shift;
    my $q = $self->query;

    my $report = $q->param('report') || 'borrower';
    my $period = $q->param('period') || 'today';
#   my $sendto = $q->param('sendto') || 'screen';
    my $gen    = $q->param('gen');

    my $template;
    my $pagetitle;

    if ($gen) {
	my $SQL_selectPhrase;
	my $SQL_groupPhrase;
	my $SQL_total = "select count(i.ts) as total_reqs from libraries u, zservers z, ill_stats i where u.lid = i.lid and z.id = i.zid ";

	if ($report eq 'borrower') {
	    # borrower report
	    $SQL_selectPhrase = "select l.library as source, z.name as target, i.location, count(i.ts) as num_req from libraries l, zservers z, ill_stats i where l.lid = i.lid and z.id = i.zid ";
	    $SQL_groupPhrase  = "group by l.library, z.name, i.location order by l.library, z.name, i.location";
	    $template = $self->load_tmpl('admin/reports/ILL_borrowers_report.tmpl');
	    $pagetitle = 'Maplin-3 Admin Reports ILL Borrowers';
	} else {
	    # lender report
	    $SQL_selectPhrase = "select z.name as target, i.location, l.library as source, count(i.ts) as num_req from libraries l, zservers z, ill_stats i where l.lid = i.lid and z.id = i.zid ";
	    $SQL_groupPhrase  = "group by z.name, i.location, l.library order by z.name, i.location, l.library";
	    $template = $self->load_tmpl('admin/reports/ILL_lenders_report.tmpl');
	    $pagetitle = 'Maplin-3 Admin Reports ILL Lenders';
	}
	
	my $SQL_periodPhrase;
	if ($period eq 'today') {
	    $SQL_periodPhrase = "and extract(doy from i.ts) = extract(doy from current_date) ";
	} elsif ($period eq 'yesterday') {
	    $SQL_periodPhrase = "and extract(doy from i.ts) = extract(doy from (current_date - interval '1 day')) ";
	} elsif ($period eq 'thisweek') {
	    $SQL_periodPhrase = "and extract(week from i.ts) = extract(week from current_date) ";
	} elsif ($period eq 'lastweek') {
	    $SQL_periodPhrase = "and extract(week from i.ts) = extract(week from (current_date - interval '7 days')) ";
	} elsif ($period eq 'thismonth') {
	    $SQL_periodPhrase = "and extract(year from i.ts) = extract(year from current_date) and extract(month from i.ts) = extract(month from current_date) ";
	} elsif ($period eq 'lastmonth') {
	    $SQL_periodPhrase = "and extract(year from i.ts) = extract(year from current_date) and extract(month from i.ts) = extract(month from (current_date - interval '1 month')) ";
	} elsif ($period eq 'all') {
	    # since inception
	    $SQL_periodPhrase = "";
	} else {
	    # since inception
	    $SQL_periodPhrase = "";
	}
	
	my $SQL = $SQL_selectPhrase . $SQL_periodPhrase . $SQL_groupPhrase;
	my $rows = $self->dbh->selectall_arrayref(
	    $SQL,
	    { Slice => {} }
	    );

	$SQL_total = $SQL_total . $SQL_periodPhrase;
	my $total = $self->dbh->selectrow_arrayref( $SQL_total );
	
	my $now_string = strftime "%a %b %e %H:%M:%S %Y", localtime;

	$period =~ s/this/this /;

	$template->param(
	    pagetitle => $pagetitle,
	    period => $period,
	    rows => $rows,
	    total_reqs => $total->[0],
	    gendate => $now_string,
	    );

    } else {
	# just show the selection form
	$template = $self->load_tmpl('admin/reports/ILL_requests_choose_report.tmpl');
	$template->param(pagetitle => 'Maplin-3 Admin Reports ILL Requests Choose');
    }

    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub admin_reports_zServers_down_process {
    my $self = shift;

    my $ar_zServers_down = $self->dbh->selectall_arrayref(
	"select id, name, z3950_connection_string, email_address, available, alive, holdings_tag, holdings_location, holdings_callno, holdings_avail, holdings_collection, holdings_due from zservers where (available <> 1) or (alive <> 1) order by name",
	{ Slice => {} },
	);

    my $template = $self->load_tmpl('admin/reports/zServers_down.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin Reports zServers down',
		     username => $self->authen->username,
		     zServers_down => $ar_zServers_down,
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub reports_home_zServers_process {
    my $self = shift;

    $self->log->debug("is_authz_runmode ? " . $self->authz->is_authz_runmode('reports_home_zServers_form'));
    $self->log->debug("authz_username   : " . $self->authz->username);
#    $self->log->debug( $self->authz->authorize('admin') );

#    return $self->authz->redirect_to_forbidden;

#    if ($self->authz->authorize('reports')) {
#	$self->log->debug('authorize(reports) ok');
#    } else {
#	$self->log->debug('authorize(reports) not ok');
#    }

#    return $self->authz->forbidden;

#    return $self->authz->forbidden unless $self->authz->authorize('reports');

    my $ar_home_zservers = $self->dbh->selectall_arrayref(
	"select z.name as zserver, l.name as user from zservers z, libraries l where z.id=l.home_zserver_id order by z.name, l.name",
	{ Slice => {} },
	);
    
    my $template = $self->load_tmpl('admin/reports/home_zservers.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin Reports home zServers',
		     username => $self->authen->username,
		     by_library => $ar_home_zservers,
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub admin_reports_last_logins_process {
    my $self = shift;

    my $ar_last_logins = $self->dbh->selectall_arrayref(
	"select lid, name, library, last_login from libraries where last_login is not null order by name",
	{ Slice => {} },
	);
    
    my $template = $self->load_tmpl('admin/reports/last_logins.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin Reports last logins',
		     username => $self->authen->username,
		     last_logins => $ar_last_logins,
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub admin_reports_never_logged_in_process {
    my $self = shift;

    my $ar_never_logged_in = $self->dbh->selectall_arrayref(
	"select lid, name, library from libraries where last_login is null order by name",
	{ Slice => {} },
	);
    
    my $template = $self->load_tmpl('admin/reports/never_logged_in.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin Reports never logged in',
		     username => $self->authen->username,
		     never_logged_in => $ar_never_logged_in,
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub admin_reports_table_stats_process {
    my $self = shift;

    my @tblstats;
    my @tbls = qw(marc status_check search_pid);
    foreach my $tbl (@tbls) {
        # Doesn't like ? for table name....
	my $SQL = "select count(*) from $tbl";
	my $tblstat = $self->dbh->selectrow_arrayref(
	    $SQL,
	    );
	if ($tblstat) {
	    push @tblstats, { 'table' => $tbl,
			      'count' => $tblstat->[0] 
	    };
	} else {
	    push @tblstats, { 'table' => $tbl,
			      'count' => "error" 
	    };
	}
    }
    
    my $template = $self->load_tmpl('admin/reports/table_stats.tmpl');
    $template->param(pagetitle => 'Maplin-3 Admin Reports table stats',
		     username => $self->authen->username,
		     table_stats => \@tblstats,
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub admin_CDT_find_process {
    my $self = shift;
    my $q = $self->query;
    my $href;
    my $message = "";
    my $ok;

    my $template = $self->load_tmpl(	    
	                      'admin/CDT_find.tmpl',
			      cache => 0,
			     );	
    if ($q->param('barcode')) {
	$href = $self->dbh->selectrow_hashref(
	    "SELECT callno, pubdate, author, title, claimed_by FROM zerocirc WHERE barcode=?", 
	    undef,
	    $q->param('barcode')
	    );
    }
    $template->param( pagetitle => 'Maplin-3 Admin CDT Find',
		      username => $self->authen->username,
		      callno => $href->{callno},
		      pubdate => $href->{pubdate},
		      author => $href->{author},
		      title => $href->{title},
		      claimed_by => $href->{claimed_by} || "nobody",
		      message => $href->{callno} ? "This is a CDT item." : "NOT a CDT item."
	);
    # Parse the template
    my $html_output = $template->output;
    return $html_output;
}


#--------------------------------------------------------------------------------
#
#
sub admin_CDT_ClaimByBarcode_process {
    my $self = shift;
    my $q = $self->query;
    my $href;
    my $message = "";
    my $status = "";
    my $ok;
    my $name = $q->param('name') || "UCN";

    my $template = $self->load_tmpl(	    
	                      'admin/CDT_ClaimByBarcode.tmpl',
			      cache => 0,
			     );	

    if ($q->param('barcode')) {
	$self->log->debug("barcode: " . $q->param('barcode'));
	$href = $self->dbh->selectrow_hashref(
	    "SELECT id, callno, pubdate, author, title, claimed_by FROM zerocirc WHERE barcode=?", 
	    undef,
	    $q->param('barcode')
	    );

	if ($href->{'id'}) {
	    my $id = $href->{'id'};
	    $self->log->debug("id: " . $id);

	    # In MySQL, setting a timestamp field to NULL sets it to the current timestamp
	    $ok = $self->dbh->do("UPDATE zerocirc SET claimed_by=?, claimed_timestamp=NULL WHERE id=? and claimed_by is null",
				 undef,
				 $name,
				 $id
		);

	    if (1 == $ok) {
		$status = "Successfully claimed.";
		$self->log->debug("claimed.");
	    } else {
		$status = "Could not be claimed.";
		$ok = 0; # because mysql actually returns '0E0'
		$self->log->debug("could not be claimed.");
	    }
	    
	    $href = $self->dbh->selectrow_hashref(
		"SELECT id, callno, pubdate, author, title, claimed_by, claimed_timestamp FROM zerocirc WHERE id=?", 
		undef,
		$id
		);
	} else {
	    $self->log->debug("no id found");
	}
	
    }

    $template->param( pagetitle => 'Maplin-3 Admin CDT ClaimByBarcode',
		      username => $self->authen->username,
		      ok => $ok,
		      name => $name,
		      callno => $href->{callno},
		      pubdate => $href->{pubdate},
		      author => $href->{author},
		      title => $href->{title},
		      claimed_by => $href->{claimed_by} || "nobody",
		      message => $href->{callno} ? "This is a CDT item." : "NOT a CDT item.",
		      status => $status
	);
    # Parse the template
    my $html_output = $template->output;
    return $html_output;
}


#--------------------------------------------------------------------------------
#
#
sub admin_actions_clear_old_data_process {
    my $self = shift;

#    $self->dbh->do("delete from marc where ts < subtime(now(),'01:00:00')");
#    $self->dbh->do("delete from status_check where ts < subtime(now(),'01:00:00')");
    $self->dbh->do("delete from marc where ts < (now() - interval '1 hour')");
    $self->dbh->do("delete from status_check where ts < (now() - interval '1 hour')");

    return $self->admin_reports_table_stats_process();
}


#--------------------------------------------------------------------------------
#
#
sub admin_reports_ILL_graphs_process {
    my $self = shift;
    my $q = $self->query;

    my $user   = $q->param('user') || 'MSEL';
    my $period = $q->param('period') || 'thisweek';
    my $cumulative = $q->param('cumulative');
    my $gen    = $q->param('gen');

    my $template;


    if ($gen) {
	my @data;
	my $dt = DateTime->now;
	my $dt_start;
	my $dt_end;

	my $SQL_selectPhrase_loaned = "select DATE(i.ts) as d, COUNT(DATE(i.ts)) as c from ill_stats i, libraries l where l.name=? and i.zid=l.home_zserver_id and l.home_zserver_location=i.location ";
	my $SQL_selectPhrase_borrowed = "select DATE(i.ts) as d, COUNT(DATE(i.ts)) as c from ill_stats i, libraries l where l.name=? and i.lid=l.lid ";
	my $SQL_groupPhrase = " group by DATE(i.ts)";
	my $SQL_periodPhrase;

	if ($period eq 'thisweek') {
	    $SQL_periodPhrase = "and extract(year from i.ts) = extract(year from current_date) and extract(week from i.ts) = extract(week from current_date) ";
	    $dt_start = $dt->clone->subtract( days => $dt->day_of_week );
	    $dt_end   = $dt_start->clone->add( days => 7 );
	} elsif ($period eq 'lastweek') {
	    $SQL_periodPhrase = "and extract(year from i.ts) = extract(year from current_date) and extract(week from i.ts) = extract(week from (current_date - interval '7 days')) ";
	    $dt_start = $dt->clone->subtract( days => 7 + $dt->day_of_week );
	    $dt_end   = $dt_start->clone->add( days => 7 );
	} elsif ($period eq 'thismonth') {
	    $SQL_periodPhrase = "and extract(year from i.ts) = extract(year from current_date) and extract(month from i.ts) = extract(month from current_date) ";
	    $dt_start = $dt->clone->subtract( days => $dt->day );
	    $dt_end   = $dt_start->clone->add( months => 1 )->subtract( days => 1 );
	} elsif ($period eq 'lastmonth') {
	    $SQL_periodPhrase = "and extract(year from i.ts) = extract(year from current_date) and extract(month from i.ts) = extract(month from (current_date - interval '1 month')) ";
	    $dt_start = $dt->clone->subtract( months => 1, days => $dt->day );
	    $dt_end   = $dt_start->clone->add( months => 1 )->subtract( days => 1 );
	} elsif ($period eq 'all') {
	    # since inception
	    $SQL_periodPhrase = "";
	} else {
	    # since inception
	    $SQL_periodPhrase = "";
	}

	my $SQL_loaned   = $SQL_selectPhrase_loaned . $SQL_periodPhrase . $SQL_groupPhrase;
	my $SQL_borrowed = $SQL_selectPhrase_borrowed . $SQL_periodPhrase . $SQL_groupPhrase;

	my $rows_loaned   = $self->dbh->selectall_hashref( $SQL_loaned, "d", undef, $user );
	my $rows_borrowed = $self->dbh->selectall_hashref( $SQL_borrowed, "d", undef, $user );

	my $SQL_total_loaned = "select COUNT(i.ts) as total from ill_stats i, libraries l where l.name=? and i.zid=l.home_zserver_id and l.home_zserver_location=i.location ";
	my $SQL_total_borrowed = "select COUNT(i.ts) as total from ill_stats i, libraries l where l.name=? and i.lid=l.lid ";

	$SQL_total_loaned   = $SQL_total_loaned   . $SQL_periodPhrase;
	$SQL_total_borrowed = $SQL_total_borrowed . $SQL_periodPhrase;
	my $total_loaned   = $self->dbh->selectrow_arrayref( $SQL_total_loaned, undef, $user );
	my $total_borrowed = $self->dbh->selectrow_arrayref( $SQL_total_borrowed, undef, $user );
	
#	# debug
#	open(LOG,'>','/opt/maplin3/logs/graphing.log') or die $!;
#	print LOG $SQL_borrowed . "\n";
#	foreach my $key ( sort keys %$rows ) {
#	    print LOG "$key: $rows->{$key}->{c}\n";
#	}
#	close LOG;
	
	$period =~ s/this/this /;
	$period =~ s/last/last /;

	my $range_start_string = $dt_start->strftime( "%F" );
	my $range_end_string   = $dt_end->strftime( "%F" );
	my @xaxis;
	my @dataset_loaned;
	my @dataset_borrowed;
	my @dataset_net;
	my $max_loan = 0;
	my $max_borr = 0;
	my $cumulative_loan = 0;
	my $cumulative_borr = 0;
	while ($dt_start <= $dt_end) {
	    my $loan = $rows_loaned->{   $dt_start->strftime( "%F" ) }->{c} || 0;
	    my $borr = $rows_borrowed->{ $dt_start->strftime( "%F" ) }->{c} || 0;

	    $cumulative_loan += $loan;
	    $cumulative_borr += $borr;

	    push @xaxis, $dt_start->strftime( "%F" );
	    if ($cumulative) {
		push @dataset_loaned, $cumulative_loan;
		push @dataset_borrowed, 0 - $cumulative_borr;
		push @dataset_net, $cumulative_loan - $cumulative_borr;
	    } else {
		push @dataset_loaned, $loan;
		push @dataset_borrowed, 0 - $borr;
		push @dataset_net, $loan - $borr;
	    }

	    if ($loan > $max_loan) {
		$max_loan = $loan;
	    }
	    if ($borr > $max_borr) {
		$max_borr = $borr;
	    }
	    $dt_start = $dt_start->add( days => 1 );
	}
	push @data, [ @xaxis ];
	push @data, [ @dataset_loaned ];
	push @data, [ @dataset_borrowed ];
	push @data, [ @dataset_net ];

	# debug
#	open(LOG,'>','/opt/maplin3/logs/graphing.log') or die $!;
#	print LOG Dumper(@data);
#	close LOG;

	my $graph = GD::Graph::lines->new(600,400);
	my $y_label_skip = int(($cumulative ? ($cumulative_loan + $cumulative_borr) : ($max_loan + $max_borr)) / 10);
	$graph->set(
	    x_label       => $period,
	    y_label       => 'transactions',
	    title         => $cumulative ? 'Cumulative Interlibrary Loan Requests' : 'Interlibrary Loan Requests',
	    y_max_value   => $cumulative ? $cumulative_loan : $max_loan,
	    y_min_value   => $cumulative ? ( 0 - $cumulative_borr ) : (0 - $max_borr),
	    y_tick_number => $cumulative ? ($cumulative_loan + $cumulative_borr) : ($max_loan + $max_borr),
	    y_label_skip  => $y_label_skip,
	    x_labels_vertical => 1,
	    zero_axis     => 1,
	    ) or die $graph->error;
	my @legend_keys = qw/loaned borrowed net/;
	$graph->set_legend( @legend_keys );

	my $gd = $graph->plot(\@data) or die $graph->error;
	my $filename = "/opt/maplin3/htdocs/tmp/graph$$";
	$gd->can('png') ? $filename .= '.png' : $filename .= '.gif';
	open(IMG, '>', $filename) or die $!;
	binmode IMG;
	my $image = $gd->can('png') ? $gd->png : $gd->gif; 
	print IMG $image;
	close IMG;


	my $now_string = strftime "%a %b %e %H:%M:%S %Y", localtime;
	$filename =~ s|/opt/maplin3/htdocs||;
	$template = $self->load_tmpl('admin/reports/ILL_graphs_report.tmpl');
	$template->param(
	    pagetitle => 'Maplin-3 Admin Reports ILL Graphs',
	    library => $user,
	    period => $period,
	    filename => $filename,
	    total_loaned   => $total_loaned->[0],
	    total_borrowed => $total_borrowed->[0],
	    gendate => $now_string,
	    );

    } else {
	# just show the selection form
	my $ar_users = $self->dbh->selectall_arrayref(
	    "SELECT name as user_name, library as user_library from libraries ORDER by library",
	    { Slice => {} }
	    );

	$template = $self->load_tmpl('admin/reports/ILL_graphs_choose_report.tmpl');
	$template->param(
	    pagetitle => 'Maplin-3 Admin Reports ILL Graphs Choose',
	    users => $ar_users
	    );
    }

    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub admin_reports_ILL_pie_process {
    my $self = shift;
    my $q = $self->query;

    my $period = $q->param('period') || 'thisweek';
    my $gen    = $q->param('gen');

    my $template;

    if ($gen) {
	my $dt = DateTime->now;
	my $dt_start;
	my $dt_end;

	my $SQL_pieSize = "select COUNT(*) as pieSize from ill_stats i ";

	my $SQL_selectPhrase_loaned = "select distinct z.name as library, COUNT(DATE(i.ts)) as c from ill_stats i, libraries l, zservers z where i.zid=l.home_zserver_id and z.id = i.zid ";

	my $SQL_selectPhrase_borrowed = "select l.name as library, COUNT(*) as c from ill_stats i, libraries l where i.lid=l.lid ";
	my $SQL_loaned_groupPhrase = " group by z.name";
	my $SQL_borrowed_groupPhrase = " group by l.name";
	my $SQL_periodPhrase;

	if ($period eq 'thisweek') {
	    $SQL_periodPhrase = "and extract(week from i.ts) = extract(week from current_date) ";
	    $dt_start = $dt->clone->subtract( days => $dt->day_of_week );
	    $dt_end   = $dt_start->clone->add( days => 7 );
	} elsif ($period eq 'lastweek') {
	    $SQL_periodPhrase = "and extract(week from i.ts) = extract(week from (current_date - interval '7 days')) ";
	    $dt_start = $dt->clone->subtract( days => 7 + $dt->day_of_week );
	    $dt_end   = $dt_start->clone->add( days => 7 );
	} elsif ($period eq 'thismonth') {
	    $SQL_periodPhrase = "and extract(year from i.ts) = extract(year from current_date) and extract(month from i.ts) = extract(month from current_date) ";
	    $dt_start = $dt->clone->subtract( days => $dt->day );
	    $dt_end   = $dt_start->clone->add( months => 1 )->subtract( days => 1 );
	} elsif ($period eq 'lastmonth') {
	    $SQL_periodPhrase = "and extract(year from i.ts) = extract(year from current_date) and extract(month from i.ts) = extract(month from (current_date - interval '1 month')) ";
	    $dt_start = $dt->clone->subtract( months => 1, days => $dt->day );
	    $dt_end   = $dt_start->clone->add( months => 1 )->subtract( days => 1 );
	} elsif ($period eq 'all') {
	    # since inception
	    $SQL_periodPhrase = "";
	} else {
	    # since inception
	    $SQL_periodPhrase = "";
	}

	my $SQL_loaned   = $SQL_selectPhrase_loaned . $SQL_periodPhrase . $SQL_loaned_groupPhrase;
	my $SQL_borrowed = $SQL_selectPhrase_borrowed . $SQL_periodPhrase . $SQL_borrowed_groupPhrase;

	my $rows_loaned   = $self->dbh->selectall_hashref( $SQL_loaned, "library" );
	my $rows_borrowed = $self->dbh->selectall_hashref( $SQL_borrowed, "library" );

	my $SQL_piePeriod = $SQL_periodPhrase;
	$SQL_piePeriod =~ s/^and /where /;
	$SQL_pieSize = $SQL_pieSize . $SQL_piePeriod;

	my $pieSize = $self->dbh->selectrow_arrayref( $SQL_pieSize );

	$period =~ s/this/this /;
	$period =~ s/last/last /;

#	my $range_start_string = $dt_start->strftime( "%F" );
#	my $range_end_string   = $dt_end->strftime( "%F" );

	my @dataset_loaned;
	my @xaxis_loaned;
	foreach my $lib ( sort keys %$rows_loaned ) {
	    push @xaxis_loaned, "$lib (" . $rows_loaned->{$lib}->{c} . ")";
	    push @dataset_loaned, $rows_loaned->{$lib}->{c};
	}
	my @dataLoan;
	push @dataLoan, [ @xaxis_loaned ];
	push @dataLoan, [ @dataset_loaned ];

	my @dataset_borrowed;
	my @xaxis_borrowed;
	foreach my $lib ( sort keys %$rows_borrowed ) {
	    push @xaxis_borrowed, "$lib (" . $rows_borrowed->{$lib}->{c} . ")";
	    push @dataset_borrowed, $rows_borrowed->{$lib}->{c};
	}
	my @dataBorr;
	push @dataBorr, [ @xaxis_borrowed ];
	push @dataBorr, [ @dataset_borrowed ];

#	my @dataset_net;
#	my @dataNet;
#	push @dataNet,  [ @dataset_net ];


	my $graph = GD::Graph::pie->new(800,600);
	$graph->set(
	    title => "Loaned",
	    suppress_angle => 5,
	    label => "Slices less than 5 degrees are not labeled",
	    ) or die $graph->error;
	my $gd = $graph->plot(\@dataLoan) or die $graph->error . "<br>\n$SQL_loaned";
	my $filename_loaned = "/opt/maplin3/htdocs/tmp/graph_pieLoan$$";
	$gd->can('png') ? $filename_loaned .= '.png' : $filename_loaned .= '.gif';
	open(IMG, '>', $filename_loaned) or die $!;
	binmode IMG;
	my $image = $gd->can('png') ? $gd->png : $gd->gif; 
	print IMG $image;
	close IMG;

	$graph = GD::Graph::pie->new(800,600);
	$graph->set(
	    title => "Borrowed",
	    suppress_angle => 5,
	    label => "Slices less than 5 degrees are not labeled",
	    ) or die $graph->error;
	$gd = $graph->plot(\@dataBorr) or die $graph->error;
	my $filename_borrowed = "/opt/maplin3/htdocs/tmp/graph_pieBorr$$";
	$gd->can('png') ? $filename_borrowed .= '.png' : $filename_borrowed .= '.gif';
	open(IMG, '>', $filename_borrowed) or die $!;
	binmode IMG;
	$image = $gd->can('png') ? $gd->png : $gd->gif; 
	print IMG $image;
	close IMG;

#	$graph = GD::Graph::pie->new(600,400);
#	$gd = $graph->plot(\@dataNet) or die $graph->error;
#	my $filename_net = "/opt/maplin3/htdocs/tmp/graph_pieNet$$.png";
#	open(IMG, '>', $filename_net) or die $!;
#	binmode IMG;
#	print IMG $gd->png;
#	close IMG;


	my $now_string = strftime "%a %b %e %H:%M:%S %Y", localtime;

	$filename_loaned   =~ s|/opt/maplin3/htdocs||;
	$filename_borrowed =~ s|/opt/maplin3/htdocs||;
#	$filename_net      =~ s|/opt/maplin3/htdocs||;

	$template = $self->load_tmpl('admin/reports/ILL_pie_report.tmpl');
	$template->param(
	    pagetitle => 'Maplin-3 Admin Reports ILL Pie',
	    period => $period,
	    filename_loaned => $filename_loaned,
	    filename_borrowed => $filename_borrowed,
#	    filename_net => $filename_net,
	    transactions => $pieSize->[0],
	    gendate => $now_string,
	    );

    } else {
	# just show the selection form
	$template = $self->load_tmpl('admin/reports/ILL_pie_choose_report.tmpl');
	$template->param( pagetitle => 'Maplin-3 Admin Reports ILL Pie Choose' );
    }

    return $template->output;
}


1; # so the 'require' or 'use' succeeds
