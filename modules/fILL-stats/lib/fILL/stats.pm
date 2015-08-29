#
#    fILL - Free/Open-Source Interlibrary Loan management system
#    Copyright (C) 2011  Government of Manitoba
#
#    stats.pm is a part of fILL.
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

# fILL::stats is unlike the other fILL modules - it does not provide any CGI runmodes.
# Instead, this is a utility module to provide consistent statistics generation
# (write the SQL to pull out stats once, use it everywhere).  
# The .cgi executables in fILL/bin/ will require something similar, which is not yet built.

package fILL::stats;
use strict;
use warnings;
use DBI;
#use fILL::charts;
#use Data::Dumper;

=head1 NAME

fILL::stats - The great new fILL::stats!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use fILL::stats;

    my $foo = fILL::stats->new($oid,2015,4);
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

#--------------------------------------------------------------------------------
=head2 new

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    my $self  = {};
    bless ($self, $class);

    $self->_init(@_);

    return $self;
}

#--------------------------------------------------------------------------------
=head2 _init

=cut

sub _init {
    my $self = shift;
#    $self->{param}->{oid} = 84;
#    $self->{param}->{month} = 4;
#    $self->{param}->{year} = 2015;
    while (my ($key, $value) = splice @_, 0, 2) {
	$self->{param}->{$key} = $value;
    }
    # should complain if oid, month and year are not valid values....
    $self->{parms_ok} = 1;

    $self->{stats} = {};
    
    $self->{dbh} = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
				"mapapp",
				"maplin3db",
				{AutoCommit => 1, 
				 RaiseError => 1, 
				 PrintError => 0,
				}
	) or die $DBI::errstr;

}

#----------------------------------------------------------------------------------
sub get_stats {
    my $self = shift;

    $self->{stats}{oid} = $self->{param}{oid};
    $self->{stats}{year} = sprintf("%4d",$self->{param}{year});
    $self->{stats}{month} = sprintf("%02d",$self->{param}{month});
    $self->{stats}{org_name} = $self->get_library();
    
    # Borrowing
    $self->{stats}{borrowing}{requests} = $self->get_borrowing_requests_made();
    $self->{stats}{borrowing}{we_received} = $self->get_borrowing_received_types();
    $self->{stats}{borrowing}{requests_unfilled} = $self->get_borrowing_requests_unfilled();
    $self->{stats}{borrowing}{responded_unfilled} = $self->get_borrowing_responses_unfilled();
    $self->{stats}{borrowing}{lender_shipped} = $self->get_borrowing_lender_shipped();
    $self->{stats}{borrowing}{we_cancelled} = $self->get_borrowing_we_cancelled();

    # Lending
    $self->{stats}{lending}{requests_to_lend} = $self->get_lending_requests_to_lend();
    $self->{stats}{lending}{responded_unfilled} = $self->get_lending_could_not_fill();
    $self->{stats}{lending}{shipped} = $self->get_lending_shipped();
    $self->{stats}{lending}{forward_to_branch} = $self->get_lending_forward_to_branch();
    $self->{stats}{lending}{borrower_cancelled} = $self->get_lending_borrower_cancelled();

    return $self->{stats};
}

#-----------------------------------------------------------------------
sub get_library {
    my $self = shift;
    my $SQL = "select org_name from org where oid=?";
    my $stats = $self->{dbh}->selectrow_hashref($SQL, { Slice => {} }, $self->{param}{oid});
    return $stats->{org_name};
}

