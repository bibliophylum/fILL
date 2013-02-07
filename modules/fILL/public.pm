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

package fILL::public;
use warnings;
use strict;
use base 'publicbase';
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
    $self->start_mode('search_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'search_form'              => 'search_process',
	'request_form'             => 'request_process',
	'request'                  => 'request_process',
	'registration_form'        => 'registration_process',
	'myaccount_form'           => 'myaccount_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub search_process {
    my $self = shift;
    my $q = $self->query;

    my ($pid,$lid,$library) = get_patron_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('public/search.tmpl');	
    $template->param( pagetitle => "fILL Public Search",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
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

    # Get this user's (requester's) library id
    my ($pid,$lid,$library) = get_patron_from_username($self, $self->authen->username);  # do error checking!
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

    # check if this is a duplicate of an existing request (e.g. patron hit 'reload')
    if ($self->isDuplicateRequest( $pid, $lid, $title, $author )) {
	my $template = $self->load_tmpl('public/request_placed.tmpl');	
        $template->param( pagetitle => "Patron: Request an ILL",
			  username => $self->authen->username,
			  library => $library,
			  title => $title,
			  author => $author
	    );
        return $template->output;
    }

    my @sources;
    foreach my $num (sort keys %sources) {

	my %src;
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

    # These should be atomic...
    # create the request_group
    $self->dbh->do("INSERT INTO patron_request (title, author, pid, lid) VALUES (?,?,?,?)",
	undef,
	$title,
	$author,
	$pid,     # requester
	$lid      # requester's home library
	);
    my $pr_id = $self->dbh->last_insert_id(undef,undef,undef,undef,{sequence=>'patron_request_seq'});

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

    # remove duplicate entries for a given library/location (they may have multiple holdings)
    my %seen = ();
    my @unique_sources = grep { ! $seen{ $_->{'symbol'}}++ } @sources;

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

    # sort sources by net borrower/lender count
    my @sorted_sources = sort { $a->{net} <=> $b->{net} } @unique_sources;

    # create the sources list for this request
    my $sequence = 1;
    $SQL = "INSERT INTO patron_request_sources (sequence_number, lid, call_number, prid) VALUES (?,?,?,?)";
    foreach my $src (@sorted_sources) {
	my $lenderID = $src->{lid};
	next unless defined $lenderID;
	my $rows_added = $self->dbh->do($SQL,
					undef,
					$sequence++,
					$lenderID,
					substr($src->{"callnumber"},0,99),  # some libraries don't clean up copy-cat recs
					$pr_id,
	    );
	unless (1 == $rows_added) {
	    $self->log->debug( "Could not add source: prid $pr_id, sequence_number " . ($sequence - 1), ", library $lenderID, call_number " . substr($src->{"callnumber"},0,99) );
	}
    }


    my $template = $self->load_tmpl('public/request_placed.tmpl');	
    $template->param( pagetitle => "Patron: Request an ILL",
		      username => $self->authen->username,
		      library => $library,
		      title => $title,
		      author => $author,
	);
    return $template->output;
    
}

#--------------------------------------------------------------------------------
#
#
sub myaccount_process {
    my $self = shift;
    my $q = $self->query;

    my ($pid,$lid,$library) = get_patron_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('public/myaccount.tmpl');	
    $template->param( pagetitle => "fILL patron account",
		      username => $self->authen->username,
		      lid => $lid,
		      library => $library,
		      pid => $pid
	);
    return $template->output;
}


#--------------------------------------------------------------------------------------------
sub get_patron_from_username {
    my $self = shift;
    my $username = shift;
    # Get this user's library id
    my $hr_id = $self->dbh->selectrow_hashref(
	"select p.pid, p.home_library_id, l.library from patrons p left join libraries l on (l.lid = p.home_library_id) where p.username=?",
	undef,
	$username
	);
    return ($hr_id->{pid}, $hr_id->{home_library_id}, $hr_id->{library});
}

#--------------------------------------------------------------------------------------------
sub isDuplicateRequest {
    my $self = shift;
    my $pid = shift;
    my $lid = shift;
    my $title = shift;
    my $author = shift;

    my $matching = $self->dbh->selectall_arrayref(
	"select prid from patron_request where pid=? and lid=? and title=? and author=?",
	undef,
	$pid, $lid, $title, $author
	); 
    
    return 1 if (@$matching);
    return undef;
}

#--------------------------------------------------------------------------------
#
# Patron self-registration
#
sub registration_process {
    my $self = shift;
    my $q = $self->query;

    my @towns;
    my $library_href;
    my $patron_href;

    my $region;
    my $lid;
    my $ask_patron_info = 0;
    my $username_exists = 0;
    my $openshelf_inquiry = 0;

    my $now = localtime;
    $self->log->debug( $now );

    if ($q->param('clear')) {
	$self->session->clear('region');
	$self->session->clear('home_library_id');
	$self->session->clear('home_library');
	$self->session->clear('home_town');
	$self->session->clear('home_libtype');
	$self->session->clear('home_email');
	$self->session->clear('patron_name');
	$self->session->clear('patron_card');
	$self->session->clear('patron_email');
	$self->session->clear('patron_username');
	$self->session->clear('patron_password');
    }

    if ($q->param('openshelf')) {
	$openshelf_inquiry = 1;
    }

    # try to get session variable (ie - user has already chosen)
    $self->log->debug("Do we have a region?");
    if ($self->session->param('region')) {
	$region = $self->session->param('region');
	$self->log->debug("\tregion from session data");
    } elsif ($q->param('region')) {
	$region = $q->param('region');
	$self->session->param('region',$region);
	$self->log->debug("\tregion from param data, saved to session");
    }

    # Do we have a region yet?
    if (defined $region) {

	$self->log->debug("Got region.  Do we have a library id?");

	# try to get town/library session variable(s)
	if ($self->session->param('home_library_id')) {

	    # already in a session variable.  load them into the href
	    $lid = $self->session->param('home_library_id');
	    $library_href = { 
		lid     => $self->session->param('home_library_id'),
		library => $self->session->param('home_library'), 
		town    => $self->session->param('home_town'), 
	    };
	    $self->log->debug("\tlid from session data");

	} elsif ($q->param('lid')) {

	    # passed in a library id.  lookup the rest.
	    $lid = $q->param('lid');
	    $self->session->param('home_library_id', $lid);

	    my $sql = "SELECT lid, library, town FROM libraries WHERE lid=?";
	    $library_href = $self->dbh->selectrow_hashref($sql, undef, $lid);

	    $self->session->param('home_library_id',$library_href->{lid});
	    $self->session->param('home_library',$library_href->{library});
	    $self->session->param('home_town',$library_href->{town});
	    $self->log->debug("\tlid from param data, saved to session");

	} elsif ($region =~ /^WINNIPEG$/) {
	    # I hate special cases!
	    my $sql = "SELECT lid, library, town FROM libraries WHERE library like '%Winnipeg Public%'";
	    $library_href = $self->dbh->selectrow_hashref($sql);

	    $self->session->param('home_library_id',$library_href->{lid});
	    $self->session->param('home_library',$library_href->{library});
	    $self->session->param('home_town',$library_href->{town});
	    $lid = $library_href->{lid};
	    $self->log->debug("\tlid from param data, saved to session");
	}

	# Do we have a town/library yet?
	if (defined $lid) {

	    $self->log->debug("Got a lid.  Do we have patron info?");
	    # try to get patron info session variables

	    if ($self->session->param('patron_name')) {
		# already in a session variable.  load them into the href
		$patron_href = { 
		    name     => $self->session->param('patron_name'),
		    card     => $self->session->param('patron_card'),
		    email    => $self->session->param('patron_email'),
		    username => $self->session->param('patron_username'),
		    password => $self->session->param('patron_password')
		};

		$self->log->debug("\tpatron info from session data");

	    } elsif ($q->param('patron_name')) {
		$patron_href = { 
		    name     => $q->param('patron_name'),
		    card     => $q->param('patron_card'),
		    email    => $q->param('patron_email'),
		    username => $q->param('patron_username'),
		    password => $q->param('patron_password')
		};

		eval {
		    my $rows_affected = $self->dbh->do("INSERT INTO patrons (username, password, home_library_id, email_address, name, card) VALUES (?,md5(?),?,?,?,?)",
						       undef,
						       $patron_href->{username},
						       $patron_href->{password},
						       $self->session->param('home_library_id'),
						       $patron_href->{email},
						       $patron_href->{name},
						       $patron_href->{card}
			);
		    $self->session->param('~logged-in', 1);
		    $self->log->debug("\tpatron info from params");
		    $self->log->debug( Dumper($patron_href) );
		    
		    return 1;
		} or do {
		    $self->log->debug("\tpatron username exists... ask for another");
		    $username_exists = 1;
		};

		unless ($username_exists) {
		    $self->session->param('patron_name', $patron_href->{name});
		    $self->session->param('patron_card', $patron_href->{card});
		    $self->session->param('patron_email', $patron_href->{email});
		    $self->session->param('patron_username', $patron_href->{username});
		    $self->session->param('patron_password', $patron_href->{password});
		    $self->log->debug("\tpatron info saved to session");
		}
	    }

	    if ((defined $patron_href) and ($username_exists == 0)) {
		# do nothing
		$self->log->debug("Got everything we need.  Let the user continue.");
	    } else {
		$self->log->debug("\tno patron yet... ask for it");
		$ask_patron_info = 1;
	    }

	} else {
	    # No town yet.  get towns list to display.

	    $self->log->debug("\tno lid yet... ask for it");
	    my $sql = "SELECT lid, town FROM libraries WHERE region=? ORDER BY town";
	    @towns = @{ $self->dbh->selectall_arrayref($sql,
						       { Slice => {} },
						       $q->param('region'),
			    )};
	    #$self->log->debug( Dumper(@towns) );
	}	
	
    } else {
	$self->log->debug("\tno region... ask for it");
    }

    $self->log->debug("Loading template");
    my $template = $self->load_tmpl('public/registration.tmpl');

    $self->log->debug("Filling template parameters");
    $template->param(USERNAME => 'Not yet registered.',
		     ASK_REGION => defined($region) ? 0 : 1,
		     ASK_TOWN   => defined($lid)    ? 0 : 1,
		     ASK_PATRON_INFO => $ask_patron_info,
		     USERNAME_EXISTS => $username_exists,
		     REGION => $region,
		     TOWNS => \@towns,
		     LIBRARY => $library_href->{library},
		     TOWN    => $library_href->{town},
		     PATRON_NAME => $patron_href->{name},
		     PATRON_CARD => $patron_href->{card},
		     PATRON_EMAIL => $patron_href->{email},
		     PATRON_USERNAME => $patron_href->{username},
		     PATRON_PASSWORD => $patron_href->{password},
		     OPENSHELF_INQUIRY => $openshelf_inquiry,
	);

    $self->log->debug("Display page");
    return $template->output;
}


1; # so the 'require' or 'use' succeeds
