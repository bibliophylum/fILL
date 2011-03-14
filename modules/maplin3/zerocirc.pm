package maplin3::zerocirc;
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
    $self->start_mode('browse_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'browse_form'                => 'browse_process',
	'browse_results_form'        => 'browse_results_process',
	'find_form'                  => 'find_process',
	'report_form'                => 'report_process',
#	'search_results_form'        => 'search_results_process',
#	'show_marc_form'             => 'show_marc_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub browse_process {
    my $self = shift;
    my $q = $self->query;

    $self->log->debug("is_authz_runmode ? " . $self->authz->is_authz_runmode('browse_form'));
    $self->log->debug("authz_username   : " . $self->authz->username);
#    $self->log->debug( $self->authz->authorize('admin') );

#    return $self->authz->redirect_to_forbidden;

#    if ($self->authz->authorize('reports')) {
#	$self->log->debug('authorize(reports) ok');
#    } else {
#	$self->log->debug('authorize(reports) not ok');
#    }


    my $SQL = "select distinct collection from zerocirc order by collection";
    $self->log->debug("SQL: $SQL");
    my $aref_collections = $self->dbh->selectall_arrayref($SQL, { Slice => {} }	);

    my $call_start;
    my $call_end;

    my $template = $self->load_tmpl(	    
	                      'zerocirc/browse.tmpl',
			      cache => 1,
			     );	
    $template->param( pagetitle => "Maplin-3 ZeroCirc Browse",
		      username => $self->authen->username,
		      sessionid => $self->session->id(),
		      collections => $aref_collections,
		      call_start => $call_start,
		      call_end => $call_end
	);
    # Parse the template
    my $html_output = $template->output;
    return $html_output;
}

#--------------------------------------------------------------------------------
#
#
sub browse_results_process {
    my $self = shift;
    my $q = $self->query;

    my $SQL;
    my $aref_browselist;

#    my $hideclaimed = $q->param('hideclaimed');

    my $order_by;
    if ($q->param('sort_pubdate')) {
	$order_by = " order by pubdate DESC, callno, title";
    } elsif ($q->param('sort_title')) {
	$order_by = " order by title, callno";
    } elsif ($q->param('sort_author')) {
	$order_by = " order by author, callno, title";
    } else {
	$order_by = " order by callno, title";
    }

    if ($q->param('call_start') && $q->param('call_end')) {
	$SQL = "select id, callno, pubdate, author, title, claimed_by from zerocirc";
	$SQL .= " where collection=?";
	$SQL .= " and callno >= ? and callno <= ?";
	$SQL .= $order_by;
	$aref_browselist = $self->dbh->selectall_arrayref(
	    $SQL, 
	    { Slice => {} },
	    $q->param('collection'),
	    $q->param('call_start'),
	    $q->param('call_end'),
	    );
	
    } else {
	$SQL = "select id, callno, pubdate, author, title, claimed_by from zerocirc";
	$SQL .= " where collection=?";
	$SQL .= $order_by;
	$aref_browselist = $self->dbh->selectall_arrayref(
	    $SQL, 
	    { Slice => {} },
	    $q->param('collection')
	    );
    }

    my $template = $self->load_tmpl(	    
	                      'zerocirc/results.tmpl',
			      cache => 0,
			     );	
    $template->param( pagetitle => "Maplin-3 ZeroCirc Results",
		      username => $self->authen->username,
#		      hideclaimed => $hideclaimed,
		      collection => $q->param('collection'),
		      call_start => $q->param('call_start'),
		      call_end => $q->param('call_end'),
		      browselist => $aref_browselist,
	);
    # Parse the template
    my $html_output = $template->output;
    return $html_output;
}


#--------------------------------------------------------------------------------
#
#
sub find_process {
    my $self = shift;
    my $q = $self->query;
    my $href;
    my $message = "";
    my $ok;

    my $template = $self->load_tmpl(	    
	                      'zerocirc/find.tmpl',
			      cache => 0,
			     );	
    if ($q->param('id')) {
#	my $timestamp = $self->dbh->do("SELECT CURRENT_TIMESTAMP");
	# In MySQL, setting a timestamp field to NULL actually sets it to the current timestamp
	$ok = $self->dbh->do("UPDATE zerocirc SET claimed_by=?, claimed_timestamp=NULL WHERE id=? and claimed_by is null",
			     undef,
			     $self->authen->username,
			     $q->param('id')
	    );
#	$self->log->debug("Find: ok=[$ok]");
	if (1 == $ok) {
	    $message = "Successfully claimed.";
	} else {
	    $message = "Someone beat you to it!";
	    $ok = 0; # because mysql actually returns '0E0'
	}
	
	$href = $self->dbh->selectrow_hashref(
	    "SELECT id, callno, pubdate, author, title, claimed_by, claimed_timestamp FROM zerocirc WHERE id=?", 
	    undef,
	    $q->param('id')
	    );
    }
    $template->param( pagetitle => "Maplin-3 ZeroCirc Find",
		      username => $self->authen->username,
		      ok => $ok,
		      callno => $href->{callno},
		      pubdate => $href->{pubdate},
		      author => $href->{author},
		      title => $href->{title},
		      claimed_by => $href->{claimed_by},
		      claimed_timestamp => $href->{claimed_timestamp},
		      message => $message
	);
    # Parse the template
    my $html_output = $template->output;
    return $html_output;
}


#--------------------------------------------------------------------------------
#
#
sub report_process {
    my $self = shift;
    my $q = $self->query;

    my $SQL;
    my $aref_browselist;

#    my $hideclaimed = $q->param('hideclaimed');

    $SQL = "select id, collection, callno, author, title, claimed_by from zerocirc";
    $SQL .= " where claimed_by=?";
    $SQL .= " order by collection, callno, author, title";
    $aref_browselist = $self->dbh->selectall_arrayref(
	    $SQL, 
	    { Slice => {} },
	    $self->authen->username,
	    );
    my $count = @$aref_browselist;

    my $template = $self->load_tmpl(	    
	                      'zerocirc/report.tmpl',
			      cache => 0,
			     );	
    $template->param( pagetitle => "Maplin-3 ZeroCirc Report",
		      username => $self->authen->username,
		      count => $count,
		      browselist => $aref_browselist,
	);
    # Parse the template
    my $html_output = $template->output;
    return $html_output;
}


#--------------------------------------------------------------------------------
#
#
sub show_marc_process {
    my $self = shift;
    my $q = $self->query;

    my $id = $q->param("id");

    my $sql = "SELECT marc FROM marc WHERE sessionid=";
    $sql .= $self->dbh->quote($self->session->id());
    $sql .= " AND id=$id";

    $self->log->debug($sql);

    # returns an array of arrays?  Ah.  1 array per row.
    my $marc_aref = $self->dbh->selectrow_arrayref($sql);
    my $marc_string = $marc_aref->[0];
    my $marc = new_from_usmarc MARC::Record($marc_string);

    my $template = $self->load_tmpl(	    
	                      'search/marc.tmpl'
			     );	
    $template->param( marc => $marc->as_formatted() );

    # Parse the template
    my $html_output = $template->output;
    $template->param( pagetitle => "Maplin-3 ZeroCirc MARC",
		      username => $self->authen->username);
    return $html_output;
}


1; # so the 'require' or 'use' succeeds
