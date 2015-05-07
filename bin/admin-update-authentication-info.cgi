#!/usr/bin/perl

use CGI;
use CGI::Session;
use DBI;
use JSON;
#use Data::Dumper;

my $q = new CGI;
my $session = CGI::Session->load(undef, $q, {Directory=>"/tmp"});
if (($session->is_expired) || ($session->is_empty)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
    exit;
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
    if (($parms{"rAuthtype"}) && ($parms{"editLID"})) {
	# delete old data, if any:
	$dbh->do("delete from library_sip2 where lid=?", undef, $parms{"editLID"});
	$dbh->do("delete from library_nonsip2 where lid=?", undef, $parms{"editLID"});
	
	if ($parms{"rAuthtype"} =~ /SIP2/) {
	    $retval = $dbh->do("insert into library_sip2 (lid,enabled,host,port,terminator,sip_server_login,sip_server_password,validate_using_info) values (?,?,?,?,?,?,?,?)",undef,
			       $parms{"editLID"},
			       $parms{"sipEnabled"},
			       $parms{"sipHost"},
			       $parms{"sipPort"},
			       $parms{"sipTeminator"} eq "Standard" ? undef : "\r",
			       $parms{"sipServerLogin"},
			       $parms{"sipServerPass"},
			       $parms{"sipMethod"} eq "Info" ? 1 : 0
		);
	    $dbh->do("update libraries set patron_authentication_method=? where lid=?", undef, 
		     "sip2", 
		     $parms{"editLID"}
		);
	    
	} elsif ($parms{"rAuthtype"} =~ /Other/) {
	    $retval = $dbh->do("insert into library_nonsip2 (lid,enabled,auth_type,url) values (?,?,?,?)",undef,
			       $parms{"editLID"},
			       $parms{"nonsipEnabled"},
			       $parms{"nonsipAuthType"},
			       $parms{"nonsipURL"}
		);
	    $dbh->do("update libraries set patron_authentication_method=? where lid=?", undef, 
		     $parms{"nonsipAuthType"}, 
		     $parms{"editLID"}
		);

	} else {  # None
	    $dbh->do("update libraries set patron_authentication_method=? where lid=?", undef, 
		     undef, 
		     $parms{"editLID"}
		);
	}
    } else {
	$error_message = "missing rAuthtype and/or editLID";
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
