#!/usr/bin/perl
use ZOOM;
use DBI;
use Log::Dispatch;
use Log::Dispatch::File;
use Log::Dispatch::Screen;

# Set up logging
my $dispatcher = Log::Dispatch->new;
$dispatcher->add( Log::Dispatch::File->new( name      => 'file1',
                                            min_level => 'debug',
                                            filename  =>  '/opt/maplin3/logs/zserver_alive.log',
					    mode      => '>>',
                  )
    );
# A cron'd script will mail any output to the owner... so let's not have output :-)
#$dispatcher->add( Log::Dispatch::Screen->new( name      => 'screen',
#                                              min_level => 'warning',
#                                              stderr    => 1,
#                  )
#    );


# Connect to database
my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    );

# Get list of available servers from db
my $SQL = "SELECT id, name, z3950_connection_string, email_address, alive, notification_sent FROM zservers WHERE available=1 and isstandardresource=1";
my $ar_conn = $dbh->selectall_arrayref( $SQL, { Slice => {} } );
my $rows_affected;

# Test each zserver
for (my $i = 0; $i < @$ar_conn; $i++) {
#    $dispatcher->debug( "testing " . $ar_conn->[$i]{name} . "\n" );
    eval {
	my $optionset = new ZOOM::Options();
	$optionset->option(implementationName => "Maplin connection tester");
	$optionset->option(preferredRecordSyntax => "usmarc");
	$optionset->option(async => 0);
	$optionset->option(count => 1);
	$optionset->option(timeout => 60);
	my $conn = create ZOOM::Connection($optionset);
	$conn->connect($ar_conn->[$i]{z3950_connection_string}, 0);

	my $resultset = $conn->search_pqf('@attr 1=4 dinosaur');
	my $n = $resultset->size();
    };
    if ($@) {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
	$year += 1900;
	$mon += 1;
	my $message = sprintf("%4d-%02d-%02d %02d:%02d:%02d ", $year,$mon,$mday,$hour,$min,$sec);
	$message .= "zid: " . $ar_conn->[$i]{id} . ", " . $ar_conn->[$i]{name} . ", ";
	my $err = $@->render();
	$dispatcher->error( $message, $err, "\n" );

	$rows_affected = $dbh->do( "UPDATE zservers SET alive=0 WHERE id=?", undef, $ar_conn->[$i]{id});
	if (defined $rows_affected) {
	    $dispatcher->debug( $ar_conn->[$i]{name} . ": set server to not-alive\n" );
	} else {
	    $dispatcher->error( $ar_conn->[$i]{name} . ": could not set server to not-alive!\n" );
	}

	unless (1 == $ar_conn->[$i]{notification_sent}) {
	    # Send an email about it, if we haven't already
	    eval {
		my $sendmail = "/usr/sbin/sendmail -t";
		open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
		print SENDMAIL "To: David.Christensen\@gov.mb.ca\n";
		#print SENDMAIL "To: " . $ar_conn->[$i]{email_address} . "\n";
		print SENDMAIL "Subject: Maplin-3 message: zServer " . $ar_conn->[$i]{id} . "(" . $ar_conn->[$i]{name} . ") down\n";
		print SENDMAIL "Content-type: text/plain\n\n";
		print SENDMAIL "Scheduled test of this zserver reported problems.\n";
		print SENDMAIL "\n$message\n$err\n";
		close(SENDMAIL);
	    };
	    if ($@) {
		$dispatcher->error( $message, "could not send an email about it!\n");
	    } else {
		my $rows_affected = $dbh->do( "UPDATE zservers SET notification_sent=1 WHERE id=?", undef, $ar_conn->[$i]{id});
		if (defined $rows_affected) {
		    $dispatcher->debug( $ar_conn->[$i]{name} . ": set server to notification-sent\n" );
		} else {
		    $dispatcher->error( $ar_conn->[$i]{name} . ": could not set server to notification-sent!\n" );
		}
	    }
	}
	
    } else {

#	$dispatcher->debug( "server ok\n" );

	# no problem - raise the dead if we need to
	unless (1 == $ar_conn->[$i]{alive}) {
	    $dispatcher->debug( $ar_conn->[$i]{name} . ": server was not-alive, raising the dead\n" );
	    $rows_affected = $dbh->do( "UPDATE zservers SET alive=1 WHERE id=?", undef, $ar_conn->[$i]{id});
	    if (defined $rows_affected) {
		$dispatcher->debug( $ar_conn->[$i]{name} . ": set server to alive\n" );
	    } else {
		$dispatcher->error( $ar_conn->[$i]{name} . ": could not set server to alive!\n" );
	    }

	    # Send an email about it
	    eval {
		my $sendmail = "/usr/sbin/sendmail -t";
		open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
		print SENDMAIL "To: David.Christensen\@gov.mb.ca\n";
		#print SENDMAIL "To: " . $ar_conn->[$i]{email_address} . "\n";
		print SENDMAIL "Subject: Maplin-3 message: zServer " . $ar_conn->[$i]{id} . "(" . $ar_conn->[$i]{name} . ") alive again.\n";
		print SENDMAIL "Content-type: text/plain\n\n";
		print SENDMAIL "Scheduled test of this zserver reported that it is now searchable again.\n";
		print SENDMAIL "\n$message\n$err\n";
		close(SENDMAIL);
	    };
	    if ($@) {
		$dispatcher->error( $message, "could not send an email about it!\n");
	    } else {
		$rows_affected = $dbh->do( "UPDATE zservers SET notification_sent=0 WHERE id=?", undef, $ar_conn->[$i]{id});
		if (defined $rows_affected) {
		    $dispatcher->debug( $ar_conn->[$i]{name} . ": reset server notification_sent flag to 0\n" );
		} else {
		    $dispatcher->error( $ar_conn->[$i]{name} . ": could not reset server notification_sent flag to 0!\n" );
		}
		
	    }
	}

    }
}