#-----------------------------------------------------------------------
# Note: counting stats for requests initiated within the month, regardless of when the answers came.
sub get_borrowing_requests_made {
    my $self = shift;
    my %stats;

    foreach my $tbl (qw/active history/) {
	my $req_tbl = ($tbl eq 'active') ? "request" : "request_closed";
	my $src_tbl = ($tbl eq 'active') ? "sources" : "sources_history";

	my $SQL = "select 
                     extract(YEAR from ts) as year, 
                     extract(MONTH from ts) as monthnum, 
                     to_char(ts,'Month') as month, 
                     case when s.call_number ~ E'[[:digit:]]+[.][[:digit:]]*' then 'NF'
                      when s.call_number ~ E'[[:digit:]]{3} [[:alpha:]][[:alpha:]]+' then 'NF'
                      when s.call_number ~ 'NF ' then 'NF'
                      when s.call_number ~ 'Non(-| )' then 'NF'
                      when s.call_number ~ 'DVD' then 'AV'
                      when s.call_number ~ 'CD' then 'AV'
                      else 'FIC'
                     end as type,
                     count(distinct rc.chain_id) as books_requested, 
                     count(distinct h.request_id) as requests_made 
                   from 
                     $req_tbl rc 
                     left join requests_$tbl h on h.request_id=rc.id 
                     left join $src_tbl s on s.request_id = rc.id  
                   where 
                     h.msg_from=? 
                     and h.status='ILL-Request' 
                     and extract(YEAR from ts)=?
                     and extract(MONTH from ts)=? 
                   group by year, monthnum, month, type 
                   order by year, monthnum, month, type";

	my $aryref = $self->{dbh}->selectall_arrayref($SQL, { Slice => {} }, $self->{param}{oid}, $self->{param}{year}, $self->{param}{month});

	foreach my $row (@$aryref) {
#	    $stats{month} = $row->{month};
	    $stats{books_requested}{total} = 0 unless (exists $stats{books_requested}{total});
	    $stats{books_requested}{total} += $row->{books_requested};
	    $stats{books_requested}{type}{$row->{type}} = 0 unless (exists $stats{books_requested}{type}{$row->{type}});
	    $stats{books_requested}{type}{$row->{type}} += $row->{books_requested};
	    $stats{requests_made} = 0 unless (exists $stats{requests_made});
	    $stats{requests_made} += $row->{requests_made};
	}
    }
    return \%stats;
}

#-----------------------------------------------------------------------
# Note: counting stats for requests initiated within the month, regardless of when the answers came.
sub get_borrowing_received_types {
    my $self = shift;
    my %stats;

    foreach my $tbl (qw/active history/) {
	my $req_tbl = ($tbl eq 'active') ? "request" : "request_closed";
	my $src_tbl = ($tbl eq 'active') ? "sources" : "sources_history";

	my $SQL = "select
                     extract(YEAR from ts) as year,
                     extract(MONTH from ts) as monthnum,
                     to_char(ts,'Month') as month,
                     case when s.call_number ~ E'[[:digit:]]+[.][[:digit:]]*' then 'NF'
                      when s.call_number ~ E'[[:digit:]]{3} [[:alpha:]][[:alpha:]]+' then 'NF'
                      when s.call_number ~ 'NF ' then 'NF'
                      when s.call_number ~ 'Non(-| )' then 'NF'
                      when s.call_number ~ 'DVD' then 'AV'
                      when s.call_number ~ 'CD' then 'AV'
                      else 'FIC'
                     end as type,
                     count(distinct rc.chain_id) as items_count 
                   from
                     $req_tbl rc
                     left join requests_$tbl h on h.request_id=rc.id
                     left join $src_tbl s on s.request_id = rc.id  
                   where
                     h.msg_from=?
                     and h.status='Received'
                     and extract(YEAR from ts)=?
                     and extract(MONTH from ts)=? 
                   group by year, monthnum, month, type  
                   order by year, monthnum, month, type";

	my $aryref = $self->{dbh}->selectall_arrayref($SQL,, { Slice => {} }, $self->{param}{oid}, $self->{param}{year}, $self->{param}{month});

	foreach my $row (@$aryref) {
#	    $stats{month} = $row->{month};
	    $stats{total} = 0 unless (exists $stats{total});
	    $stats{total} += $row->{items_count};
	    $stats{type}{$row->{type}} = 0 unless (exists $stats{type}{$row->{type}});
	    $stats{type}{$row->{type}} += $row->{items_count};
	}
    }
    return \%stats;
}

#-----------------------------------------------------------------------
sub get_borrowing_responses_unfilled {
    my $self = shift;
    my %stats;

    # This is counting individual 'unfilled' responses, rather than
    # whether a particular request (however many responses) remained unfilled.
    # Any given request for an item (identified by the request or request_closed
    # *chain_id*) can have multiple generated requests (one per source tried),
    # each of which has a distinct request_id but common chain_id.
    #
    # This statistic counts the total number of 'unfilled' responses to all
    # (request_id) requests within the time frame.
    
    foreach my $tbl (qw/active history/) {
	my $req_tbl = ($tbl eq 'active') ? "request" : "request_closed";
	my $src_tbl = ($tbl eq 'active') ? "sources" : "sources_history";

	my $SQL = "select 
                 extract(YEAR from ts) as year, 
                 extract(MONTH from ts) as monthnum, 
                 to_char(ts, 'Month') as month, 
                 count(request_id) as responded_unfilled 
               from 
                 requests_$tbl 
               where 
                 msg_to=? 
                 and status like 'ILL-Answer|Unfilled%' 
                 and extract(YEAR from ts)=?
                 and extract(MONTH from ts)=? 
               group by year, monthnum, month 
               order by year, monthnum, month";
    
	my $aryref = $self->{dbh}->selectall_arrayref($SQL, { Slice => {} }, $self->{param}{oid}, $self->{param}{year}, $self->{param}{month});
	foreach my $row (@$aryref) {
	    #       $stats{month} = $row->{month};
	    $stats{total} = 0 unless (exists $stats{total});
	    $stats{total} += $row->{responded_unfilled};
	}
    }
    return \%stats;
}


