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
    'Manitoba PLS'                             => 'MWPL',
    'Altona Library'                           => 'MAOW',  # SCRL Altona
    'Miami Library'                            => 'MMIOW', # SCRL Miami
    'Morden Library'                           => 'MMOW',  # SCRL Morden
    'Winkler Library'                          => 'MWOW',  # SCRL Winkler
    'Boissevain-Morton Library'                => 'MBOM',  # Boissevain
    'Manitou Regional Library'                 => 'MMA',   # Manitou
    'Ste Rose Library'                         => 'MSTR',  # Ste. Rose
    'AB'                                       => 'MWP',   # Legislative Library
    'MWP'                                      => 'MWP',   # Legislative Library
    'Stonewall Library'                        => 'MSTOS', # SIRL Stonewall
    'Teulon Library'                           => 'MTSIR', # SIRL Teulon
    'McAuley Branch - Border Regional Library' => 'MMCA',  # MB McAuley
    'Main Branch - Border Regional Library'    => 'MVE',   # MB Virden
    'Elkhorn Branch - Border Regional Library' => 'ME',    # MB Elkhorn
    'Somerset Library'                         => 'MS',    # Somerset
    'Glenwood and Souris Regional Library'     => 'MSOG',  # Glenwood and Souris
    'Bren Del Win Centennial Library'          => 'MDB',   # Bren Del Win
    'Portage la Prairie Regional Library'      => 'MPLP',  # Portage
    'Shilo Community Library'                  => 'MSSC',  # Shilo
    'Chemawawin Public Library at Easterville' => 'MEC',   # UCN Chemawawin
    'UCN/Norway House Public Library'          => 'MNH',   # UCN Norway House
    'UCN Health at Swan River'                 => 'UCN',   # UCN Health at Swan River
    'Thompson Campus Library'                  => 'MTK',   # UCN Thompson
    'The Pas Campus Library'                   => 'MTPK',  # UCN The Pas
    'UCN Midwifery in Winnipeg'                => 'UCN',   # UCN Midwifery
    'UCN/Pukatawagan Public Library'           => 'MPPL',  # UCN Pukatawagan
    'UCN Health at Swan River'                 => 'MSRH',  # UCN Health
    'Russell Library'                          => 'MRD',   # MRUS Russell
    'Binscarth Library'                        => 'MBI',   # MRUS Binscarth
    'Bibliotheque St. Claude Library'          => 'MSCL',  # St.Claude
    'Bibliotheque Pere Champagne Library'      => 'MNDP',  # Pere Champagne
    'Louise Public Library'                    => 'MPM',   # Pilot Mound
    'Bibliotheque Ste-Anne Library'            => 'MSA',   # Ste Anne
    'Parkland Regional'                        => 'MDA',   # Parkland
    'Dauphin Public'                           => 'MDA',
    'Parkland'                                 => 'MDA',
    'Archive Headquarters'                     => 'MDA',
    'Headquarters'                             => 'MDA',
    'Birch River'                              => 'MDA',
    'Birtle'                                   => 'MDA',
    'Bowsman'                                  => 'MDA',
    'Erickson'                                 => 'MDA',
    'Eriksdale'                                => 'MDA',
    'Foxwarren'                                => 'MDA',
    'Gilbert Plains'                           => 'MDA',
    'Gladstone'                                => 'MDA',
    'Hamiota'                                  => 'MDA',
    'Langruth'                                 => 'MDA',
    'McCreary'                                 => 'MDA',
    'Minitonas'                                => 'MDA',
    'Ochre River'                              => 'MDA',
    'Roblin'                                   => 'MDA',
    'Rossburn'                                 => 'MDA',
    'Shoal Lake'                               => 'MDA',
    'Siglunes'                                 => 'MDA',
    'St. Lazare'                               => 'MDA',
    'Ste. Rose'                                => 'MDA',
    'Strathclair'                              => 'MDA',
    'Winnipegosis'                             => 'MDA',
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
	'holds'                    => 'holds_process',
	'on_hold'                  => 'on_hold_process',
	'receive'                  => 'receiving_process',
	'renewals'                 => 'renewals_process',
	'returns'                  => 'returns_process',
	'overdue'                  => 'overdue_process',
	'renew_answer'             => 'renew_answer_process',
	'checkins'                 => 'checkins_process',
	'history'                  => 'history_process',
	'current'                  => 'current_process',
	'new_patron_requests'      => 'new_patron_requests_process',
	'pending'                  => 'pending_process',
	'lost'                     => 'lost_process',
	'lend_overdue'             => 'lend_overdue_process',
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
    my $placeOnHold = $q->param('placeOnHold') || 'lenderPolicy';
    my $reqid = $q->param('request_id');
    my $group_id = $q->param('group_id');
    my $copies_requested = $q->param('copies_requested') || 1;
