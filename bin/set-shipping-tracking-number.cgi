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
my $rid = $query->param('rid');
my $oid = $query->param('oid');
my $tracking = $query->param('tracking');

my $success = 0;

unless ((defined $rid) && (defined $oid) && (defined $tracking)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0 } );
    exit 0;
}

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
                       "mapapp",
                       "maplin3db",
                       {AutoCommit => 0,  # enable transactions! 
                        RaiseError => 1, 
                        PrintError => 0,
                       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $SQL = "select count(rid) from shipping_tracking_number where rid=?";
my $isUpdate = $dbh->selectrow_array($SQL,undef,$rid);
if ((defined $isUpdate) && ($isUpdate != 0)) {
    eval {
	$dbh->do("UPDATE shipping_tracking_number set tracking=?, oid=? where rid=?",
		 undef, $tracking,$oid,$rid);
	
	$dbh->commit;
    };  # end of eval
    if ($@) {
	warn "set-shipping-tracking-number transaction aborted because $@";
	eval { $dbh->rollback };
    } else {
	$success = 1;
    }
} else {
    # does not exist, so insert
    eval {
	$dbh->do("INSERT INTO shipping_tracking_number (oid,rid,tracking) VALUES (?,?,?)",
		 undef,$oid,$rid,$tracking);
	
	$dbh->commit;
    };  # end of eval
    if ($@) {
	warn "set-shipping-tracking-number transaction aborted because $@";
	eval { $dbh->rollback };
    } else {
	$success = 1;
    }
}
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $success } );
