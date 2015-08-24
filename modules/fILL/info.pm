#
#    fILL - Free/Open-Source Interlibrary Loan management system
#    Copyright (C) 2011  Government of Manitoba
#
#    info.pm is a part of fILL.
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

package fILL::info;
use strict;
use base 'fILLbase';
use CGI::Application::Plugin::Stream (qw/stream_file/);
use Data::Dumper;
use fILL::stats;
#use fILL::charts;

#--------------------------------------------------------------------------------
# Define our runmodes
#
sub setup {
    my $self = shift;
    $self->start_mode('info_contacts_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'info_contacts_form'      => 'info_contacts_process',
	'info_documents_form'     => 'info_documents_process',
#	'info_reports_form'       => 'info_reports_process',
#	'info_report-folder_form' => 'info_reportfolder_process',
	'info_feeds_form'         => 'info_feeds_process',
	'send_pdf'                => 'send_pdf',
	'send_report_output'      => 'send_report_output',
	'info_new_reports_form'   => 'info_new_reports_process',
	'info_average_times_form' => 'info_average_times_process',
	'info_borrowers_lenders_form' => 'info_borrowers_lenders_process',
	'info_board_report_form' => 'info_board_report_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub info_contacts_process {
    my $self = shift;
    my $q = $self->query;

    my ($oid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $SQL_getLibrary = "SELECT symbol, phone, email_address, org_name, mailing_address_line1, mailing_address_line2, mailing_address_line3 from org WHERE active=1 ORDER BY org_name";

    # Get any parameter data (ie - user is submitting a change)
    my $sort = $q->param("sort");

    # Get the form data
    my $aref = $self->dbh->selectall_arrayref(
	$SQL_getLibrary,
	{ Slice => {} }
	);
    
    my $template = $self->load_tmpl('info/contacts.tmpl');
    $template->param(pagetitle => "fILL Info Contacts",
		     username  => $self->authen->username,
		     oid       => $oid,
		     library   => $library,
		     libraries => $aref);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub info_documents_process {
    my $self = shift;

    my ($oid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('info/documents.tmpl');
    $template->param(pagetitle => "fILL Info Documents",
		     username => $self->authen->username,
	             oid => $oid,
		     library => $library,
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub info_reports_process {
    my $self = shift;

    my ($oid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('info/reports.tmpl');
    $template->param(pagetitle => "fILL Info Reports",
		     username => $self->authen->username,
	             oid => $oid,
		     library => $library,
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub info_reportfolder_process {
    my $self = shift;

    my ($oid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('info/report-folder.tmpl');
    $template->param(pagetitle => "fILL Info Reports-folder",
		     username => $self->authen->username,
	             oid => $oid,
		     library => $library,
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub info_feeds_process {
    my $self = shift;

    my ($oid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('info/feeds.tmpl');
    $template->param(pagetitle => "fILL Info Feeds",
		     username => $self->authen->username,
	             oid => $oid,
		     library => $library,
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
# NOTE: this is an interim measure until we get the real reporting system built
#
sub info_new_reports_process {
    my $self = shift;

    # - from report-basic-stats.pl ------------------
    $self->dbh->do("SET TIMEZONE='America/Winnipeg'");
    my ($oid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $Stats_href = $self->_get_stats_DEPRECATED( $oid );  # this needs to start using fILL-stats....

    # build our array to pass to HTML::Template
    my @allStats;
    foreach my $year (sort keys %{$Stats_href}) {
	my $href = $Stats_href->{$year};
	foreach my $monthnum (sort keys %{$href}) {
	    $href->{$monthnum}->{year} = $year;
	    $href->{$monthnum}->{monthnum} = $monthnum;
	    push @allStats, $href->{$monthnum};
	}
    }
#    print STDERR Dumper(@allStats);

    # --------------------
    my $template = $self->load_tmpl('info/view_report.tmpl');
    $template->param(pagetitle => "fILL Info Stats Report",
		     username => $self->authen->username,
		     oid => $oid,
		     library => $library,
		     allStats => \@allStats
	    );
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub send_pdf {
    my $self = shift;
    my $q = $self->query;

    my $docname = $q->param("doc");
    $self->header_add( -attachment => $docname );    
    $self->stream_file( "/opt/fILL/restricted_docs/$docname",2048);
    
#    $self->header_type('none'); # let's you set your own headers
#    $self->header_props(
#	-content-type         => 'application/pdf',
#	-content-disposition  => "inline; filename=$docname"
#  );
#
#  return "Download $docname";

    return;
} 

#--------------------------------------------------------------------------------
#
#
sub send_report_output {
    my $self = shift;
    my $q = $self->query;

    my $docname = $q->param("doc");
    $self->header_add( -attachment => $docname );    
    $self->stream_file( "/opt/fILL/report-output/$docname",2048);
    
    return;
} 

#--------------------------------------------------------------------------------
#
#
sub info_average_times_process {
    my $self = shift;

    my ($oid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('info/average-times.tmpl');
    $template->param(pagetitle => "Average Handling Times",
		     username => $self->authen->username,
	             oid => $oid,
		     library => $library,
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub info_borrowers_lenders_process {
    my $self = shift;

    my ($oid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('info/borrowers-lenders.tmpl');
    $template->param(pagetitle => "Borrowers/Lenders Report",
		     username => $self->authen->username,
	             oid => $oid,
		     library => $library,
	);
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub info_board_report_process {
    my $self = shift;

    my ($oid,$library) = get_library_from_username($self, $self->authen->username);  # do error checking!

    my $template = $self->load_tmpl('info/board-monthly.tmpl');
    $template->param(pagetitle => "Board Report",
		     username => $self->authen->username,
	             oid => $oid,
		     library => $library,
	);
    return $template->output;
}


#----------------------------------------------------------------------------------
sub _get_stats_DEPRECATED {
    my $self = shift;
    my $oid = shift;
    my $aryref;
    my %Stats;

    # Borrowing
    # Note: counting stats for requests initiated within the month, regardless of when the answers came.
    foreach my $tbl (qw/active history/) {
	my $req_tbl = ($tbl eq 'active') ? "request" : "request_closed";

	$aryref = $self->dbh->selectall_arrayref("select extract(YEAR from ts) as year, extract(MONTH from ts) as monthnum, to_char(ts,'Month') as month, count(distinct rc.chain_id) as books_requested, count(distinct request_id) as requests_made from $req_tbl rc left join requests_$tbl h on h.request_id=rc.id where h.msg_from=? and h.status='ILL-Request' group by year, monthnum, month order by year, monthnum, month", { Slice => {} }, $oid);
	foreach my $row (@$aryref) {
	    $Stats{ $row->{year} }{ $row->{monthnum} }{month} = $row->{month};
	    $Stats{ $row->{year} }{ $row->{monthnum} }{books_requested} = 0 unless (exists $Stats{ $row->{year} }{ $row->{monthnum} }{books_requested});
	    $Stats{ $row->{year} }{ $row->{monthnum} }{books_requested} += $row->{books_requested};
	    $Stats{ $row->{year} }{ $row->{monthnum} }{requests_made} = 0 unless (exists $Stats{ $row->{year} }{ $row->{monthnum} }{requests_made});
	    $Stats{ $row->{year} }{ $row->{monthnum} }{requests_made} += $row->{requests_made};
	}

	$aryref = $self->dbh->selectall_arrayref("select extract(YEAR from ts) as year, extract(MONTH from ts) as monthnum, to_char(ts, 'Month') as month, count(request_id) as responded_unfilled from requests_$tbl where msg_to=? and status like 'ILL-Answer|Unfilled%' group by year, monthnum, month order by year, monthnum, month", { Slice => {} }, $oid);
	foreach my $row (@$aryref) {
	    $Stats{ $row->{year} }{ $row->{monthnum} }{month} = $row->{month};
	    $Stats{ $row->{year} }{ $row->{monthnum} }{responded_unfilled} = 0 unless (exists $Stats{ $row->{year} }{ $row->{monthnum} }{responded_unfilled});
	    $Stats{ $row->{year} }{ $row->{monthnum} }{responded_unfilled} += $row->{responded_unfilled};
	}

	$aryref = $self->dbh->selectall_arrayref("select extract(YEAR from ts) as year, extract(MONTH from ts) as monthnum, to_char(ts, 'Month') as month, count(request_id) as shipped from requests_$tbl where msg_to=? and status='Shipped' group by year, monthnum, month order by year, monthnum, month", { Slice => {} }, $oid);
	foreach my $row (@$aryref) {
	    $Stats{ $row->{year} }{ $row->{monthnum} }{month} = $row->{month};
	    $Stats{ $row->{year} }{ $row->{monthnum} }{lender_shipped} = 0 unless (exists $Stats{ $row->{year} }{ $row->{monthnum} }{lender_shipped});
	    $Stats{ $row->{year} }{ $row->{monthnum} }{lender_shipped} += $row->{shipped};
	}
	
	# To calculate the # of requests that we cancelled before receiving a reply:
	# 1. Find the requests we initiated in that time frame (status = 'ILL-Request')
	# 2. Ignore the requests that someone replied to (status like 'ILL-Answer%')
	# 3. Count the entries where status = 'Cancelled'
	$aryref = $self->dbh->selectall_arrayref("select extract(YEAR from ts) as year, extract(MONTH from ts) as monthnum, to_char(ts, 'Month') as month, count(request_id) as we_cancelled from requests_$tbl where msg_from=? and status='Cancelled' and request_id in (select request_id from requests_$tbl where msg_from=? and status='ILL-Request') and request_id not in (select request_id from requests_$tbl where msg_to=? and status like 'ILL-Answer%') group by year, monthnum, month order by year, monthnum, month", { Slice => {} }, $oid, $oid, $oid);
	foreach my $row (@$aryref) {
	    $Stats{ $row->{year} }{ $row->{monthnum} }{month} = $row->{month};
	    $Stats{ $row->{year} }{ $row->{monthnum} }{we_cancelled} = 0 unless (exists $Stats{ $row->{year} }{ $row->{monthnum} }{we_cancelled});
	    $Stats{ $row->{year} }{ $row->{monthnum} }{we_cancelled} += $row->{we_cancelled};
	}

    }

    # Lending
    # Counting answers made within the date range, regardless of when the request was initiated.
    foreach my $tbl (qw/active history/) {
	$aryref = $self->dbh->selectall_arrayref("select extract(YEAR from ts) as year, extract(MONTH from ts) as monthnum, to_char(ts,'Month') as month, count(request_id) as requests_to_lend from requests_$tbl where msg_to=? and status='ILL-Request' group by year, monthnum, month order by year, monthnum, month", { Slice => {} }, $oid);
	foreach my $row (@$aryref) {
	    $Stats{ $row->{year} }{ $row->{monthnum} }{month} = $row->{month};
	    $Stats{ $row->{year} }{ $row->{monthnum} }{requests_to_lend} = 0 unless (exists $Stats{ $row->{year} }{ $row->{monthnum} }{requests_to_lend});
	    $Stats{ $row->{year} }{ $row->{monthnum} }{requests_to_lend} += $row->{requests_to_lend};
	}

	$aryref = $self->dbh->selectall_arrayref("select extract(YEAR from ts) as year, extract(MONTH from ts) as monthnum, to_char(ts, 'Month') as month, count(request_id) as could_not_fill from requests_$tbl where msg_from=? and status like 'ILL-Answer|Unfilled%' group by year, monthnum, month order by year, monthnum, month", { Slice => {} }, $oid);
	foreach my $row (@$aryref) {
	    $Stats{ $row->{year} }{ $row->{monthnum} }{month} = $row->{month};
	    $Stats{ $row->{year} }{ $row->{monthnum} }{could_not_fill} = 0 unless (exists $Stats{ $row->{year} }{ $row->{monthnum} }{could_not_fill});
	    $Stats{ $row->{year} }{ $row->{monthnum} }{could_not_fill} += $row->{could_not_fill};
	}

	$aryref = $self->dbh->selectall_arrayref("select extract(YEAR from ts) as year, extract(MONTH from ts) as monthnum, to_char(ts, 'Month') as month, count(request_id) as shipped from requests_$tbl where msg_from=? and status='Shipped' group by year, monthnum, month order by year, monthnum, month", { Slice => {} }, $oid);
	foreach my $row (@$aryref) {
	    $Stats{ $row->{year} }{ $row->{monthnum} }{month} = $row->{month};
	    $Stats{ $row->{year} }{ $row->{monthnum} }{shipped} = 0 unless (exists $Stats{ $row->{year} }{ $row->{monthnum} }{shipped});
	    $Stats{ $row->{year} }{ $row->{monthnum} }{shipped} += $row->{shipped};
	}

	$aryref = $self->dbh->selectall_arrayref("select extract(YEAR from ts) as year, extract(MONTH from ts) as monthnum, to_char(ts, 'Month') as month, count(request_id) forward_to_branch from requests_$tbl where msg_from=? and status like 'ILL-Answer|Locations-provided%' group by year, monthnum, month order by year, monthnum, month", { Slice => {} }, $oid);
	foreach my $row (@$aryref) {
	    $Stats{ $row->{year} }{ $row->{monthnum} }{month} = $row->{month};
	    $Stats{ $row->{year} }{ $row->{monthnum} }{forward_to_branch} = 0 unless (exists $Stats{ $row->{year} }{ $row->{monthnum} }{forward_to_branch});
	    $Stats{ $row->{year} }{ $row->{monthnum} }{forward_to_branch} += $row->{forward_to_branch};
	}
	
	# the 'msg_from is not null' bit has to do with an ancient bug that created "phantom" requests... requests to/from null.
	# the bug has been fixed, but libraries are still cleaning up their data (by cancelling the phantom requests).
	$aryref = $self->dbh->selectall_arrayref("select extract(YEAR from ts) as year, extract(MONTH from ts) as monthnum, to_char(ts, 'Month') as month, count(request_id) as borrower_cancelled from requests_$tbl where msg_to=? and status='Cancelled' and msg_from is not null group by year, monthnum, month order by year, monthnum, month", { Slice => {} }, $oid);
	foreach my $row (@$aryref) {
	    $Stats{ $row->{year} }{ $row->{monthnum} }{month} = $row->{month};
	    $Stats{ $row->{year} }{ $row->{monthnum} }{borrower_cancelled} = 0 unless (exists $Stats{ $row->{year} }{ $row->{monthnum} }{borrower_cancelled});
	    $Stats{ $row->{year} }{ $row->{monthnum} }{borrower_cancelled} += $row->{borrower_cancelled};
	}
    }

    return \%Stats;
}

#----------------------------------------------------------------------------------
sub get_library_from_username {
    my $self = shift;
    my $username = shift;
    # Get this user's library id
    my $hr_id = $self->dbh->selectrow_hashref(
	"select o.oid, o.org_name from users u left join org o on (u.oid = o.oid) where u.username=?",
	undef,
	$username
	);
    return ($hr_id->{oid}, $hr_id->{org_name});
}


1; # so the 'require' or 'use' succeeds

