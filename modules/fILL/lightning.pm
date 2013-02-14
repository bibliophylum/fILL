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
use Clone qw(clone);
use Encode;
use Text::Unidecode;
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
    'MMCA' => 'MMCA',
    'MVE' => 'MVE',
    'ME' => 'ME',
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
	'new_patron_requests'      => 'new_patron_requests_process',
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
    my $group_id = $q->param('group_id');
    my $copies_requested = $q->param('copies_requested') || 1;
    if (($copies_requested) && ($copies_requested > 1)) {
	$self->dbh->do("UPDATE request_group SET copies_requested=? where group_id=?", undef, $copies_requested, $group_id);
    }
    if ($pbarcode) {
	$self->dbh->do("UPDATE request_group SET patron_barcode=? where group_id=?", undef, $pbarcode, $group_id);
    }
    if ($request_note) {
	$self->dbh->do("UPDATE request_group SET note=? where group_id=?", undef, $request_note, $group_id);
    }

    # Get this user's (requester's) library id
    my ($requester,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!
    if (not defined $requester) {
	# should never get here...
	# go to some error page.
    }

    # Get request details from group
    my $req_href = $self->dbh->selectrow_hashref("SELECT * FROM request_group WHERE group_id=?", undef, $group_id);

    my $seq;

    # get the sources
    my @sources = @{ $self->dbh->selectall_arrayref("SELECT * FROM sources WHERE group_id=? ORDER BY sequence_number",
						    { Slice => {} }, $group_id)
	};

#    $self->log->debug( "complete_the_request sources:\n" . Dumper( @sources ) );
#    $self->log->debug( "complete_the_request # sources: " . scalar @sources );
#    $self->log->debug( "complete_the_request copies_requested: " . $copies_requested );

    for ($seq=1; $seq<=$copies_requested; $seq++) {
	last if ($seq > (scalar @sources));  # bail if we've run out of sources
	$self->log->debug( "complete_the_request #" . $seq );

	# separate chain for each copy requested
	$self->dbh->do("insert into request_chain (group_id) values (?)",
		       undef,
		       $group_id
	    );
	my $cid = $self->dbh->last_insert_id(undef,undef,undef,undef,{sequence=>'request_chain_seq'});
	
	my $source_library = $sources[$seq-1]->{"lid"};
	
	# create the request
	$self->dbh->do("INSERT INTO request (requester,current_source_sequence_number,chain_id) VALUES (?,?,?)",
		       undef,
		       $req_href->{"requester"},
		       $sources[$seq-1]->{"sequence_number"},
		       $cid
	    );
	my $reqid = $self->dbh->last_insert_id(undef,undef,undef,undef,{sequence=>'request_seq'});
	
	# begin the ILL conversation
	my $SQL = "INSERT INTO requests_active (request_id, msg_from, msg_to, status) VALUES (?,?,?,?)";
	$self->dbh->do($SQL, undef, $reqid, $requester, $source_library, 'ILL-Request');

	# not sure we really need request_id in sources any more... but we do need to note that we've tried this source.
	$self->dbh->do("UPDATE sources SET tried=true, request_id=? WHERE group_id=? AND sequence_number=?",
		       undef, $reqid, $group_id, $sources[$seq-1]->{"sequence_number"} );
	
	# does the selected source library want immediate notification, by email, of new requests?
	my @notify = $self->dbh->selectrow_array("SELECT request_email_notification, email_address FROM libraries WHERE lid=?",
						 undef,$source_library);
	if ($notify[0]) {
	    send_notification($self,$notify[1],$reqid);
	}
    }

    my $trying_aref = $self->dbh->selectall_arrayref("select g.group_id, c.chain_id, s.request_id, l.name as symbol, l.library, s.call_number from sources s left join request r on r.id=s.request_id left join request_chain c on c.chain_id=r.chain_id left join request_group g on g.group_id=c.group_id left join libraries l on l.lid=s.lid where s.group_id=? and s.tried=true", { Slice => {} }, $group_id);

    my $template = $self->load_tmpl('search/request_placed.tmpl');	
    $template->param( pagetitle => "fILL Request has been placed",
		      username => $self->authen->username,
		      lid => $requester,
		      title => $req_href->{"title"},
		      author => $req_href->{"author"},
		      medium => $req_href->{"medium"},
		      multiple_copies => ($copies_requested > 1) ? 1 : 0,
		      copies_requested => $copies_requested,
		      number_of_sources => scalar @sources,
                      requests_made => $seq-1,
		      trying => $trying_aref,
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
    #my $SQL = "select b.barcode, r.title, r.author, r.note, date_trunc('second',ra.ts) as ts, l.name as from, l.library, s.call_number from request r left join requests_active ra on (r.id = ra.request_id) left join library_barcodes b on (ra.msg_from = b.borrower and b.lid=?) left join sources s on (s.request_id = ra.request_id and s.lid = ra.msg_to) left join libraries l on ra.msg_from = l.lid where ra.msg_to=? and ra.status='ILL-Request' and ra.request_id not in (select request_id from requests_active where msg_from=?) order by s.call_number";
    my $SQL="select 
  b.barcode, 
  g.title, 
  g.author, 
  g.note, 
  date_trunc('second',ra.ts) as ts, 
  l.name as from, 
  l.library, 
  s.call_number 
from requests_active ra
  left join request r on r.id=ra.request_id
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join library_barcodes b on (ra.msg_from = b.borrower and b.lid=?) 
  left join sources s on (s.group_id = g.group_id and s.lid = ra.msg_to) 
  left join libraries l on l.lid = ra.msg_from
where 
  ra.msg_to=? 
  and ra.status='ILL-Request' 
  and ra.request_id not in (select request_id from requests_active where msg_from=?) 
order by s.call_number
";

    my $pulls = $self->dbh->selectall_arrayref($SQL, { Slice => {} }, $lid, $lid, $lid );

    # generate barcodes (code39 requires '*' as start and stop characters
    foreach my $request (@$pulls) {
	if (( $request->{barcode} ) && ( $request->{barcode} =~ /\d+/)) {
	    $request->{"barcode_image"} = encode_base64(GD::Barcode::Code39->new( '*' . $request->{barcode} . '*' )->plot->png);
	}
    }

    my $template = $self->load_tmpl('search/pull_list.tmpl');	
    $template->param( pagetitle => "Pull-list",
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
	    $sources{$num}{$pname} = uc($sources{$num}{$pname}) if ($pname eq 'symbol');
	}
    }
#    $self->log->debug( "request_process parms:\n" . Dumper( @parms ) );
#    foreach my $num (keys %sources) {
#	$self->log->debug( "request_process sources $num hash:\n " . Dumper( $sources{$num} ) );
#    }

    my $medium;
    my @sources;
    foreach my $num (sort keys %sources) {

	my %src;

	$medium = $sources{$num}{'medium'};  # fILL-client.js groups by medium, so all sources' mediums should be the same.
	delete $sources{$num}{'medium'};

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
		} elsif ($sources{$num}{'symbol'} eq 'MDA') {
		    # temp - testing Parklands... eventually this will work like Spruce or WMRL
		    $loc_callno{ $loc } = $loc . " [" . $loc_callno{ $loc } . "]";
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

    my $title = eval { decode( 'UTF-8', $q->param('title'), Encode::FB_CROAK ) };
    if ($@) {
	$title = unidecode( $q->param('title') );
    }
    my $author = eval { decode( 'UTF-8', $q->param('author'), Encode::FB_CROAK ) };
    if ($@) {
	$author = unidecode( $q->param('author') );
    }
    my $medium = sprintf("%.40s", $medium);
#    $self->log->debug( "Medium for " . $title . ": " . $medium . "\n" );

    # These should be atomic...
    # create the request_group
    $self->dbh->do("INSERT INTO request_group (copies_requested, title, author, medium, requester) VALUES (?,?,?,?,?)",
	undef,
	1,        # default copies_requested
	$title,
	$author,
	$medium,
	$lid,     # requester
	);
    my $group_id = $self->dbh->last_insert_id(undef,undef,undef,undef,{sequence=>'request_group_seq'});

    # ...end of atomic

    # re-consolidate MW locations - they handle ILL for all branches centrally
    my $index = 0; 
    my $cn;
    my $primary;
    while ($index <= $#sources ) { 
	if ((!exists( $sources[$index]{'symbol'} )) || (!defined( $sources[$index]{'symbol'} )) ) {
	    $self->log->debug( "sources[" . $index . "] has no symbol:\n" . Dumper( $sources[$index] ));
	}
	my $value = $sources[$index]{symbol}; 
	if ( $value eq "MW" ) { 
	    if ($sources[$index]{location} =~ /^Millennium/ ) {
		$primary = "" unless $primary;
		$primary = $sources[$index]{location} . ' ' . $sources[$index]{callnumber} . "<br/>";
	    } else {
		$cn = "" unless $cn;
		$cn = $cn . $sources[$index]{location} . ' ' . $sources[$index]{callnumber} . "<br/>";
	    }
	    splice @sources, $index, 1; 
	} else { 
	    $index++; 
	} 
    }
    if (($cn) || ($primary)) {
	$cn = $primary . $cn;  # callnumber is a limited length; make sure the primary branch is first.
	push @sources, { 'symbol' => 'MW', 'holding' => '===', 'location' => 'xxxx', 'callnumber' => $cn };
    }
#    $self->log->debug( "request_process sources array after MW reconsolidation:\n" . Dumper(@sources) );

    # remove duplicate entries for a given library/location (they may have multiple holdings)
    my %seen = ();
    my @unique_sources = grep { ! $seen{ $_->{'symbol'}}++ } @sources;
#    my @unique_sources = grep { ! $seen{ $_->{'symbol'} . '|' . $_->{'location'} }++ } @sources;

    # net borrower/lender count  (loaned - borrowed)  based on all currently active requests
    my $SQL = "select l.lid, l.name, sum(CASE WHEN status = 'Shipped' THEN 1 ELSE 0 END) - sum(CASE WHEN status='Received' THEN 1 ELSE 0 END) as net from libraries l left outer join requests_active ra on ra.msg_from=l.lid group by l.lid, l.name order by l.name";
    my $nblc_href = $self->dbh->selectall_hashref($SQL,'name');
    foreach my $src (@unique_sources) {
	if (exists $nblc_href->{ $src->{symbol} }) {
	    $src->{net} = $nblc_href->{ $src->{symbol} }{net};
	    $src->{lid} = $nblc_href->{ $src->{symbol} }{lid};
	} else {
	    $src->{net} = 0;
	    $src->{lid} = undef;
	    $self->log->debug( $src->{'symbol'} . " not found in net-borrower/net-lender counts." );
	}
    }
#    $self->log->debug( "Unique sources:\n" . Dumper(@unique_sources) );

    # sort sources by net borrower/lender count
    my @sorted_sources = sort { $a->{net} <=> $b->{net} } @unique_sources;
#    $self->log->debug( "Sorted sources:\n" . Dumper(@sorted_sources) );

    # create the sources list for this request
    my $sequence = 1;
    $SQL = "INSERT INTO sources (sequence_number, lid, call_number, group_id) VALUES (?,?,?,?)";
    foreach my $src (@sorted_sources) {
	my $lenderID = $src->{lid};
	next unless defined $lenderID;
	my $rows_added = $self->dbh->do($SQL,
					undef,
					$sequence++,
					$lenderID,
					substr($src->{"callnumber"},0,99),  # some libraries don't clean up copy-cat recs
					$group_id,
	    );
	unless (1 == $rows_added) {
	    $self->log->debug( "Could not add source: group_id $group_id, sequence_number " . ($sequence - 1), ", library $lenderID, call_number " . substr($src->{"callnumber"},0,99) );
	}
    }


    my $template = $self->load_tmpl('search/make_request.tmpl');	
    $template->param( pagetitle => "fILL Request an ILL",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
#		      title => $q->param('title') || ' ',
		      title => $title || ' ',
#		      author => $q->param('author') || ' ',
		      author => $author || ' ',
		      medium => $medium,
		      group_id => $group_id,
		      num_sources => scalar @sorted_sources,
		      copies_requested => 1,    # default copies requested
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

#--------------------------------------------------------------------------------
#
#
sub new_patron_requests_process {
    my $self = shift;
    my $q = $self->query;

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/new_patron_requests.tmpl');	
    $template->param( pagetitle => "New requests from your patrons",
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

    my ($lid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

#    my @tac = $self->dbh->selectrow_array("select r.title, r.author, s.call_number from request r left join sources s on s.request_id = r.id where r.id=?",
#					  undef,$reqid);

    my $SQL="select 
  g.title, 
  g.author, 
  s.call_number 
from request r
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join sources s on s.group_id = g.group_id 
where r.id=?
  and s.lid=?
";
    my @tac = $self->dbh->selectrow_array($SQL,undef,$reqid,$lid);

    my $subject = "Subject: ILL Request: " . $tac[0] . "\n";
    my $content = "fILL notification\n\n";
    $content .= "You have a new request for the following item:\n";
    $content .= $tac[2] . "\t" . $tac[1] . "\t" . $tac[0] . "\n\n";
    $content .= "fILL: http://fill.sitka.bclibraries.ca/cgi-bin/lightning.cgi\n";

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