#-----------------------------------------------------------------------
sub get_borrowing_requests_unfilled {
    my $self = shift;
    my %stats;

    #-- need to count only the requests where NO response was "filled"....
    #-- active requests may still (eventually) be filled, so don't count active
    #    foreach my $tbl (qw/active history/) {
    foreach my $tbl (qw/history/) {
	my $req_tbl = ($tbl eq 'active') ? "request" : "request_closed";
	my $src_tbl = ($tbl eq 'active') ? "sources" : "sources_history";

	my $SQL = "select 
                     extract(YEAR from ts) as year, 
                     extract(MONTH from ts) as monthnum, 
                     to_char(ts, 'Month') as month, 
                     case when s.call_number ~ '\\d+\\.\\d*' then 'NF'
                       when s.call_number ~ '\\d{3} \\D\\D+' then 'NF'
                       when s.call_number ~ 'NF ' then 'NF'
                       when s.call_number ~ 'Non(-| )' then 'NF'
                       when s.call_number ~ 'DVD' then 'AV'
                       when s.call_number ~ 'CD' then 'AV'
                       else 'FIC'
                      end as type,
                     count(h.request_id) as items_count 
                   from 
                     $req_tbl rc 
                     left join requests_$tbl h on h.request_id=rc.id
                     left join $src_tbl s on s.request_id = rc.id  
                   where 
                     h.msg_to=? 
                     and h.status like 'ILL-Answer|Unfilled%' 
                     and rc.chain_id not in (
                       select chain_id
                       from $req_tbl rc2
                       left join requests_$tbl h2 on h2.request_id=rc2.id
                       where rc2.chain_id = rc.chain_id
                       and h2.status = 'Shipped' 
                     )
                     and extract(YEAR from ts)=?
                     and extract(MONTH from ts)=? 
                   group by year, monthnum, month, type 
                   order by year, monthnum, month, type";
    
	my $aryref = $self->{dbh}->selectall_arrayref($SQL, { Slice => {} }, $self->{param}{oid}, $self->{param}{year}, $self->{param}{month});

	foreach my $row (@$aryref) {
	    #	$stats{month} = $row->{month};
	    $stats{total} = 0 unless (exists $stats{total});
	    $stats{total} += $row->{items_count};
	    $stats{type}{$row->{type}} = 0 unless (exists $stats{type}{$row->{type}});
	    $stats{type}{$row->{type}} += $row->{items_count};
	}
    }
    return \%stats;
}


#-----------------------------------------------------------------------
sub get_borrowing_lender_shipped {
    my $self = shift;
    my %stats;

    foreach my $tbl (qw/active history/) {
	my $req_tbl = ($tbl eq 'active') ? "request" : "request_closed";
#	my $src_tbl = ($tbl eq 'active') ? "sources" : "sources_history";

	my $SQL = "select 
                     extract(YEAR from ts) as year, 
                     extract(MONTH from ts) as monthnum, 
                     to_char(ts, 'Month') as month, 
                     count(request_id) as shipped 
                   from 
                     requests_$tbl 
                   where 
                     msg_to=? 
                     and status='Shipped' 
                     and extract(YEAR from ts)=?
                     and extract(MONTH from ts)=? 
                   group by year, monthnum, month 
                   order by year, monthnum, month";

	my $aryref = $self->{dbh}->selectall_arrayref($SQL , { Slice => {} }, $self->{param}{oid}, $self->{param}{year}, $self->{param}{month});
	foreach my $row (@$aryref) {
#	    $stats{month} = $row->{month};
	    $stats{total} = 0 unless (exists $stats{total});
	    $stats{total} += $row->{shipped};
	}
    }
    return \%stats;
}