#    $self->log->debug( "group_id: [" . $group_id . "], placeOnHold: [" . $placeOnHold . "]" );
    if (($copies_requested) && ($copies_requested > 1)) {
	$self->dbh->do("UPDATE request_group SET copies_requested=? where group_id=?", undef, $copies_requested, $group_id);
    }
    if ($pbarcode) {
	$self->dbh->do("UPDATE request_group SET patron_barcode=? where group_id=?", undef, $pbarcode, $group_id);
    }
    if ($request_note) {
	$self->dbh->do("UPDATE request_group SET note=? where group_id=?", undef, $request_note, $group_id);
    }
    if ($placeOnHold) {
	$self->dbh->do("UPDATE request_group SET place_on_hold=? where group_id=?", undef, $placeOnHold, $group_id);
    }

    # Get this user's (requester's) library id
    my ($requester,$library,$symbol) = get_library_from_username($self, $self->authen->username);  # do error checking!
    if (not defined $requester) {
	# should never get here...
	# go to some error page.
    }

    # Get request details from group
    my $req_href = $self->dbh->selectrow_hashref("SELECT * FROM request_group WHERE group_id=?", undef, $group_id);

    my $seq;

    # get the sources
    my @sources = @{ $self->dbh->selectall_arrayref("SELECT * FROM sources WHERE group_id=? and tried is null ORDER BY sequence_number",
						    { Slice => {} }, $group_id)
	};

