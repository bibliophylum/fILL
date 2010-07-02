#!/usr/bin/perl

use CGI;
use DBI;

my $query = new CGI;
my $sessionid = $query->param('sessionid');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

my $aref_status = $dbh->selectall_arrayref("select s.sessionid, s.zid, s.event, s.msg, z.name from status_check s, zservers z where s.zid = z.id and s.sessionid=? order by z.name",
					    { Slice => {} },
					    $sessionid
		       );

my $html = "<table><tr><td><strong>zServer</strong></td><td><strong>Status</strong></td></tr>";
my $is_still_processing = 0;
foreach my $href (@$aref_status) {
    $is_still_processing = 1 if (($href->{event} != 99) && ($href->{event} != 4));
    $html .= "<tr><td>" . $href->{name} . "</td><td>" . $href->{msg} . "</td></tr>";
}
$html .= "</table>";

# Build response
my $response;
$response = "Content-Type:text/plain\n\n";
$response .= $is_still_processing ? "working|" : "done|";
if ($query->param('showstatus')) {
    $response .= $html;
} else {
    $response .= "Searching all available or selected libraries in Manitoba...<br><img src='/img/progressbar_green.gif'>";
}

# Send it out
print $response;

$dbh->disconnect;