#-----------------------------------------------------------------------
sub get_borrowing_we_cancelled {
    my $self = shift;
    my %stats;

    # To calculate the # of requests that we cancelled before receiving a reply:
    # 1. Find the requests we initiated in that time frame (status = 'ILL-Request')
    # 2. Ignore the requests that someone replied to (status like 'ILL-Answer%')
    # 3. Count the entries where status = 'Cancelled'

    foreach my $tbl (qw/active history/) {
	my $req_tbl = ($tbl eq 'active') ? "request" : "request_closed";
#	my $src_tbl = ($tbl eq 'active') ? "sources" : "sources_history";

	my $SQL ="select 
                    extract(YEAR from ts) as year, 
                    extract(MONTH from ts) as monthnum, 
                    to_char(ts, 'Month') as month, 
                    count(request_id) as we_cancelled 
                  from 
                    requests_$tbl 
                  where 
                    msg_from=? 
                    and status='Cancelled' 
                    and request_id in (select request_id from requests_$tbl where msg_from=? and status='ILL-Request') 
                    and request_id not in (select request_id from requests_$tbl where msg_to=? and status like 'ILL-Answer%') 
                    and extract(YEAR from ts)=?
                    and extract(MONTH from ts)=? 
                  group by year, monthnum, month 
                  order by year, monthnum, month";

	my $aryref = $self->{dbh}->selectall_arrayref($SQL, { Slice => {} }, $self->{param}{oid}, $self->{param}{oid}, $self->{param}{oid}, $self->{param}{year}, $self->{param}{month});
	foreach my $row (@$aryref) {
#	    $stats{month} = $row->{month};
	    $stats{total} = 0 unless (exists $stats{total});
	    $stats{total} += $row->{we_cancelled};
	}
    }
    return \%stats;
}
	
#-----------------------------------------------------------------------
# Counting answers made within the date range, regardless of when the request was initiated.
sub get_lending_requests_to_lend {
    my $self = shift;
    my %stats;

    foreach my $tbl (qw/active history/) {
	my $req_tbl = ($tbl eq 'active') ? "request" : "request_closed";
#	my $src_tbl = ($tbl eq 'active') ? "sources" : "sources_history";

	my $SQL = "select 
                     extract(YEAR from ts) as year, 
                     extract(MONTH from ts) as monthnum, 
                     to_char(ts,'Month') as month, 
                     count(request_id) as requests_to_lend 
                   from 
                     requests_$tbl 
                   where 
                     msg_to=? 
                     and status='ILL-Request' 
                     and extract(YEAR from ts)=?
                     and extract(MONTH from ts)=? 
                   group by year, monthnum, month 
                   order by year, monthnum, month";

	my $aryref = $self->{dbh}->selectall_arrayref($SQL, { Slice => {} }, $self->{param}{oid}, $self->{param}{year}, $self->{param}{month});
	foreach my $row (@$aryref) {
#	    $stats{month} = $row->{month};
	    $stats{total} = 0 unless (exists $stats{total});
	    $stats{total} += $row->{requests_to_lend};
	}
    }
    return \%stats;
}
	
#-----------------------------------------------------------------------
sub get_lending_could_not_fill {
    my $self = shift;
    my %stats;

    foreach my $tbl (qw/active history/) {
	my $req_tbl = ($tbl eq 'active') ? "request" : "request_closed";

	my $SQL = "select 
                     extract(YEAR from ts) as year, 
                     extract(MONTH from ts) as monthnum, 
                     to_char(ts, 'Month') as month, 
                     h.status,
                     count(h.status) as status_count
                   from 
                     $req_tbl rc
                     left join requests_$tbl h on h.request_id=rc.id 
                   where 
                     msg_from=? 
                     and status like 'ILL-Answer|Unfilled%' 
                     and extract(YEAR from ts)=?
                     and extract(MONTH from ts)=? 
                   group by year, monthnum, month, status 
                   order by year, monthnum, month, status";

	my $aryref = $self->{dbh}->selectall_arrayref($SQL, { Slice => {} }, $self->{param}{oid}, $self->{param}{year}, $self->{param}{month});
	foreach my $row (@$aryref) {
	    $stats{total} = 0 unless (exists $stats{total});
	    $stats{total} += $row->{status_count};
	    $row->{status} =~ s/ILL-Answer\|Unfilled\|//;
	    $stats{status}{ $row->{status} } = 0 unless (exists $stats{status}{ $row->{status} });
	    $stats{status}{ $row->{status} } += $row->{status_count};
	}
    }
    return \%stats;
}

