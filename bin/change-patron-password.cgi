#!/usr/bin/perl

use CGI;
use DBI;
use JSON;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Data::Dumper;

my $query = new CGI;
#print STDERR Dumper($query->param(pass));
#print STDERR Dumper($query->param(newpass));
#print STDERR Dumper($query->param(pid));
#exit;

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $retval = 0;
my $SQL = "select password from patrons where pid=?";
my @row = $dbh->selectrow_array( $SQL, undef, $query->param('pid'));
if (@row) {
    #print STDERR "db  : [" . $row[0] . "]\n";
    #print STDERR "parm: [" . md5_hex($query->param('pass')) . "]\n";
    if ($row[0] eq md5_hex($query->param('pass'))) {
	$SQL = "update patrons set password=md5(?) where pid=?";
	$retval = $dbh->do( $SQL, undef, $query->param('newpass'),$query->param('pid') );
    }
}
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
