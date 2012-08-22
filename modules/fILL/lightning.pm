#
#    fILL - Free/Open-Source Interlibrary Loan management system
#    Copyright (C) 2012  Government of Manitoba
#
#    lightning.pm is part of fILL.
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

package fILL::lightning;
use warnings;
use strict;
use base 'fILLbase';
use GD::Barcode;
use GD::Barcode::Code39;
use MIME::Base64;
use Data::Dumper;
#use Fcntl qw(LOCK_EX LOCK_NB);

my %SPRUCE_TO_MAPLIN = (
    'MWPL' => 'MWPL',
    'ALTONA' => 'MAOW',
    'BOISSEVAIN' => 'MBOM',
    'MANITOU' => 'MMA',
    'MIAMI' => 'MMIOW',
    'MORDEN' => 'MMOW',
    'STEROSE' => 'MSTR',
    'WINKLER' => 'MWOW',
    'AB' => 'MWP',
    'MWP' => 'MWP',
    'MSTOS' => 'MSTOS',
    'MTSIR' => 'MTSIR',
    );

my %WESTERN_MB_TO_MAPLIN = (
    'Brandon Public Library' => 'MBW',
    'Neepawa Public Library' => 'MNW',
    'Carberry / North Cypress Library' => 'MCNC',
    'Glenboro / South Cypress Library' => 'MGW',
    'Hartney / Cameron Library' => 'MHW',
    );

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
	'shipping'                 => 'shipping_process',
	'unfilled'                 => 'unfilled_process',
	'receive'                  => 'receiving_process',
	'renewals'                 => 'renewals_process',
	'returns'                  => 'returns_process',
	'overdue'                  => 'overdue_process',
	'renew_answer'             => 'renew_answer_process',
	'checkins'                 => 'checkins_process',
	'history'                  => 'history_process',
	'current'                  => 'current_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub complete_the_request_process {
    my $self = shift;
    my $q = $self->query;

    my $pbarcode = $q->param('pbarcode') || 'no barcode';
    my $request_note = $q->param('request_note');
    my $reqid = $q->param('request_id');
    if ($pbarcode) {
	my $SQL = "UPDATE request SET patron_barcode=?, current_source_sequence_number=1 WHERE id=?";
	$self->dbh->do($SQL, undef, $pbarcode, $reqid);  # do some error checking....!
    }
    if ($request_note) {
	my $SQL = "UPDATE request SET note=? WHERE id=?";
	$self->dbh->do($SQL, undef, $request_note, $reqid);  # do some error checking....!
    }

    # get the request
    my $hr_req = $self->dbh->selectrow_hashref("SELECT * FROM request WHERE id=?",undef,$reqid);
    my $requester = $hr_req->{requester};
    my $seq = $hr_req->{current_source_sequence_number}; # where are we in the sequence of sources? (sequence #)

    # get the first source
    my $hr_src = $self->dbh->selectrow_hashref("SELECT * FROM sources WHERE request_id=? and sequence_number=?",undef,$reqid,$seq);
    my $source_library = $hr_src->{library};

    # begin the ILL conversation
    my $SQL = "INSERT INTO requests_active (request_id, msg_from, msg_to, status) VALUES (?,?,?,?)";
    $self->dbh->do($SQL, undef, $reqid, $requester, $source_library, 'ILL-Request');

    # does the selected source library want immediate notification, by email, of new requests?
    my @notify = $self->dbh->selectrow_array("SELECT request_email_notification, email_address FROM libraries WHERE lid=?",
					     undef,$source_library);
    if ($notify[0]) {
	send_notification($self,$notify[1],$reqid);
    }

    my $template = $self->load_tmpl('search/request_placed.tmpl');	
    $template->param( pagetitle => "fILL Request has been placed",
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

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/lightning.tmpl');	
    $template->param( pagetitle => "fILL Lightning Search",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub pull_list_process {
    my $self = shift;
    my $q = $self->query;

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    # sql to get requests to this library, which this library has not responded to yet
    my $SQL = "select b.barcode, r.title, r.author, r.note, date_trunc('second',ra.ts) as ts, l.name as from, l.library, s.call_number from request r left join requests_active ra on (r.id = ra.request_id) left join library_barcodes b on (ra.msg_from = b.borrower and b.lid=?) left join sources s on (s.request_id = ra.request_id and s.library = ra.msg_to) left join libraries l on ra.msg_from = l.lid where ra.msg_to=? and ra.status='ILL-Request' and ra.request_id not in (select request_id from requests_active where msg_from=?) order by s.call_number";

    my $pulls = $self->dbh->selectall_arrayref($SQL, { Slice => {} }, $lid, $lid, $lid );

    # generate barcodes (code39 requires '*' as start and stop characters
    foreach my $request (@$pulls) {
	if (( $request->{barcode} ) && ( $request->{barcode} =~ /\d+/)) {
	    $request->{"barcode_image"} = encode_base64(GD::Barcode::Code39->new( '*' . $request->{barcode} . '*' )->plot->png);
	}
    }

    my $template = $self->load_tmpl('search/pull_list.tmpl');	
    $template->param( pagetitle => $self->authen->username . " Pull-list",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
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
    $self->log->debug( "request_process sources hash:\n " . Dumper( %sources ) );

    my @sources;
    foreach my $num (sort keys %sources) {

	my %src;

#	$self->log->debug( "source [" . $num . "]" . Dumper( $sources{$num} ));
	if ($sources{$num}{'locallocation'}) {
	    
	    # split the combined locallocation into separate locations
	    my @locs = split /\,/, $sources{$num}{'locallocation'};
	    delete $sources{$num}{'locallocation'};
	    my @callnos;
	    # confusingly, the text string 'undefined' is passed in rather than undef
	    if (($sources{$num}{'localcallno'}) && ($sources{$num}{'localcallno'} ne 'undefined')) {
		@callnos = split /\,/, $sources{$num}{'localcallno'};
	    } elsif (($sources{$num}{'callnumber'}) && ($sources{$num}{'callnumber'} ne 'undefined')) {
		@callnos = split /\,/, $sources{$num}{'callnumber'};
	    }
	    delete $sources{$num}{'localcallno'};
	    delete $sources{$num}{'callnumber'};
	    my %loc_callno = ();
	    # if there are call numbers at all, there will be one per location...
	    for (my $i=0; $i < @locs; $i++) {
		if (@callnos) {
		    if ($callnos[$i] ne 'PAZPAR2_NULL_VALUE') {
			$loc_callno{ $locs[$i] } = $callnos[$i];
		    } else {
			$loc_callno{ $locs[$i] } = $sources{$num}{'holding'};
		    }
		} elsif ($sources{$num}{'holding'}) {
		    # ...otherwise, there might be one single 'holding' entry
		    $loc_callno{ $locs[$i] } = $sources{$num}{'holding'};
		} else {
		    $loc_callno{ $locs[$i] } = 'No callno info';
		}
	    }
	    
	    my %seen;
	    foreach my $loc (@locs) {
		next if $seen{$loc};
		$seen{$loc} = 1;
		my %src;
		foreach my $pname (keys %{$sources{$num}}) {
		    $src{$pname} = $sources{$num}{$pname};
		}
		# really need to generalize this....
		if ($sources{$num}{'symbol'} eq 'SPRUCE') {
		    $src{'symbol'} = $SPRUCE_TO_MAPLIN{ $loc };
		} elsif ($sources{$num}{'symbol'} eq 'MW') {
		    # leave as-is... requests to all MW branches go to MW
		} elsif ($sources{$num}{'symbol'} eq 'MBW') {
		    $src{'symbol'} = $WESTERN_MB_TO_MAPLIN{ $loc };
		} else {
		    $src{'symbol'} = $sources{$num}{'symbol'};
		}
		$src{'location'} = $loc;
		$src{'holding'} = '---';
		$src{'callnumber'} = $loc_callno{ $loc };
		push @sources, \%src;
	    }
	}
    }
#    $self->log->debug( "request_process sources array:\n" . Dumper(@sources) );

    # Get this user's (requester's) library id
    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!
    if (not defined $lid) {
	# should never get here...
	# go to some error page.
    }

    my $title = $q->param('title');
    my $author = $q->param('author');

    # These should be atomic...
    # create the request (sans patron barcode)
    $self->dbh->do("INSERT INTO request (title,author,requester,current_source_sequence_number) VALUES (?,?,?,?)",
		   undef,
		   $title,
		   $author,
		   $lid,
		   0           # no source yet (aka request isn't complete until patron barcode is in
	);
    my $reqid = $self->dbh->last_insert_id(undef,undef,undef,undef,{sequence=>'request_seq'});
    # ...end of atomic

    # re-consolidate MW locations - they handle ILL for all branches centrally
    my $index = 0; 
    my $cn;
    my $primary;
    while ($index <= $#sources ) { 
	my $value = $sources[$index]{symbol}; 
	if ( $value eq "MW" ) { 
	    if ($sources[$index]{location} =~ /^Millennium/ ) {
		$primary = $sources[$index]{location} . ' ' . $sources[$index]{callnumber} . "<br/>";
	    } else {
		$cn = $cn . $sources[$index]{location} . ' ' . $sources[$index]{callnumber} . "<br/>";
	    }
	    splice @sources, $index, 1; 
	} else { 
	    $index++; 
	} 
    }
    if ($cn) {
	$cn = $primary . $cn;  # callnumber is a limited length; make sure the primary branch is first.
	push @sources, { 'symbol' => 'MW', 'holding' => '===', 'location' => 'xxxx', 'callnumber' => $cn };
    }
#    $self->log->debug( "request_process sources array after MW reconsolidation:\n" . Dumper(@sources) );

    # remove duplicate entries for a given library/location (they may have multiple holdings)
    my %seen = ();
    my @unique_sources = grep { ! $seen{ $_->{'symbol'}}++ } @sources;
#    my @unique_sources = grep { ! $seen{ $_->{'symbol'} . '|' . $_->{'location'} }++ } @sources;

    # net borrower/lender count  (loaned - borrowed)
    my $SQL = "select l.lid, l.name, sum(CASE WHEN status = 'Shipped' THEN 1 ELSE 0 END) - sum(CASE WHEN status='Received' THEN 1 ELSE 0 END) as net from libraries l left outer join requests_history rh on rh.msg_from=l.lid group by l.lid, l.name order by l.name";
    my $nblc_href = $self->dbh->selectall_hashref($SQL,'name');
    foreach my $src (@unique_sources) {
	$src->{net} = $nblc_href->{ $src->{symbol} }{net};
	$src->{lid} = $nblc_href->{ $src->{symbol} }{lid};
    }

    # sort sources by net borrower/lender count
    my @sorted_sources = sort { $a->{net} <=> $b->{net} } @unique_sources;
#    $self->log->debug( Dumper(@sorted_sources) );

    # create the sources list for this request
    my $sequence = 1;
    $SQL = "INSERT INTO sources (request_id, sequence_number, library, call_number) VALUES (?,?,?,?)";
    foreach my $src (@sorted_sources) {
	my $lenderID = $src->{lid};
	next unless defined $lenderID;
	$self->dbh->do($SQL,
		       undef,
		       $reqid,
		       $sequence++,
		       $lenderID,
		       substr($src->{"callnumber"},0,99),  # some libraries don't clean up copy-cat recs
	    );
    }


    my $template = $self->load_tmpl('search/make_request.tmpl');	
    $template->param( pagetitle => "fILL Request an ILL",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
		      request_id => $reqid,
		      title => $q->param('title') || ' ',
		      author => $q->param('author') || ' ',
		      sources => \@sorted_sources,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub respond_process {
    my $self = shift;
    my $q = $self->query;

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/respond.tmpl');	
    $template->param( pagetitle => "Respond to ILL requests",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub shipping_process {
    my $self = shift;
    my $q = $self->query;

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/shipping.tmpl');	
    $template->param( pagetitle => "Shipping",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub receiving_process {
    my $self = shift;
    my $q = $self->query;

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/receiving.tmpl');	
    $template->param( pagetitle => "Receive items to fill your requests",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub renewals_process {
    my $self = shift;
    my $q = $self->query;

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/renewals.tmpl');	
    $template->param( pagetitle => "Ask for renewals on borrowed items",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub renew_answer_process {
    my $self = shift;
    my $q = $self->query;

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/renew-answer.tmpl');	
    $template->param( pagetitle => "Respond to renewal requests",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub returns_process {
    my $self = shift;
    my $q = $self->query;

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/returns.tmpl');	
    $template->param( pagetitle => "Return items to lending libraries",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub overdue_process {
    my $self = shift;
    my $q = $self->query;

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/overdue.tmpl');	
    $template->param( pagetitle => "Overdue items to be returned to lender",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub checkins_process {
    my $self = shift;
    my $q = $self->query;

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/checkins.tmpl');	
    $template->param( pagetitle => "Loan items to be checked back into your ILS",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub history_process {
    my $self = shift;
    my $q = $self->query;

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/history.tmpl');	
    $template->param( pagetitle => "ILL history",
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

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/current.tmpl');	
    $template->param( pagetitle => "Current ILLs",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub unfilled_process {
    my $self = shift;
    my $q = $self->query;

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/unfilled.tmpl');	
    $template->param( pagetitle => "Unfilled ILL requests",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------------------
sub send_notification {
    my $self = shift;
    my $to_email = shift;
    my $reqid = shift;

#    $self->log->info( "Source wants an email" );

    # for testing:
    my $old_email = $to_email;
    $to_email = 'David.Christensen@gov.mb.ca';

    my @tac = $self->dbh->selectrow_array("select r.title, r.author, s.call_number from request r left join sources s on s.request_id = r.id where r.id=?",
					  undef,$reqid);

    my $subject = "Subject: ILL Request: " . $tac[0] . "\n";
    my $content = "fILL notification\n\n";
    $content .= "You have a new request for the following item:\n";
    $content .= $tac[2] . "\t" . $tac[1] . "\t" . $tac[0] . "\n\n";
    $content .= "fILL: http://fill.sitka.bclibraries.ca/cgi-bin/lightning.cgi\n";
    $content .= "\n\n(debug): original email: $old_email\n";

#    $self->log->info( "To: $to_email\n$subject$content" );

    my $error_sendmail = 0;
    my $sendmail = "/usr/sbin/sendmail -t";

    eval {
        open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
        print SENDMAIL 'To: ' . $to_email;
        print SENDMAIL $subject;
        print SENDMAIL "Content-type: text/plain\n\n";
        print SENDMAIL $content;
        close(SENDMAIL);
    };
    if ($@) {
        # sendmail blew up
        $self->log->debug("sendmail blew up");
    } else {
#        $self->log->debug("sendmail sent request");
    }

}

#--------------------------------------------------------------------------------------------
sub get_library_from_username {
    my $self = shift;
    my $username = shift;
    # Get this user's library id
    my $hr_id = $self->dbh->selectrow_hashref(
	"select l.lid, l.library from users u left join libraries l on (u.lid = l.lid) where u.username=?",
	undef,
	$username
	);
    return ($hr_id->{lid}, $hr_id->{library});
}

1; # so the 'require' or 'use' succeeds
