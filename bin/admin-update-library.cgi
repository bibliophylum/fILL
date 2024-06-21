#!/usr/bin/perl

use CGI;
use CGI::Session;
use DBI;
use JSON;
#use Data::Dumper;

my $q = new CGI;
my $session;
if (($ENV{GATEWAY_INTERFACE}) && ($ENV{GATEWAY_INTERFACE} =~ /CGI/)) {  # only worry about session if we're a cgi
    $session = CGI::Session->load(undef, $q, {Directory=>"/tmp"});
    if (($session->is_expired) || ($session->is_empty)) {
	print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
	exit;
    }
}

my %parms;
my @inParms = $q->param;
foreach my $parm_name (@inParms) {
    $parms{$parm_name} = $q->param($parm_name);
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

my $SQL;
my $error_message;
my $retval = 0;
$dbh->{AutoCommit} = 0;  # enable transactions, if possible
$dbh->{RaiseError} = 1;
eval {
    if (($parms{"new-pw"}) && ($parms{"editUID"})) {
	$retval = $dbh->do("update users set password=md5(?) where uid=?",undef,
			   $parms{"new-pw"},
			   $parms{"editUID"}
	    );
    } else {
	$error_message = "missing pw and/or editUID";
    }
    $dbh->commit;   # commit the changes if we get this far
};
if ($@) {
    $retval = 0;
    $error_message = "Transaction aborted because $@";
    # now rollback to undo the incomplete changes
    # but do it in an eval{} as it may also fail
    eval { $dbh->rollback };
    # add other application on-error-clean-up code here
}

$dbh->disconnect;
    
print "Content-Type:application/json\n\n" . to_json( { success => $retval ,
						       error_message => $error_message
						     });
