#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use DBI;
#use JSON;
use GD::Barcode;
use GD::Barcode::Code39;
use MIME::Base64;
use Data::Dumper;

my $query = new CGI;
my $reqid = $query->param('reqid');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 0, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

# sql to get the slip info
#my $SQL = "select r.id, r.title, r.author, r.patron_barcode, l.library, ra.message from request r left join requests_active ra on r.id = ra.request_id left join libraries l on ra.msg_from = l.lid where r.id=? and ra.status='Shipped'";
my $SQL = "select 
  r.id, 
  g.title, 
  g.author, 
  g.patron_barcode, 
  l.library, 
  ra.message 
from requests_active ra
  left join request r on r.id=ra.request_id
  left join request_chain c on c.chain_id = r.chain_id
  left join request_group g on g.group_id = c.group_id
  left join libraries l on l.lid = ra.msg_from
where 
  r.id=? 
  and ra.status='Shipped'
";

my $href;
eval {
    $href = $dbh->selectrow_hashref($SQL, undef, $reqid );
};
if ($@) {
    # $sth->err and $DBI::err will be true if error was from DBI
    warn $@; # print the error
    #... # do whatever you need to deal with the error
}
print Dumper($href);

my $slips_href;
eval {
    $slips_href = $dbh->selectrow_hashref("select slips_with_barcodes from libraries where lid=(select requester from request where id=?)", 
					  undef, 
					  $reqid
	);
};
if ($@) {
    warn $@;
}
$dbh->disconnect;

print "Content-Type:text/html\n\n";
print "<html><head></head><body>\n";
print "<h4>Interlibrary Loan</h4>\n";
print '<p>for patron ' . $href->{patron_barcode} . "</p>\n";

if ($slips_href->{slips_with_barcodes}) {
#    if (( $href->{patron_barcode} ) && ( $href->{patron_barcode} =~ /^\d+$/)) {
    if ( $href->{patron_barcode} ) {
        # generate barcodes (code39 requires '*' as start and stop characters)
	my $oGdBar;
	my $bcimg;
	eval {
	    $oGdBar = GD::Barcode::Code39->new( '*' . $href->{patron_barcode} . '*' );
	    die $GD::Barcode::Code39::errStr unless($oGdBar);     #Invalid Characters
	};
	if ($@) {
	    # warn $@;
	    print "<p>Unable to create scannable patron barcode image.</p>\n";
	} else {
	    $bcimg = encode_base64($oGdBar->plot->png);
	    print "<p><img id=\"bcimg\" src=\"data:image/png;base64,$bcimg\"></p>\n";
	}
    } else {
	print "<p>Scannable patron barcode image not available.</p>\n";
    }
}

print "<hr>\n";
print '<p style="text-align:center">' . $href->{title} . "</p>\n" if ($href->{title});
print '<p style="text-align:center"><em>' . $href->{author} . "</em></p>\n" if ($href->{author});
print '<p style="text-align:center"><strong><br/>' . $href->{message} . "<br/></strong></p>\n";  # due YYYY-MM-DD
print "<hr><p>Borrowed for you from</p>\n";
print "<p>" . $href->{library} . "</p>\n";  # lender
print "</body></html>\n";
