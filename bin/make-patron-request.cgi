#!/usr/bin/perl

use CGI;
use CGI::Session;
use DBI;
use JSON;
use Encode;
use Text::Unidecode;
use Data::Dumper;

my %SPRUCE_TO_MAPLIN = (
    'MWPL' => 'MWPL',
    'MAOW' => 'MAOW',        # Altona
    'MMIOW' => 'MMIOW',      # Miami
    'MMOW' => 'MMOW',        # Morden
    'MWOW' => 'MWOW',        # Winkler
    'MBOM' => 'MBOM',        # Boissevain
    'MANITOU' => 'MMA',
    'STEROSE' => 'MSTR',
    'AB' => 'MWP',
    'MWP' => 'MWP',
    'MSTOS' => 'MSTOS',      # Stonewall
    'MTSIR' => 'MTSIR',      # Teulon
    'MMCA' => 'MMCA',        # McAuley
    'MVE' => 'MVE',          # Virden
    'ME' => 'ME',            # Elkhorn
    'MS' => 'MS',            # Somerset
    'MSOG' => 'MSOG',        # Glenwood and Souris
    'MDB' => 'MDB',          # Bren Del Win
    'MPLP' => 'MPLP',        # Portage
    'MSSC' => 'MSSC',        # Shilo
    'MEC' => 'MEC',
    'MNH' => 'MNH',
    'MSRH' => 'UCN',         # University College of the North
    'MTK' => 'MTK',          #   libraries and campuses
    'MTPK' => 'MTPK',
    'MWMW' => 'UCN',
    'MRD' => 'MRD',          # Russell
    'MBI' => 'MBI',          # Binscarth
    'MSCL' => 'MSCL',        # St.Claude
    );

my %WESTERN_MB_TO_MAPLIN = (
    'Brandon Public Library' => 'MBW',
    'Neepawa Public Library' => 'MNW',
    'Carberry / North Cypress Library' => 'MCNC',
    'Glenboro / South Cypress Library' => 'MGW',
    'Hartney / Cameron Library' => 'MHW',
    );


my $q = new CGI;
my $session = CGI::Session->load(undef, $q, {Directory=>"/tmp"});
if (($session->is_expired) || ($session->is_empty)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
    exit;
}

my $username = $q->param('username');
#my $oid = $q->param('oid');
my $oid = $session->param('fILL-oid');
my $pid = $session->param('fILL-pid');
my $library = $session->param('fILL-library');
my $is_enabled = $session->param('fILL-is_enabled');

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

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

## Get this user's (requester's) library id
#my $hr_id = $dbh->selectrow_hashref(
#    "select p.pid, p.home_library_id, o.org_name, p.is_enabled from patrons p left join org o on (o.oid = p.home_library_id) where p.username=? and p.home_library_id=?",
#    undef,
#    $username,
#    $oid
#    );
#
##print STDERR "requester's (" . $username . ") id info: " . Dumper($hr_id) . "\n";
#
#my $pid = $hr_id->{pid};
#
##print STDERR "pid: $pid\n";
##exit; 
#
##my $oid = $hr_id->{home_library_id};
#my $library = $hr_id->{org_name};
#my $is_enabled = $hr_id->{is_enabled};

if (not defined $pid) {
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
my $pubdate = $q->param('pubdate');
my $isbn = $q->param('isbn');

# check if this is a duplicate of an existing request (e.g. patron hit 'reload')
my $matching = $dbh->selectall_arrayref(
    "select prid from patron_request where pid=? and oid=? and title=? and author=?",
    undef,
    $pid, $oid, $title, $author
    ); 
if (@$matching) {
    $dbh->disconnect;
    
    print "Content-Type:application/json\n\n" . to_json( { success => 1,
							   user => $username,
							   title => $title,
							   author => $author,
							   medium => $medium,
							   library => $library,
							   prid => $matching->[0][0]
							 } );
    exit;
}

my $medium;
my @sources;
foreach my $num (sort keys %sources) {

    $medium = $sources{$num}{'medium'};  # fILL-client.js groups by medium, so all sources' mediums should be the same.
    delete $sources{$num}{'medium'};

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
#print STDERR "make-patron-request.cgi sources array:\n" . Dumper(@sources) ;

$title   = sprintf("%.1024s", $title);
$author  = sprintf("%.256s", $author);
$medium  = sprintf("%.80s", $medium);
$pubdate = sprintf("%.20s", $pubdate);
$isbn    = sprintf("%.20s", $isbn);

#print STDERR "pid [$pid] oid [$oid] isbn [$isbn] pubdate [$pubdate] title [$title]\n";

# These should be atomic...
# create the request_group
$dbh->do("INSERT INTO patron_request (title, author, medium, pid, oid, pubdate, isbn) VALUES (?,?,?,?,?,?,?)",
	 undef,
	 $title,
	 $author,
	 $medium,
	 $pid,     # requester
	 $oid,     # requester's home library
	 $pubdate,
	 $isbn
    );
my $pr_id = $dbh->last_insert_id(undef,undef,undef,undef,{sequence=>'patron_request_seq'});

# ...end of atomic

# re-consolidate MW locations - they handle ILL for all branches centrally
my $index = 0; 
my $cn;
my $primary;
while ($index <= $#sources ) { 
    if ((!exists( $sources[$index]{'symbol'} )) || (!defined( $sources[$index]{'symbol'} )) ) {
	#print STDERR "sources[" . $index . "] has no symbol:\n" . Dumper( $sources[$index] );
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
my $SQL = "select o.oid, o.symbol, sum(CASE WHEN status = 'Shipped' THEN 1 ELSE 0 END) - sum(CASE WHEN status='Received' THEN 1 ELSE 0 END) as net from org o left outer join requests_active ra on ra.msg_from=o.oid group by o.oid, o.symbol order by o.symbol";
my $nblc_href = $dbh->selectall_hashref($SQL,'symbol');
foreach my $src (@unique_sources) {
    if (exists $nblc_href->{ $src->{symbol} }) {
	$src->{net} = $nblc_href->{ $src->{symbol} }{net};
	$src->{oid} = $nblc_href->{ $src->{symbol} }{oid};
    } else {
	$src->{net} = 0;
	$src->{oid} = undef;
	#print STDERR $src->{'symbol'} . " not found in net-borrower/net-lender counts.";
    }
}

# sort sources by net borrower/lender count
my @sorted_sources = sort { $a->{net} <=> $b->{net} } @unique_sources;

# create the sources list for this request
my $sequence = 1;
$SQL = "INSERT INTO patron_request_sources (sequence_number, oid, call_number, prid) VALUES (?,?,?,?)";
foreach my $src (@sorted_sources) {
    my $lenderID = $src->{oid};
    next unless defined $lenderID;
    my $rows_added = $dbh->do($SQL,
			      undef,
			      $sequence++,
			      $lenderID,
			      substr($src->{"callnumber"},0,99),  # some libraries don't clean up copy-cat recs
			      $pr_id,
	);
    unless (1 == $rows_added) {
	print STDERR "Could not add source: prid $pr_id, sequence_number " . ($sequence - 1), ", library $lenderID, call_number " . substr($src->{"callnumber"},0,99);
    }
}


$dbh->disconnect;
    
print "Content-Type:application/json\n\n" . to_json( { success => 1,
						       user => $username,
						       title => $title,
						       author => $author,
						       medium => $medium,
						       library => $library,
						       prid => $pr_id
						     } );
