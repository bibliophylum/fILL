#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $rid = $query->param('rid');
my $lid = $query->param('lid');
my $tracking = $query->param('tracking');

my $success = 0;

unless ((defined $rid) && (defined $lid) && (defined $tracking)) {
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
	$dbh->do("UPDATE shipping_tracking_number set tracking=?, lid=? where rid=?",
		 undef, $tracking,$lid,$rid);
	
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
	$dbh->do("INSERT INTO shipping_tracking_number (lid,rid,tracking) VALUES (?,?,?)",
		 undef,$lid,$rid,$tracking);
	
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