#-----------------------------------------------------------------------
sub get_lending_shipped {
    my $self = shift;
    my %stats;

    foreach my $tbl (qw/active history/) {
	my $req_tbl = ($tbl eq 'active') ? "request" : "request_closed";
#	my $src_tbl = ($tbl eq 'active') ? "sources" : "sources_history";

	my $SQL = "select 
                     extract(YEAR from ts) as year, 
                     extract(MONTH from ts) as monthnum, 
                     to_char(ts, 'Month') as month, 
                     count(distinct rc.chain_id) as shipped 
                   from 
                     $req_tbl rc
                     left join requests_$tbl h on h.request_id=rc.id
                   where 
                     msg_from=? 
                     and status='Shipped' 
                     and extract(YEAR from ts)=?
                     and extract(MONTH from ts)=? 
                   group by year, monthnum, month 
                   order by year, monthnum, month";

	my $aryref = $self->{dbh}->selectall_arrayref($SQL, { Slice => {} }, $self->{param}{oid}, $self->{param}{year}, $self->{param}{month});
	foreach my $row (@$aryref) {
	    $stats{total} = 0 unless (exists $stats{total});
	    $stats{total} += $row->{shipped};
	}
    }
    return \%stats;
}
	
#-----------------------------------------------------------------------
sub get_lending_forward_to_branch {
    my $self = shift;
    my %stats;

    foreach my $tbl (qw/active history/) {
	my $req_tbl = ($tbl eq 'active') ? "request" : "request_closed";
#	my $src_tbl = ($tbl eq 'active') ? "sources" : "sources_history";

	my $SQL = "select 
                     extract(YEAR from ts) as year, 
                     extract(MONTH from ts) as monthnum, 
                     to_char(ts, 'Month') as month, 
                     count(request_id) as forward_to_branch 
                   from 
                     requests_$tbl 
                   where 
                     msg_from=? 
                     and status like 'ILL-Answer|Locations-provided%' 
                     and extract(YEAR from ts)=?
                     and extract(MONTH from ts)=? 
                   group by year, monthnum, month 
                   order by year, monthnum, month";

	my $aryref = $self->{dbh}->selectall_arrayref($SQL, { Slice => {} }, $self->{param}{oid}, $self->{param}{year}, $self->{param}{month});
	foreach my $row (@$aryref) {
#	    $stats{month} = $row->{month};
	    $stats{total} = 0 unless (exists $stats{total});
	    $stats{total} += $row->{forward_to_branch};
	}
    }
    return \%stats;
}
	
#-----------------------------------------------------------------------
sub get_lending_borrower_cancelled {
    my $self = shift;
    my %stats;

    foreach my $tbl (qw/active history/) {
	my $req_tbl = ($tbl eq 'active') ? "request" : "request_closed";
#	my $src_tbl = ($tbl eq 'active') ? "sources" : "sources_history";

	# the 'msg_from is not null' bit has to do with an ancient bug that created 
	# "phantom" requests... requests to/from null.
	# the bug has been fixed, but libraries are still cleaning up their data 
	# (by cancelling the phantom requests).
	my $SQL = "select 
                     extract(YEAR from ts) as year, 
                     extract(MONTH from ts) as monthnum, 
                     to_char(ts, 'Month') as month, 
                     count(request_id) as borrower_cancelled 
                   from 
                     requests_$tbl 
                   where 
                     msg_to=? 
                     and status='Cancelled' 
                     and msg_from is not null 
                     and extract(YEAR from ts)=?
                     and extract(MONTH from ts)=? 
                   group by year, monthnum, month 
                   order by year, monthnum, month";

	my $aryref = $self->{dbh}->selectall_arrayref($SQL, { Slice => {} }, $self->{param}{oid}, $self->{param}{year}, $self->{param}{month});
	foreach my $row (@$aryref) {
#	    $stats{month} = $row->{month};
	    $stats{total} = 0 unless (exists $stats{total});
	    $stats{total} += $row->{borrower_cancelled};
	}
    }
    return \%stats;
}
	
#-----------------------------------------------------------------------
sub get_lending_ {
    my $self = shift;
    my %stats;

    my $SQL = "";

    return \%stats;
}
	
1;
