#!/usr/bin/perl
use strict;
use warnings;

use CGI;
use CGI::Session;
use DBI;
use JSON;
#use Data::Dumper;

my $query = new CGI;
my $session;
if (($ENV{GATEWAY_INTERFACE}) && ($ENV{GATEWAY_INTERFACE} =~ /CGI/)) {  # only worry about session if we're a cgi
    $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
    if (($session->is_expired) || ($session->is_empty)) {
        print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
        exit;
    }
}

my $oid = $query->param('oid');
exit unless $oid;

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
                       "mapapp",
                       "maplin3db",
                       {AutoCommit => 1, 
                        RaiseError => 1, 
                        PrintError => 0,
                       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $aryref;
my %Stats;

# Borrowing
# Note: counting stats for requests initiated within the month, regardless of when the answers came.
foreach my $tbl (qw/active history/) {
    my $req_tbl = ($tbl eq 'active') ? "request" : "request_closed";
    
    $aryref = $dbh->selectall_arrayref("select extract(YEAR from ts) as year, extract(MONTH from ts) as monthnum, to_char(ts,'Month') as month, count(distinct rc.chain_id) as books_requested, count(distinct request_id) as requests_made from $req_tbl rc left join requests_$tbl h on h.request_id=rc.id where h.msg_from=? and h.status='ILL-Request' group by year, monthnum, month order by year, monthnum, month", { Slice => {} }, $oid);
    foreach my $row (@$aryref) {
	$Stats{ $row->{year} }{ $row->{monthnum} }{month} = $row->{month};
	$Stats{ $row->{year} }{ $row->{monthnum} }{books_requested} = 0 unless (exists $Stats{ $row->{year} }{ $row->{monthnum} }{books_requested});
	$Stats{ $row->{year} }{ $row->{monthnum} }{books_requested} += $row->{books_requested};
	$Stats{ $row->{year} }{ $row->{monthnum} }{requests_made} = 0 unless (exists $Stats{ $row->{year} }{ $row->{monthnum} }{requests_made});
	$Stats{ $row->{year} }{ $row->{monthnum} }{requests_made} += $row->{requests_made};
    }
    
    $aryref = $dbh->selectall_arrayref("select extract(YEAR from ts) as year, extract(MONTH from ts) as monthnum, to_char(ts, 'Month') as month, count(request_id) as responded_unfilled from requests_$tbl where msg_to=? and status like 'ILL-Answer|Unfilled%' group by year, monthnum, month order by year, monthnum, month", { Slice => {} }, $oid);
    foreach my $row (@$aryref) {
	$Stats{ $row->{year} }{ $row->{monthnum} }{month} = $row->{month};
	$Stats{ $row->{year} }{ $row->{monthnum} }{responded_unfilled} = 0 unless (exists $Stats{ $row->{year} }{ $row->{monthnum} }{responded_unfilled});
	$Stats{ $row->{year} }{ $row->{monthnum} }{responded_unfilled} += $row->{responded_unfilled};
    }
    
    $aryref = $dbh->selectall_arrayref("select extract(YEAR from ts) as year, extract(MONTH from ts) as monthnum, to_char(ts, 'Month') as month, count(request_id) as shipped from requests_$tbl where msg_to=? and status='Shipped' group by year, monthnum, month order by year, monthnum, month", { Slice => {} }, $oid);
    foreach my $row (@$aryref) {
	$Stats{ $row->{year} }{ $row->{monthnum} }{month} = $row->{month};
	$Stats{ $row->{year} }{ $row->{monthnum} }{lender_shipped} = 0 unless (exists $Stats{ $row->{year} }{ $row->{monthnum} }{lender_shipped});
	$Stats{ $row->{year} }{ $row->{monthnum} }{lender_shipped} += $row->{shipped};
    }
    
    # To calculate the # of requests that we cancelled before receiving a reply:
    # 1. Find the requests we initiated in that time frame (status = 'ILL-Request')
    # 2. Ignore the requests that someone replied to (status like 'ILL-Answer%')
    # 3. Count the entries where status = 'Cancelled'
    $aryref = $dbh->selectall_arrayref("select extract(YEAR from ts) as year, extract(MONTH from ts) as monthnum, to_char(ts, 'Month') as month, count(request_id) as we_cancelled from requests_$tbl where msg_from=? and status='Cancelled' and request_id in (select request_id from requests_$tbl where msg_from=? and status='ILL-Request') and request_id not in (select request_id from requests_$tbl where msg_to=? and status like 'ILL-Answer%') group by year, monthnum, month order by year, monthnum, month", { Slice => {} }, $oid, $oid, $oid);
    foreach my $row (@$aryref) {
	$Stats{ $row->{year} }{ $row->{monthnum} }{month} = $row->{month};
	$Stats{ $row->{year} }{ $row->{monthnum} }{we_cancelled} = 0 unless (exists $Stats{ $row->{year} }{ $row->{monthnum} }{we_cancelled});
	$Stats{ $row->{year} }{ $row->{monthnum} }{we_cancelled} += $row->{we_cancelled};
    }
    
}

# Lending
# Counting answers made within the date range, regardless of when the request was initiated.
foreach my $tbl (qw/active history/) {
    $aryref = $dbh->selectall_arrayref("select extract(YEAR from ts) as year, extract(MONTH from ts) as monthnum, to_char(ts,'Month') as month, count(request_id) as requests_to_lend from requests_$tbl where msg_to=? and status='ILL-Request' group by year, monthnum, month order by year, monthnum, month", { Slice => {} }, $oid);
    foreach my $row (@$aryref) {
	$Stats{ $row->{year} }{ $row->{monthnum} }{month} = $row->{month};
	$Stats{ $row->{year} }{ $row->{monthnum} }{requests_to_lend} = 0 unless (exists $Stats{ $row->{year} }{ $row->{monthnum} }{requests_to_lend});
	$Stats{ $row->{year} }{ $row->{monthnum} }{requests_to_lend} += $row->{requests_to_lend};
    }
    
    $aryref = $dbh->selectall_arrayref("select extract(YEAR from ts) as year, extract(MONTH from ts) as monthnum, to_char(ts, 'Month') as month, count(request_id) as could_not_fill from requests_$tbl where msg_from=? and status like 'ILL-Answer|Unfilled%' group by year, monthnum, month order by year, monthnum, month", { Slice => {} }, $oid);
    foreach my $row (@$aryref) {
	$Stats{ $row->{year} }{ $row->{monthnum} }{month} = $row->{month};
	$Stats{ $row->{year} }{ $row->{monthnum} }{could_not_fill} = 0 unless (exists $Stats{ $row->{year} }{ $row->{monthnum} }{could_not_fill});
	$Stats{ $row->{year} }{ $row->{monthnum} }{could_not_fill} += $row->{could_not_fill};
    }
    
    $aryref = $dbh->selectall_arrayref("select extract(YEAR from ts) as year, extract(MONTH from ts) as monthnum, to_char(ts, 'Month') as month, count(request_id) as shipped from requests_$tbl where msg_from=? and status='Shipped' group by year, monthnum, month order by year, monthnum, month", { Slice => {} }, $oid);
    foreach my $row (@$aryref) {
	$Stats{ $row->{year} }{ $row->{monthnum} }{month} = $row->{month};
	$Stats{ $row->{year} }{ $row->{monthnum} }{shipped} = 0 unless (exists $Stats{ $row->{year} }{ $row->{monthnum} }{shipped});
	$Stats{ $row->{year} }{ $row->{monthnum} }{shipped} += $row->{shipped};
    }
    
    $aryref = $dbh->selectall_arrayref("select extract(YEAR from ts) as year, extract(MONTH from ts) as monthnum, to_char(ts, 'Month') as month, count(request_id) forward_to_branch from requests_$tbl where msg_from=? and status like 'ILL-Answer|Locations-provided%' group by year, monthnum, month order by year, monthnum, month", { Slice => {} }, $oid);
    foreach my $row (@$aryref) {
	$Stats{ $row->{year} }{ $row->{monthnum} }{month} = $row->{month};
	$Stats{ $row->{year} }{ $row->{monthnum} }{forward_to_branch} = 0 unless (exists $Stats{ $row->{year} }{ $row->{monthnum} }{forward_to_branch});
	$Stats{ $row->{year} }{ $row->{monthnum} }{forward_to_branch} += $row->{forward_to_branch};
    }
    
    # the 'msg_from is not null' bit has to do with an ancient bug that created "phantom" requests... requests to/from null.
    # the bug has been fixed, but libraries are still cleaning up their data (by cancelling the phantom requests).
    $aryref = $dbh->selectall_arrayref("select extract(YEAR from ts) as year, extract(MONTH from ts) as monthnum, to_char(ts, 'Month') as month, count(request_id) as borrower_cancelled from requests_$tbl where msg_to=? and status='Cancelled' and msg_from is not null group by year, monthnum, month order by year, monthnum, month", { Slice => {} }, $oid);
    foreach my $row (@$aryref) {
	$Stats{ $row->{year} }{ $row->{monthnum} }{month} = $row->{month};
	$Stats{ $row->{year} }{ $row->{monthnum} }{borrower_cancelled} = 0 unless (exists $Stats{ $row->{year} }{ $row->{monthnum} }{borrower_cancelled});
	$Stats{ $row->{year} }{ $row->{monthnum} }{borrower_cancelled} += $row->{borrower_cancelled};
    }
}

# build our array to pass to HTML::Template
my @allStats;
foreach my $year (sort keys %Stats) {
    my $href = $Stats{$year};
    foreach my $monthnum (sort keys %{$href}) {
	$href->{$monthnum}->{year} = $year;
	$href->{$monthnum}->{monthnum} = $monthnum;
	push @allStats, $href->{$monthnum};
    }
}
#    print STDERR Dumper(@allStats);


$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { report => [ @allStats ] } );
