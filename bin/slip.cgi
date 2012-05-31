#!/usr/bin/perl

use CGI;
use DBI;
#use JSON;
use Data::Dumper;

my $query = new CGI;
my $reqid = $query->param('reqid');

# sql to get the slip info
my $SQL = "select r.id, r.title, r.author, r.patron_barcode, l.library, ra.message from request r left join requests_active ra on r.id = ra.request_id left join libraries l on ra.msg_from = l.lid where r.id=? and ra.status='Shipped'";

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 0, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;
my $href;
eval {
    $href = $dbh->selectrow_hashref($SQL, undef, $reqid );
};
if ($@) {
    # $sth->err and $DBI::err will be true if error was from DBI
    warn $@; # print the error
    #... # do whatever you need to deal with the error
}
$dbh->disconnect;

print "Content-Type:text/html\n\n";
print "<html><head></head><body>\n";
print "<h4>Interlibrary Loan</h4>\n";
print '<p>for patron ' . $href->{patron_barcode} . "</p>\n";
print "<hr>\n";
print '<p style="text-align:center">' . $href->{title} . "</p>\n";
print '<p style="text-align:center"><em>' . $href->{author} . "</em></p>\n";
print '<p style="text-align:center"><strong><br/>' . $href->{message} . "<br/></strong></p>\n";  # due YYYY-MM-DD
print "<hr><p>Borrowed for you from</p>\n";
print "<p>" . $href->{library} . "</p>\n";  # lender
print "</body></html>\n";
