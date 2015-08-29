#!/usr/bin/perl

use CGI;
use CGI::Session;
use DBI;
use JSON;

my $query = new CGI;
my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
if (($session->is_expired) || ($session->is_empty)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
    exit;
}
my $oid = $query->param('oid');
my $barcode = $query->param('barcode');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

$dbh->{AutoCommit} = 0;  # enable transactions, if possible
$dbh->{RaiseError} = 1;
eval {
    my $SQL = "update rotations set previous_library = current_library, current_library = ?, ts = now() where barcode = ?";
    my $rows = $dbh->do($SQL, undef, $oid, $barcode);
    $dbh->commit;   # commit the changes if we get this far
};
if ($@) {
    warn "Transaction aborted because $@";
    # now rollback to undo the incomplete changes
    # but do it in an eval{} as it may also fail
    eval { $dbh->rollback };
    # add other application on-error-clean-up code here
}

# sql to get this rotation item
my $SQL = "select 
 r.id,
 r.callno,
 r.title, 
 r.author,
 r.barcode,
 o1.symbol as current_library,
 o2.symbol as previous_library,
 r.ts as timestamp
from 
 rotations r
 left join org o1 on o1.oid=r.current_library
 left join org o2 on o2.oid=r.previous_library
where 
  barcode=? 
";

my $aref = $dbh->selectall_arrayref($SQL, { Slice => {} }, $barcode );

$SQL = "select coalesce(sum(circs),0) as count from rotations_stats where barcode=?";
my $circs = $dbh->selectrow_arrayref($SQL, { Slice => {} }, $barcode );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { item => $aref, circs => $circs->[0] });
