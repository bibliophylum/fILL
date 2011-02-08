package maplin3::myaccount;
use strict;
use base 'maplin3base';
use ZOOM;
use MARC::Record;
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
	'myaccount_zserver_form'     => 'myaccount_zserver_process',
	'myaccount_locations_form'   => 'myaccount_locations_process',
	'myaccount_status_form'      => 'myaccount_status_process',
	'myaccount_LocalUse_form'    => 'myaccount_LocalUse_process',
	'myaccount_ebsco_form'       => 'myaccount_ebsco_process',
	'myaccount_institutioncards_form' => 'myaccount_institutioncards_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub myaccount_settings_process {
    my $self = shift;
    my $q = $self->query;

    my $SQL_getUser = "SELECT lid, name, password, email_address, library, mailing_address_line1, mailing_address_line2, mailing_address_line3, use_standardresource, use_databaseresource, use_electronicresource, use_webresource FROM libraries WHERE name=?";

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
    my $use_standardresource = $q->param("standard") ? 1 : 0;
    my $use_databaseresource = $q->param("database") ? 1 : 0;
    my $use_electronicresource = $q->param("ebook") ? 1 : 0;
    my $use_webresource = $q->param("web") ? 1 : 0;

    # If the user has clicked the 'update' button, $lid will be defined
    # (the user is submitting a change)
    if (defined $lid) {

	$self->log->debug("MyAccount:Settings: Updating lid [$lid], name [$name]");

	$self->dbh->do("UPDATE libraries SET name=?, password=?, email_address=?, library=?, mailing_address_line1=?, mailing_address_line2=?, mailing_address_line3=?, use_standardresource=?, use_databaseresource=?, use_electronicresource=?, use_webresource=? WHERE lid=?",
		       undef,
		       $name,
		       $password,
		       $email_address,
		       $library,
		       $mailing_address_line1,
		       $mailing_address_line2,
		       $mailing_address_line3,
		       $use_standardresource,
		       $use_databaseresource,
		       $use_electronicresource,
		       $use_webresource,
		       $lid
	    );

	$status = "Updated.";
	$self->_set_header_to_get_fresh_page();

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
    $template->param(username     => $self->authen->username,
	             status       => $status,
		     editLID      => $href->{lid},
		     editName     => $href->{name},
		     editPassword => $href->{password},
		     editEmail    => $href->{email_address},
		     editLibrary  => $href->{library},
		     editMailingAddressLine1 => $href->{mailing_address_line1},
		     editMailingAddressLine2 => $href->{mailing_address_line2},
		     editMailingAddressLine3 => $href->{mailing_address_line3},
		     use_standardresource => $href->{use_standardresource},
		     use_databaseresource => $href->{use_databaseresource},
		     use_electronicresource => $href->{use_electronicresource},
		     use_webresource => $href->{use_webresource}
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub myaccount_zserver_process {
    my $self = shift;
    my $q = $self->query;

    my $status;

    # Get any parameter data (ie - user is submitting a change)
    my $id = $q->param("id"); # zserver id
    my $name = $q->param("name");
    my $z3950_connection_string = $q->param("z3950_connection_string");
    my $email_address = $q->param("email_address");
    my $available = $q->param("available");
    my $holdings_tag = $q->param("holdings_tag");
    my $holdings_location = $q->param("holdings_location");
    my $holdings_callno = $q->param("holdings_callno");
    my $holdings_avail = $q->param("holdings_avail");
    my $holdings_collection = $q->param("holdings_collection");
    my $holdings_due = $q->param("holdings_due");

    # If the user has clicked the 'update' button, $id will be defined
    # (the user is submitting a change)
    if (defined $id) {

	$self->log->debug("MyAccount:zServer: Updating ztarget for id [$id], name [$name]");

	$self->dbh->do("UPDATE zservers SET name=?, z3950_connection_string=?, email_address=?, available=?, holdings_tag=?, holdings_location=?, holdings_callno=?, holdings_avail=?, holdings_collection=?, holdings_due=? WHERE id=?",
		       undef,
		       $name,
		       $z3950_connection_string,
		       $email_address,
		       $available,
		       $holdings_tag,
		       $holdings_location,
		       $holdings_callno,
		       $holdings_avail,
		       $holdings_collection,
		       $holdings_due,
		       $id
	    );
	$status = "Updated.";
	$self->_set_header_to_get_fresh_page();
    }

    # Get the form data
    my $SQL = "select l.lid, l.name as username, z.id, z.name, z.z3950_connection_string, z.email_address, z.available, z.holdings_tag, z.holdings_location, z.holdings_callno, z.holdings_avail, z.holdings_collection, z.holdings_due from libraries l join library_zserver lz on l.lid=lz.lid join zservers z on lz.zid=z.id where l.name=?";
    my $href = $self->dbh->selectrow_hashref(
	$SQL,
	{},
	$self->authen->username,
	);
    if ($href) {
	$self->log->debug("MyAccount:zServer: Edit target [$href->{id}] for user id [$href->{lid}]");
    }
    
    $status = "Editing in process." unless $status;

    my $template = $self->load_tmpl('myaccount/zserver.tmpl');
    $template->param(username => $self->authen->username,
		     status               => $status,
		     has_zserver          => $href->{id} ? 1 : 0,
		     editID               => $href->{id},
		     editName             => $href->{name},
		     editConn             => $href->{z3950_connection_string},
		     editEmail            => $href->{email_address},
		     editAvailable        => $href->{available},
		     editHoldingsTag      => $href->{holdings_tag},
		     editHoldingsLocation => $href->{holdings_location},
		     editHoldingsCollection => $href->{holdings_collection},
		     editHoldingsCallno   => $href->{holdings_callno},
		     editHoldingsAvail    => $href->{holdings_avail},
		     editHoldingsDue      => $href->{holdings_due},
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub myaccount_locations_process {
    my $self = shift;
    my $q = $self->query;

    my $SQL_getLocationsList = "select loc.zid, loc.location, loc.name, loc.email_address from libraries l join library_zserver lz on l.lid=lz.lid join locations loc on lz.zid=loc.zid where l.name=?";

    my $status = "Select a location / branch to edit...";

    my $ar_locs = $self->dbh->selectall_arrayref(
	$SQL_getLocationsList,
	{ Slice => {} },
	$self->authen->username
	);

    my %edit;

    my $locSelected = $q->param("loc");
    my $location = $q->param("location");
    my $name = $q->param("name");
    my $email_address = $q->param("email_address");
    my $new_location = $q->param("new_location");
    my $delete_location = $q->param("delete_location");

    if (defined $locSelected) {

	# User has chosen a new location to edit from the list

	$self->log->debug("MyAccount:Locations: Edit location [$locSelected]");

	# Find the array element (hash) where locSelected matches {location}
	foreach my $href (@$ar_locs) {
	    if ($href->{location} eq $locSelected) {
		$edit{zid}           = $href->{zid};
		$edit{location}      = $href->{location};
		$edit{name}          = $href->{name};
		$edit{email_address} = $href->{email_address};
		$self->log->debug("MyAccount:Locations: Edit location:$href->{location}, name:$href->{name}, email_address:$href->{email_address} (zid:$href->{zid})");
		last;
	    }
	}

	$status = "Editing in process.";
	$self->_set_header_to_get_fresh_page();

    } elsif (defined $new_location) {

	# Get the zserver_id associated with this user
	# (assumption: if you get here, you are the "head" library of a region)
	my $href = $self->dbh->selectrow_hashref(
	    "SELECT l.lid, l.name, lz.zid from libraries l JOIN library_zserver lz ON l.lid=lz.lid WHERE l.name=?",
	    undef,
	    $self->authen->username
	    );

	$self->log->debug("MyAccount:Locations: zserver [" . $href->{zid} . "], New location [$location]");

	$self->dbh->do("INSERT INTO locations (zid, location, name, email_address) VALUES (?,?,?,?)",
		       undef,
		       $href->{zid},
		       $location,
		       $name,
		       $email_address
	    );

	$status = "Added.  Select a location to edit...";
	$self->_set_header_to_get_fresh_page();

	# Get the locations list again.
	$ar_locs = $self->dbh->selectall_arrayref(
	    $SQL_getLocationsList,
	    { Slice => {} },
	    $self->authen->username
	    );

    } elsif (defined $delete_location) {

	# Get the zserver_id associated with this user
	# (assumption: if you get here, you are the "head" library of a region)
	my $href = $self->dbh->selectrow_hashref(
	    "SELECT l.lid, l.name, lz.zid from libraries l JOIN library_zserver lz ON l.lid=lz.lid WHERE l.name=?",
	    undef,
	    $self->authen->username
	    );

	$self->log->debug("MyAccount:Locations: zserver [" . $href->{zid} . ", Delete location [$delete_location]");

	$self->dbh->do("DELETE FROM locations WHERE zid=? AND location=?",
		       undef,
		       $href->{zid},
		       $delete_location
	    );

	$status = "Deleted.  Select a user to edit...";
	$self->_set_header_to_get_fresh_page();

	# Get the locations list again.
	$ar_locs = $self->dbh->selectall_arrayref(
	    $SQL_getLocationsList,
	    { Slice => {} },
	    $self->authen->username
	    );

    } elsif (defined $location) {

	# Get the zserver id associated with this library
	# (assumption: if you get here, you are the "head" library of a region)
	my $href = $self->dbh->selectrow_hashref(
	    "SELECT l.lid, l.name, lz.zid from libraries l JOIN library_zserver lz ON l.lid=lz.lid WHERE l.name=?",
	    undef,
	    $self->authen->username
	    );

	$self->log->debug("MyAccount:Locations: Updating location [$location], name [$name] (zid [$href->{zid}])");

	$self->dbh->do("UPDATE locations SET name=?, email_address=? WHERE zid=? AND location=?",
		       undef,
		       $name,
		       $email_address,
		       $href->{zid},
		       $location
	    );

	$status = "Updated.  Select a user to edit...";
	$self->_set_header_to_get_fresh_page();

	# Get the locations list again.
	$ar_locs = $self->dbh->selectall_arrayref(
	    $SQL_getLocationsList,
	    { Slice => {} },
	    $self->authen->username
	    );
    }

    my @locations = sort { $a->{location} cmp $b->{location} } @$ar_locs;

    my $template = $self->load_tmpl('myaccount/locations.tmpl');
    # note - the has_zserver bit resolves to TRUE if there was *anything* returned.
    $template->param(username => $self->authen->username,
		     has_zserver  => $ar_locs->[0]->{zid} ? 1 : 0,
		     locSelected  => $locSelected,
		     locations    => \@locations,
		     status       => $status,
		     editLocation => $edit{location},
		     editName     => $edit{name},
		     editEmail    => $edit{email_address},
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub myaccount_LocalUse_process {
    my $self = shift;
    my $q = $self->query;
    my $ar_nfl;
    my $has_zserver = 0;

    my $SQL = "select l.lid, l.name as username, z.id as zid from libraries l join library_zserver lz on l.lid=lz.lid join zservers z on lz.zid=z.id where l.name=?";
    my $href = $self->dbh->selectrow_hashref(
	$SQL,
	{},
	$self->authen->username,
	);

    if ($href->{'zid'}) {
	$has_zserver = 1;

	if ($q->param('add')) {
	    if ($q->param('tag') && $q->param('subfield') && $q->param('text')) {
		my $SQL = "INSERT INTO notforloan (zid,tag,subfield,text,atstart) VALUES (?,?,?,?,?)";
		
		$self->dbh->do($SQL,
			       undef,
			       $href->{'zid'},
			       $q->param('tag'),
			       $q->param('subfield'),
			       $q->param('text'),
			       $q->param('atstart') ? 1 : 0,
		    );
	    } elsif ($q->param('tag') && $q->param('text') && ($q->param('tag') lt '010')) {
		# control field
		my $SQL = "INSERT INTO notforloan (zid,tag,text,atstart) VALUES (?,?,?,?)";
		
		$self->dbh->do($SQL,
			       undef,
			       $href->{'zid'},
			       $q->param('tag'),
			       $q->param('text'),
			       $q->param('atstart') ? 1 : 0,
		    );
	    }
	}

	if ($q->param('delete')) {
	    if ($q->param('tag') && $q->param('subfield') && $q->param('text')) {
		my $SQL = "DELETE FROM notforloan WHERE zid=? and tag=? and subfield=? and text=?";
		
		$self->dbh->do($SQL,
			       undef,
			       $href->{'zid'},
			       $q->param('tag'),
			       $q->param('subfield'),
			       $q->param('text'),
		    );
	    } elsif ($q->param('tag') && $q->param('text') && ($q->param('tag') lt '010')) {
		my $SQL = "DELETE FROM notforloan WHERE zid=? and tag=? and text=?";
		
		$self->dbh->do($SQL,
			       undef,
			       $href->{'zid'},
			       $q->param('tag'),
			       $q->param('text'),
		    );
	    }
	}


	
	$ar_nfl = $self->dbh->selectall_arrayref(
	    "SELECT zid, tag, subfield, text, atstart FROM notforloan WHERE zid=?",
	    { Slice => {} },
	    $href->{'zid'},
	    );
    } else {
	my @nfl = ();
	$ar_nfl = \@nfl;
    }

    my $template = $self->load_tmpl('myaccount/LocalUse.tmpl');
    $template->param(username => $self->authen->username,
		     has_zserver => $has_zserver,
		     localuse => $ar_nfl,
		     zid => $href->{'zid'},
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub myaccount_ebsco_process {
    my $self = shift;
    my $q = $self->query;

    my $SQL_getUser = "SELECT lid, name, ebsco_user, ebsco_pass from libraries WHERE name=?";

    my $edit = 1;

    # Get any parameter data (ie - user is submitting a change)
    my $lid = $q->param("lid");
    my $name = $q->param("name");
    my $ebsco_user = $q->param("ebsco_user");
    my $ebsco_pass = $q->param("ebsco_pass");


    # If the user has clicked the 'update' button, $lid will be defined
    # (the user is submitting a change)
    if (defined $lid) {

	$self->dbh->do("UPDATE libraries SET ebsco_user=?, ebsco_pass=? WHERE lid=?",
		       undef,
		       $ebsco_user,
		       $ebsco_pass,
		       $lid
	    );
	$edit = 0;
	$self->_set_header_to_get_fresh_page();
    }

    # Get the form data
    my $href = $self->dbh->selectrow_hashref(
	$SQL_getUser,
	{},
	$self->authen->username,
	);
    

    my $template = $self->load_tmpl('myaccount/ebsco.tmpl');
    $template->param(username   => $self->authen->username,
		     edit       => $edit,
		     lid        => $href->{lid},
		     ebsco_user => $href->{ebsco_user},
		     ebsco_pass => $href->{ebsco_pass},
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub myaccount_institutioncards_process {
    my $self = shift;
    my $q = $self->query;

    my $SQL_getUser = "SELECT lid, name, wpl_institution_card from libraries WHERE name=?";

    my $edit = 1;

    # Get any parameter data (ie - user is submitting a change)
    my $lid = $q->param("lid");
    my $name = $q->param("name");
    my $wpl_institution_card = $q->param("wpl_institution_card");

    # If the user has clicked the 'update' button, $lid will be defined
    # (the user is submitting a change)
    if (defined $lid) {

	$self->dbh->do("UPDATE libraries SET wpl_institution_card=? WHERE lid=?",
		       undef,
		       $wpl_institution_card,
		       $lid
	    );
	$edit = 0;
	$self->_set_header_to_get_fresh_page();
    }

    # Get the form data
    my $href = $self->dbh->selectrow_hashref(
	$SQL_getUser,
	{},
	$self->authen->username,
	);
    

    my $template = $self->load_tmpl('myaccount/institutioncards.tmpl');
    $template->param(username   => $self->authen->username,
		     edit       => $edit,
		     lid        => $href->{lid},
		     wpl_institution_card => $href->{wpl_institution_card},
	);
    return $template->output;
}

#
#
#
sub _set_header_to_get_fresh_page {
    my $self = shift;

    # Get a fresh page (not from cache)!
    use POSIX qw( strftime );	
    $self->header_add(
	# date in the past
	-expires       => 'Sat, 26 Jul 1997 05:00:00 GMT',
	# always modified
	-Last_Modified => strftime('%a, %d %b %Y %H:%M:%S GMT', gmtime),
	# HTTP/1.0
	-Pragma        => 'no-cache',
	# HTTP/1.1
	-Cache_Control => join(', ', qw(
                        no-store
                        no-cache
                        must-revalidate
                        post-check=0
                        pre-check=0
                        )),
	);
}


1; # so the 'require' or 'use' succeeds

#		     atstart => $href->{'atstart'},
