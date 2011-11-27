package maplin3::lightning;
use warnings;
use strict;
use base 'maplin3base';
use ZOOM;
use MARC::Record;
use Data::Dumper;
#use Fcntl qw(LOCK_EX LOCK_NB);

#--------------------------------------------------------------------------------
# Define our runmodes
#
sub setup {
    my $self = shift;
    $self->start_mode('lightning_search_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'lightning_search_form'    => 'lightning_search_process',
	'lightning_request_form'   => 'lightning_request_process',
	'request'                  => 'request_process',
	'complete_the_request'     => 'complete_the_request_process',
	'pull_list'                => 'pull_list_process',
	'respond'                  => 'respond_process',
	'receive'                  => 'receiving_process',
	'returns'                  => 'returns_process',
	'checkins'                 => 'checkins_process',
	'history'                  => 'history_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub complete_the_request_process {
    my $self = shift;
    my $q = $self->query;

    my $pbarcode = $q->param('pbarcode');
    my $reqid = $q->param('request_id');
    if ($pbarcode) {
	my $SQL = "UPDATE request SET patron_barcode=?, current_target=1 WHERE id=?";
	$self->dbh->do($SQL, undef, $pbarcode, $reqid);  # do some error checking....!
    }

    # get the request
    my $hr_req = $self->dbh->selectrow_hashref("SELECT * FROM request WHERE id=?",undef,$reqid);
    my $requester = $hr_req->{requester};
    my $seq = $hr_req->{current_target}; # where are we in the sequence of sources? (sequence #)

    # get the first source
    my $hr_src = $self->dbh->selectrow_hashref("SELECT * FROM sources WHERE request_id=? and sequence_number=?",undef,$reqid,$seq);
    my $source_library = $hr_src->{library};

    # begin the ILL conversation
    my $SQL = "INSERT INTO requests_active (request_id, msg_from, msg_to, status) VALUES (?,?,?,?)";
    $self->dbh->do($SQL, undef, $reqid, $requester, $source_library, 'ILL-Request');

    my $template = $self->load_tmpl('search/request_placed.tmpl');	
    $template->param( pagetitle => "Maplin-4 Request has been placed",
		      username => $self->authen->username,
		      lid => $requester,
		      request_id => $reqid,
	);
    return $template->output;
}

#--------------------------------------------------------------------------------
#
#
sub lightning_search_process {
    my $self = shift;
    my $q = $self->query;

    my $template = $self->load_tmpl('search/lightning.tmpl');	
#    $template->param( pagetitle => "Maplin-4 Lightning Search",
#		      username => $self->authen->username,
#		      sessionid => $self->session->id(),
#	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub pull_list_process {
    my $self = shift;
    my $q = $self->query;

    my $lid = get_lid_from_symbol($self, $self->authen->username);  # do error checking!

    # sql to get requests to this library, which this library has not responded to yet
    my $SQL = "select r.title, r.author, ra.ts, ra.msg_from, s.call_number from request r left join requests_active ra on (r.id = ra.request_id) left join sources s on (s.request_id = ra.request_id and s.library = ra.msg_to) where ra.msg_to=$lid and ra.status='ILL-Request' and ra.request_id not in (select request_id from requests_active where msg_from=$lid)";

    my $pulls = $self->dbh->selectall_arrayref($SQL, { Slice => {} } );

    my $template = $self->load_tmpl('search/pull_list.tmpl');	
    $template->param( pagetitle => $self->authen->username . " Pull-list",
		      username => $self->authen->username,
		      lid => $lid,
		      pulls => $pulls,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub request_process {
    my $self = shift;
    my $q = $self->query;

    my @inParms = $q->param;
    my @parms;
    my %sources;
    foreach my $parm_name (@inParms) {
	my %p;
	$p{parm_name} = $parm_name;
	$p{parm_value} = $q->param($parm_name);
	push @parms, \%p;

	if ($parm_name =~ /_\d+/) {
	    my ($pname,$num) = split /_/,$parm_name;
	    $sources{$num}{$pname} = $q->param($parm_name);
	}
    }

    my @sources;
    foreach my $num (sort keys %sources) {
	my %src;
	foreach my $pname (keys %{$sources{$num}}) {
	    $src{$pname} = $sources{$num}{$pname};
	}
	push @sources, \%src;
    }
#    $self->log->debug( Dumper(@sources) );

    # Get this user's (requester's) library id
    my $requester = get_lid_from_symbol($self, $self->authen->username);  # do error checking!
    if (not defined $requester) {
	# should never get here...
	# go to some error page.
    }

    my $title = $q->param('title');
    my $author = $q->param('author');

    # These should be atomic...
    # create the request (sans patron barcode)
    $self->dbh->do("INSERT INTO request (title,author,requester,current_target) VALUES (?,?,?,?)",
		   undef,
		   $title,
		   $author,
		   $requester,
		   0                                   # no source yet (aka request isn't complete until patron barcode is in
	);
    my $reqid = $self->dbh->last_insert_id(undef,undef,undef,undef,{sequence=>'request_seq'});
    # ...end of atomic

    # ...and the sources list (worry about proper order after this code is working!)
    my $sequence = 1;
    my $SQL = "INSERT INTO sources (request_id, sequence_number, library, call_number) VALUES (?,?,?,?)";
    foreach my $src (@sources) {
	my $hr_id = $self->dbh->selectrow_hashref(
	    "SELECT lid FROM libraries WHERE name=?",
	    undef,
	    $src->{symbol},
	    );
	my $lenderID = $hr_id->{lid};
	next unless defined $lenderID;
	$self->dbh->do($SQL,
		       undef,
		       $reqid,
		       $sequence++,
		       $lenderID,
		       "fake-call-number",
	    );
    }


    my $template = $self->load_tmpl('search/make_request.tmpl');	
    $template->param( pagetitle => "Maplin-4 Request an ILL",
		      username => $self->authen->username,
		      lid => $requester,
#		      parms => \@parms,
		      request_id => $reqid,
		      title => $q->param('title'),
		      author => $q->param('author'),
		      sources => \@sources,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub respond_process {
    my $self = shift;
    my $q = $self->query;

    my $lid = get_lid_from_symbol($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/respond.tmpl');	
    $template->param( pagetitle => "Respond to ILL requests",
		      username => $self->authen->username,
		      lid => $lid,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub receiving_process {
    my $self = shift;
    my $q = $self->query;

    my $lid = get_lid_from_symbol($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/receiving.tmpl');	
    $template->param( pagetitle => "Receive items to fill your requests",
		      username => $self->authen->username,
		      lid => $lid,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub returns_process {
    my $self = shift;
    my $q = $self->query;

    my $lid = get_lid_from_symbol($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/returns.tmpl');	
    $template->param( pagetitle => "Return items to lending libraries",
		      username => $self->authen->username,
		      lid => $lid,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub checkins_process {
    my $self = shift;
    my $q = $self->query;

    my $lid = get_lid_from_symbol($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/checkins.tmpl');	
    $template->param( pagetitle => "Loan items to be checked back into your ILS",
		      username => $self->authen->username,
		      lid => $lid,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub history_process {
    my $self = shift;
    my $q = $self->query;

    my $lid = get_lid_from_symbol($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/history.tmpl');	
    $template->param( pagetitle => "ILL history",
		      username => $self->authen->username,
		      lid => $lid,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub lightning_request_process {
    my $self = shift;
    my $q = $self->query;

    my $zname = $q->param('ztarget');
    $zname =~ s/^(.+) \(.+$/$1/;
    my $hr_zserver = $self->dbh->selectrow_hashref("SELECT id, email_address FROM zservers WHERE name=?", {}, $zname);
    
    my $hr_user = $self->dbh->selectrow_hashref("SELECT lid, email_address, library, mailing_address_line1, mailing_address_line2, mailing_address_line3 from libraries WHERE name=?", {}, $self->authen->username);
    
    my $from = "From: plslib1\@mts.net\n";
    my $to = "To: " . $hr_zserver->{'email_address'} . "\n";
    my $reply_to = "Reply-to: " . $hr_user->{'email_address'} . "\n";
    my $cc = "Cc: " . $hr_user->{'email_address'} . "\n";

    my $subject = "Subject: ILL Request: " . $q->param('title') . "\n";

    my $content = "This is an automatically generated request from MAPLIN-3\n\n";
    $content .= $hr_user->{'library'} . " would like to request the following item\nfrom ";
    $content .= $zname . ":\n-------------------------------------\n";
    $content .= "Title : " . $q->param('title') . "\n";
    $content .= "Author: " . $q->param('author') . "\n";
    $content .= "Call #: " . $q->param('callno') . "\n";
    $content .= "Medium: " . $q->param('medium') . ", ";
    $content .= "PubDate " . $q->param('date') . ", ";
    $content .= "ISBN " . $q->param('isbn') . "\n";
    $content .= "Holding:" . $q->param('holding') . "\n";

    $content .= "\n-------------------------------------\n";
    $content .= "Requesting library: " . $self->authen->username . "\n\n";
    $content .= $hr_user->{'library'} . "\n";
    $content .= $hr_user->{'mailing_address_line1'} . "\n" if ($hr_user->{'mailing_address_line1'});
    $content .= $hr_user->{'mailing_address_line2'} . "\n" if ($hr_user->{'mailing_address_line2'});
    $content .= $hr_user->{'mailing_address_line3'} . "\n" if ($hr_user->{'mailing_address_line3'});

    $content .= "\n-------------------------------------\n";
    $content .= "Patron #: " . $q->param('patron') . "\n" if ($q->param('patron'));
    $content .= "Notes   : " . $q->param('notes') . "\n" if ($q->param('notes'));

    my $sent = $q->param('sent') || 0;
    my $error_sendmail = 0;
    my $sendmail = "/usr/sbin/sendmail -t";
    if ($q->param('send_email')) {
	eval {
	    open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
	    #    print SENDMAIL $from;
	    print SENDMAIL $reply_to;
	    print SENDMAIL $to;
	    print SENDMAIL $cc;
	    print SENDMAIL $subject;
	    print SENDMAIL "Content-type: text/plain\n\n";
	    print SENDMAIL $content;
	    close(SENDMAIL);
	};
	if ($@) {
	    # sendmail blew up
	    $self->log->debug("sendmail blew up");
	    $error_sendmail = 1;
	    $content =~ s/This is an automatically generated request from Maplin-4/Maplin had a problem sending email.\nThis is a MANUAL request./;
	    $content = "--- copy from here ---\n" . $content . "\n--- copy to here ---\n";
	} else {
	    #$self->log->debug("sendmail sent request");
	    #$self->_update_ILL_stats($lid, $zid, $loc, $callno, $pubdate);
	    $sent = 1;
	}
    }

    my $template = $self->load_tmpl('search/lightning_request.tmpl');	
    $template->param( pagetitle => "Maplin-4 Lightning Request",
		      username => $self->authen->username,
		      from => $from,
		      to => $to,
		      cc => $cc,
		      reply_to => $reply_to,
		      subject => $subject,
		      content => $content,
		      error_sendmail => $error_sendmail,
		      sent => $sent,
		      ztarget => $q->param('ztarget'),
		      title => $q->param('title'),
		      author => $q->param('author'),
		      callno => $q->param('callno'),
		      medium => $q->param('medium'),
		      date => $q->param('date'),
		      isbn => $q->param('isbn'),
	);
    return $template->output;
}


#--------------------------------------------------------------------------------------------
sub get_lid_from_symbol {
    my $self = shift;
    my $symbol = shift;
    # Get this user's (requester's) library id
    my $hr_id = $self->dbh->selectrow_hashref(
	"SELECT lid FROM libraries WHERE name=?",
	undef,
	$symbol
	);
    my $requester = $hr_id->{lid};
    return $requester;
}

1; # so the 'require' or 'use' succeeds
