#!/usr/bin/perl
use ZOOM;
use MARC::Record;

my @zservers = qw/SCRL SWMR/;
my %cnx;
$cnx{'SCRL'}    = "206.45.116.103:210/ILS";
$cnx{'SWMR'}    = "216.130.92.141:210/Melita_ILS";
$cnx{'RRNR'}    = "24.76.72.252:210/Main";
$cnx{'Portage'} = "24.79.32.253:210/Destiny";
$cnx{'PLS'}     = "library.gov.mb.ca:210/maplin";

my %titles;
foreach my $target (@zservers) {

    my $conn = new ZOOM::Connection( $cnx{ $target } );
    print "\n--[ title browse ]----\n";
    my $pqf = '@attr 1=4 @attr 2=3 @attr 3=1 @attr 4=1 "the power of"';
    print "$pqf\n";
    my $rs = $conn->search_pqf($pqf);
    my $n = $rs->size();
    print "$target, $n record(s) found.\n";
    
    $rs->records( 0, $n, 0);

    my $i = 0;
    while ($i < 1000) {
	last if ($i >= $n);
#	print $rs->record_immediate($i)->render;
	my $marc;
	eval { $marc = new_from_usmarc MARC::Record($rs->record_immediate($i)->raw()); };
	if ($marc) {
	    my $ind2 = $marc->field('245')->indicator(2) || 0;
	    my $t = ucfirst( substr($marc->title, $ind2) . " [$target]");
	    $titles{ $t } += 1;
	} else {
	    $titles{ "__error converting to MARC" } += 1;
	}
	$i++;
    }
    $rs->destroy;
    $conn->destroy;
}

print "\nsorted\n------\n";
foreach my $title (sort keys %titles) {
    print $titles{ $title } . "\t" . $title . "\n";
}