#    $self->log->debug( "complete_the_request sources:\n" . Dumper( @sources ) );
#    $self->log->debug( "complete_the_request # sources: " . scalar @sources );
#    $self->log->debug( "complete_the_request copies_requested: " . $copies_requested );

    for ($seq=1; $seq<=$copies_requested; $seq++) {
	last if ($seq > (scalar @sources));  # bail if we've run out of sources
#	$self->log->debug( "complete_the_request #" . $seq );

	# separate chain for each copy requested
	$self->dbh->do("insert into request_chain (group_id) values (?)",
		       undef,
		       $group_id
	    );
	my $cid = $self->dbh->last_insert_id(undef,undef,undef,undef,{sequence=>'request_chain_seq'});
	
	my $source_library = $sources[$seq-1]->{"oid"};
	
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
	my @notify = $self->dbh->selectrow_array("SELECT request_email_notification, email_address FROM org WHERE oid=?",
						 undef,$source_library);
	if ($notify[0]) {
	    send_notification($self,$notify[1],$reqid);
	}
    }

    my $trying_aref = $self->dbh->selectall_arrayref("select g.group_id, c.chain_id, s.request_id, o.symbol, o.org_name, s.call_number from sources s left join request r on r.id=s.request_id left join request_chain c on c.chain_id=r.chain_id left join request_group g on g.group_id=c.group_id left join org o on o.oid=s.oid where s.group_id=? and o.symbol<>? and s.tried=true", { Slice => {} }, $group_id, uc($symbol));

    if ($self->is_spruce_library($symbol)) {
	my $i = 0;
	while ($i <= $#$trying_aref) {
	    if ($self->is_spruce_library($trying_aref->[$i]{'symbol'})) {
		splice @$trying_aref, $i, 1;  # toast the element (but don't increment the loop count!)
	    } else {
		$i++;
	    }
	}
    }

    $self->log->debug("trying_aref:\n" . Dumper($trying_aref));

    my $template = $self->load_tmpl('search/request_placed.tmpl');	
    $template->param( pagetitle => "fILL Request has been placed",
		      username => $self->authen->username,
		      oid => $requester,
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

    my ($oid,$library,$symbol) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/lightning.tmpl');	
    $template->param( pagetitle => "fILL Lightning Search",
		      username => $self->authen->username,
		      oid => $oid,
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

    my ($oid,$library,$symbol,$rows_per_page) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/pull_list.tmpl');	
    $template->param( pagetitle => "Pull-list",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
		      table_rows_per_page => $rows_per_page,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub request_process {
    my $self = shift;
    my $q = $self->query;

    my %sources = $self->_turn_request_parms_into_sources_hash( $q );

    my ($title,$author,$medium,$isbn,$pubdate) = $self->_normalize_request_data(
	$q->param('title') || '--',
	$q->param('author') || '--',
	$q->param('medium_0'), # fILL-client.js groups by medium, so all sources' mediums should be the same.
	$q->param('isbn') || '--',
	$q->param('pubdate') || '--'
	);

    my @sources = $self->_isolate_and_normalize_source_callnos( \%sources );

    # Get this user's (requester's) library id
    my ($oid,$library,$symbol) = get_library_from_username($self, $self->authen->username);  # do error checking!
    if (not defined $oid) {
	# should never get here...
	# go to some error page.
    }
    my $isRequesterSpruce = $self->is_spruce_library($symbol);

    # These should be atomic...
    # create the request_group
    $self->dbh->do("INSERT INTO request_group (copies_requested, title, author, medium, requester, isbn, pubdate) VALUES (?,?,?,?,?,?,?)",
	undef,
	1,        # default copies_requested
	$title,
	$author,
	$medium,
	$oid,     # requester
	$isbn,
	$pubdate,
	);
    my $group_id = $self->dbh->last_insert_id(undef,undef,undef,undef,{sequence=>'request_group_seq'});

    # ...end of atomic

    # re-consolidate MW/MDA locations - they handle ILL for all branches centrally
    @sources = $self->_consolidate_locations( \@sources );

    # remove duplicates for a given library/location (they may have multiple holdings)
    my %seen = ();
    my @unique_sources = grep { ! $seen{ $_->{'symbol'}}++ } @sources;

    my @sorted_sources = $self->_sort_sources_by_region_and_NBLC( $oid, \@unique_sources );

    # remove garbage sources
    my $index = 0; 
    while ($index <= $#sorted_sources ) { 
	my $src = $sorted_sources[$index]; 
	if ( not defined $src->{oid} ) { 
	    splice @sorted_sources, $index, 1; 
	} else { 
	    $index++; 
	} 
    }

    # create the sources list for this request
    my $sequence = 1;
    my $SQL = "INSERT INTO sources (sequence_number, oid, call_number, group_id, tried) VALUES (?,?,?,?,?)";
    foreach my $src (@sorted_sources) {
	my $lenderID = $src->{oid};
	next unless defined $lenderID;
	my $isSelfRequest = $src->{'symbol'} eq $symbol ? 1 : 0;
	my $tried = undef;
	$tried = 1 if (($isSelfRequest) || ($isRequesterSpruce && $src->{'is_spruce'}));
	$src->{'msg'} = "";
	if ($isSelfRequest) {
	    $src->{'msg'} = "You have a copy (but fILL will not try to request from you).";
	} elsif ($isRequesterSpruce && $src->{'is_spruce'}) {
	    $src->{'msg'} = "As a Spruce library, you've already tried other Spruce libraries (so fILL will skip this lender).";
	}
	delete $src->{'is_spruce'};
	delete $src->{sameRegion};
#	$self->log->debug("current src:\n" . Dumper($src));
	my $rows_added = $self->dbh->do($SQL,
					undef,
					$sequence++,
					$lenderID,
					substr($src->{"callnumber"},0,99),  # some libraries don't clean up copy-cat recs
					$group_id,
					$tried,
	    );
	unless (1 == $rows_added) {
	    $self->log->debug( "Could not add source: group_id $group_id, sequence_number " . ($sequence - 1), ", library $lenderID, call_number " . substr($src->{"callnumber"},0,99) );
	}
    }
#    $self->log->debug("sources:\n" . Dumper(@sorted_sources));

    my $template = $self->load_tmpl('search/make_request.tmpl');	
    $template->param( pagetitle => "fILL Request an ILL",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
		      title => $title,
		      author => $author,
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
sub holds_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library,$symbol,$rows_per_page) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/holds.tmpl');	
    $template->param( pagetitle => "Lenders have placed holds",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
		      table_rows_per_page => $rows_per_page,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub respond_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library,$symbol,$rows_per_page) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/respond.tmpl');	
    $template->param( pagetitle => "Respond to ILL requests",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
		      table_rows_per_page => $rows_per_page,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub on_hold_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library,$symbol,$rows_per_page) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/on_hold.tmpl');	
    $template->param( pagetitle => "On hold",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
		      table_rows_per_page => $rows_per_page,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub shipping_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library,$symbol,$rows_per_page) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/shipping.tmpl');	
    $template->param( pagetitle => "Shipping",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
		      table_rows_per_page => $rows_per_page,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub receiving_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library,$symbol,$rows_per_page) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/receiving.tmpl');	
    $template->param( pagetitle => "Receive items to fill your requests",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
		      table_rows_per_page => $rows_per_page,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub renewals_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library,$symbol,$rows_per_page) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/renewals.tmpl');	
    $template->param( pagetitle => "Ask for renewals on borrowed items",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
		      table_rows_per_page => $rows_per_page,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub renew_answer_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library,$symbol,$rows_per_page) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/renew-answer.tmpl');	
    $template->param( pagetitle => "Respond to renewal requests",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
		      table_rows_per_page => $rows_per_page,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub returns_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library,$symbol,$rows_per_page) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/returns.tmpl');	
    $template->param( pagetitle => "Return items to lending libraries",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
		      table_rows_per_page => $rows_per_page,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub overdue_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library,$symbol,$rows_per_page) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/overdue.tmpl');	
    $template->param( pagetitle => "Overdue items to be returned to lender",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
		      table_rows_per_page => $rows_per_page,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub lend_overdue_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library,$symbol,$rows_per_page) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/lend_overdue.tmpl');	
    $template->param( pagetitle => "Lender list of overdue items",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
		      table_rows_per_page => $rows_per_page,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub checkins_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library,$symbol,$rows_per_page) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/checkins.tmpl');	
    $template->param( pagetitle => "Loan items to be checked back into your ILS",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
		      table_rows_per_page => $rows_per_page,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub history_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library,$symbol,$rows_per_page) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/history.tmpl');	
    $template->param( pagetitle => "ILL history",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
		      table_rows_per_page => $rows_per_page,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub current_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library,$symbol,$rows_per_page) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/current.tmpl');	
    $template->param( pagetitle => "Current ILLs",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
		      table_rows_per_page => $rows_per_page,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub unfilled_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library,$symbol,$rows_per_page) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/unfilled.tmpl');	
    $template->param( pagetitle => "Unfilled ILL requests",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
		      table_rows_per_page => $rows_per_page,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub new_patron_requests_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library,$symbol,$rows_per_page) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/new_patron_requests.tmpl');	
    $template->param( pagetitle => "New requests from your patrons",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
		      table_rows_per_page => $rows_per_page,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub pending_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library,$symbol,$rows_per_page) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/pending.tmpl');	
    $template->param( pagetitle => "ILL requests with no response yet",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
		      table_rows_per_page => $rows_per_page,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub lost_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library,$symbol,$rows_per_page) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('search/lost.tmpl');	
    $template->param( pagetitle => "Lost items reported by borrowers",
		      username => $self->authen->username,
		      oid => $oid,
		      library => $library,
		      table_rows_per_page => $rows_per_page,
	);
    return $template->output;
    
}

#-------------------------------------------------------------------------------
sub send_notification {
    my $self = shift;
    my $to_email = shift;
    my $reqid = shift;

#    $self->log->info( "Source wants an email" );

    my ($oid,$library,$symbol) = get_library_from_username($self, $self->authen->username);  # do error checking!

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
  and s.oid=?
";
    my @tac = $self->dbh->selectrow_array($SQL,undef,$reqid,$oid);

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
        print SENDMAIL 'To: ' . $to_email . "\n";
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

#----------------------------------------------------------------------------------
sub is_spruce_library {
    my $self = shift;
    my $symbol = shift;

    my $found = 0;
    foreach my $key (keys %SPRUCE_TO_MAPLIN) {
	if ($SPRUCE_TO_MAPLIN{$key} eq uc($symbol)) {
	    $found = 1;
	    last;
	}
    }
    return $found;
}

#----------------------------------------------------------------------------------
sub get_library_from_username {
    my $self = shift;
    my $username = shift;
    # Get this user's library id
    my $hr_id = $self->dbh->selectrow_hashref(
	"select o.oid, o.org_name, o.symbol, o.rows_per_page from users u left join org o on (u.oid = o.oid) where u.username=?",
	undef,
	$username
	);
    return ($hr_id->{oid}, $hr_id->{org_name}, $hr_id->{symbol}, $hr_id->{rows_per_page});
}


#----------------------------------------------------------------------------------
sub _turn_request_parms_into_sources_hash {
    my $self = shift;
    my $q = shift;

    my @inParms = $q->param;
    my %sources;
    foreach my $parm_name (@inParms) {
	if ($parm_name =~ /_\d+/) {
	    my ($pname,$num) = split /_/,$parm_name;
	    $sources{$num}{$pname} = $q->param($parm_name);
	    $sources{$num}{$pname} = uc($sources{$num}{$pname}) if ($pname eq 'symbol');
#	} else {  # debugging...
#	    $self->log->debug("param: $parm_name [" . $q->param($parm_name) . "]\n");
	}
    }
#    foreach my $num (sort keys %sources) {
#	$self->log->debug("request_process sources $num hash:\n " . Dumper($sources{$num}));
#    }

    return %sources;
}

#----------------------------------------------------------------------------------
sub _normalize_request_data {
    my $self = shift;
    my ($t,$a,$m,$i,$p) = @_;

#    $self->log->debug("normalize request data:\nt\t$t\na\t$a\nm\t$m\ni\t$i\np\t$p\n");

    my $title = eval { decode( 'UTF-8', $t, Encode::FB_CROAK ) };
    if ($@) {
	$title = unidecode( $t );
    }
    my $author = eval { decode( 'UTF-8', $a, Encode::FB_CROAK ) };
    if ($@) {
	$author = unidecode( $a );
    }
    my $medium  = sprintf("%.40s", $m);
    my $isbn    = sprintf("%.40s", $i);
    my $pubdate = sprintf("%.40s", $p);

#    $self->log->debug("...becomes normalized:\nt\t$title\na\t$author\nm\t$medium\ni\t$isbn\np\t$pubdate\n");
    return ($title,$author,$medium,$isbn,$pubdate);
}

#----------------------------------------------------------------------------------
# Call numbers can appear in various places in a record, depending on the ILS.
# Let's check the usual suspects, and herd them all into a standard place.
sub _isolate_and_normalize_source_callnos {
    my $self = shift;
    my $sourcesref = shift;
    my %sources = %$sourcesref;

#    my $medium;
    my @sources;

    foreach my $num (sort keys %sources) {

	my %src;

	if ($sources{$num}{'medium'}) {      # medium will be the same for each, and
	    delete $sources{$num}{'medium'}; #  doesn't appear in template loop, so
	}                                    #  toast it.

	if (($sources{$num}{'locallocation'}) && ($sources{$num}{'locallocation'} eq 'undefined')) { # yes, the string 'undefined'
	    $sources{$num}{'locallocation'} = $sources{$num}{'symbol'};
	}

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
		$src{'is_spruce'} = 0;
		# really need to generalize this....
		# SEE ALSO bin/make-patron-request.cgi
		if ($sources{$num}{'symbol'} eq 'SPRUCE') {
		    $src{'symbol'} = $SPRUCE_TO_MAPLIN{ $loc };
		    $src{'is_spruce'} = 1;

		} elsif ($sources{$num}{'symbol'} eq 'MW') {
		    # leave as-is... requests to all MW branches go to MW

#		} elsif ($sources{$num}{'symbol'} eq 'MBW') {
		} elsif ($sources{$num}{'symbol'} eq 'WMRL') {
		    $src{'symbol'} = $WESTERN_MB_TO_MAPLIN{ $loc };
		    # sometime the horizon zserver does not return local holdings info...
		    # so force it to MBW and let MBW forward to branches.
		    $src{'symbol'} = 'MBW' if (not defined $src{'symbol'});

#		} elsif ($sources{$num}{'symbol'} eq 'PARKLAND') {
#		    # all Parkland requests go to MDA
#		    $src{'symbol'} = 'MDA';
#                    # This is handled in _consolidate_locations()....
#		    #$loc_callno{ $loc } = $loc . " [" . $loc_callno{ $loc } . "]";

		} elsif ($sources{$num}{'symbol'} eq 'ALLARD') {
		    # all Allard requests go to MSTG
		    $src{'symbol'} = 'MSTG';

		} elsif ($sources{$num}{'symbol'} eq 'LAKELAND') {
		    # all Lakeland requests go to MKL
		    $src{'symbol'} = 'MKL';

		} elsif ($sources{$num}{'symbol'} eq 'JOLYS') {
		    # all Jolys requests go to MSTP
		    $src{'symbol'} = 'MSTP';

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
    return @sources;
}

#----------------------------------------------------------------------------------
sub _consolidate_locations {
    my $self = shift;
    my $sourcesref = shift;
    my @sources = @$sourcesref;

    my $index = 0; 
    my %cn;      # hold consolidated call number for given symbol
    my %primary;
    while ($index <= $#sources ) { 
	if ((!exists( $sources[$index]{'symbol'} )) || (!defined( $sources[$index]{'symbol'} )) ) {
	    $self->log->debug( "sources[" . $index . "] has no symbol:\n" . Dumper( $sources[$index] ));
	}
	my $value = $sources[$index]{symbol}; 
#	$self->log->debug("cons: source [$index], symbol [$value]\n");
	if ( $value eq "MW" ) { 
	    if ($sources[$index]{location} =~ /^Millennium/ ) {
		$primary{$value} = "" unless $primary{$value};
		$primary{$value} = $sources[$index]{location} . ' ' . $sources[$index]{callnumber} . "<br/>";
	    } else {
		$cn{$value} = "" unless $cn{$value};
		$cn{$value} = $cn{$value} . $sources[$index]{location} . ' ' . $sources[$index]{callnumber} . "<br/>";
	    }
	    splice @sources, $index, 1; 
	    $self->log->debug("      saved to primary/callno, source [$index] removed\n");

	} elsif ( $value eq "MDA" ) {
	    if ($sources[$index]{location} =~ /^Dauphin/ ) {
		$primary{$value} = "" unless $primary{$value};
		$primary{$value} = $sources[$index]{location} . ' ' . $sources[$index]{callnumber} . "<br/>";
	    } else {
		$cn{$value} = "" unless $cn{$value};
		$cn{$value} = $cn{$value} . $sources[$index]{location} . ' ' . $sources[$index]{callnumber} . "<br/>";
	    }
	    splice @sources, $index, 1; 
	    $self->log->debug("      saved to primary/callno, source [$index] removed\n");

	} else { 
	    $index++; 
	} 
    }
    # can't just use keys %cn, because there might be a primary and no cn...
    foreach my $key ("MW","MDA") {
	if (($cn{$key}) || ($primary{$key})) {
	    $cn{$key} = $primary{$key} . $cn{$key};  # callnumber is a limited length; make sure the primary branch is first.
	    push @sources, { 'symbol' => $key, 'holding' => '===', 'location' => 'xxxx', 'callnumber' => $cn{$key} };
	}
    }

#    $self->log->debug("consolidation:\n" . Dumper(\%cn) . "\n");

    return @sources;
}

#----------------------------------------------------------------------------------
sub _sort_sources_by_region_and_NBLC {
    my $self = shift;
    my $oid = shift;
    my $uniquesourcesref = shift;
    my @unique_sources = @$uniquesourcesref;

    # other branches in this regional library (if this is a regional library)
    my $SQL = "select member_id from org_members where oid=(select oid from org_members where member_id=?);";
    my $same_regional = $self->dbh->selectall_arrayref($SQL,undef,$oid);
    my %sameReg = map { $_->[0] => 1 } @$same_regional;

    # net borrower/lender count (loaned - borrowed) based on all currently active requests
    $SQL = "select o.oid, o.symbol, sum(CASE WHEN status = 'Shipped' THEN 1 ELSE 0 END) - sum(CASE WHEN status='Received' THEN 1 ELSE 0 END) as net from org o left outer join requests_active ra on ra.msg_from=o.oid group by o.oid, o.symbol order by o.symbol";
    my $nblc_href = $self->dbh->selectall_hashref($SQL,'symbol');

    my $untracked_href = $self->dbh->selectall_hashref("select oid, borrowed, loaned from libraries_untracked_ill",'oid');

    foreach my $src (@unique_sources) {
	if (exists $nblc_href->{ $src->{symbol} }) {
	    $src->{net} = $nblc_href->{ $src->{symbol} }{net};
	    $src->{oid} = $nblc_href->{ $src->{symbol} }{oid};
#	    $self->log->debug( "NBLC for " . $src->{symbol} . ": " . $src->{net} );
	    if (exists $untracked_href->{ $src->{oid} } ) {
		# does this library have any untracked-by-fILL ILL counts imported into the system?
		$src->{net} = $src->{net} + $untracked_href->{ $src->{oid} }{loaned} - $untracked_href->{ $src->{oid} }{borrowed};
		$self->log->debug( "...untracked ILL counts being included, new net is " . $src->{net} );
	    }
	} else {
	    $src->{net} = 0;
	    $src->{oid} = undef;
	    $self->log->debug( $src->{'symbol'} . " not found in net-borrower/net-lender counts." );
	}

	$src->{sameRegion} = 0;
	$src->{sameRegion} = 1 if ($sameReg{ $src->{oid} });
    }
#    $self->log->debug( "Unique sources:\n" . Dumper(@unique_sources) );

    # sort sources by same-region-ness and then by net borrower/lender count
    my @sorted_sources = sort { $b->{sameRegion} <=> $a->{sameRegion} || $a->{net} <=> $b->{net} } @unique_sources;
#    $self->log->debug( "Sorted sources:\n" . Dumper(@sorted_sources) );

    return @sorted_sources;
}

1; # so the 'require' or 'use' succeeds
