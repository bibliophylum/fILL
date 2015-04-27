#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use CGI::Session;
use DBI;
use Text::CSV::Slurp;
use File::Copy qw(move);
use Data::Dumper;
use JSON;

my $query = new CGI;
my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
if (($session->is_expired) || ($session->is_empty)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
    exit;
}

my $uploads_dir = '/opt/fILL/ill_uploads';
my $archive_dir = '/opt/fILL/ill_loaded';

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
                       "mapapp",
                       "maplin3db",
                       {AutoCommit => 0,  # enable transactions! 
                        RaiseError => 1, 
                        PrintError => 0,
                       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $sth_getid = $dbh->prepare("select lid from libraries where name=?");
my $sth_currdata = $dbh->prepare("select lid, borrowed, loaned from libraries_untracked_ill where lid=?");
my $sth_update = $dbh->prepare("update libraries_untracked_ill set borrowed=borrowed+?, loaned=loaned+? where lid=?");
my $sth_insert = $dbh->prepare("insert into libraries_untracked_ill (lid,borrowed,loaned) values (?,?,?)");
my $sth_isSibling = $dbh->prepare("select
 case 
 when (? = (select parent_id from library_systems where child_id=?)) then 1
 when (? = (select parent_id from library_systems where child_id=?)) then 1 
 when ((select parent_id from library_systems where child_id=?) = (select parent_id from library_systems where child_id=?)) then 1
 else 0
 end
");


my %files;
chdir $uploads_dir || die "can't chdir to uploads directory $uploads_dir: $!";
opendir(my $dh, $uploads_dir) || die "can't opendir $uploads_dir: $!";
while(readdir $dh) {
    next unless -f "$uploads_dir/$_";
#    next unless /^\d{4}-\d{2}-\d{2}.csv$/; # uploaded files will be named like "2015-03-16.csv"
    $files{ $_ }{"filename"} = $_;
}
closedir $dh;

foreach my $fn (keys %files) {
    load_records( \%{ $files{$fn} } );
    move( "$uploads_dir/" . $files{ $fn }{"filename"}, "$archive_dir/" . $files{ $fn }{"filename"} );
}

$sth_getid->finish;
$sth_currdata->finish;
$sth_update->finish;
$sth_insert->finish;
$sth_isSibling->finish;
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( \%files );

#--------------------------------------------------------------------------------
sub is_sibling {
    my ($lib1, $lib2) = @_;
    my $lid1;
    my $lid2;

    my $rv = $sth_getid->execute($lib1);
    my $aref = $sth_getid->fetchrow_arrayref();
    if (defined $aref) {
	$lid1 = $aref->[0];
    }
    $rv = $sth_getid->execute($lib2);
    $aref = $sth_getid->fetchrow_arrayref();
    if (defined $aref) {
	$lid2 = $aref->[0];
    }

    #local $sth_isSibling->{TraceLevel} = "2";
    my $sibs = 0;
    if ($lid1 && $lid2) {
	$sth_isSibling->execute($lid1,$lid2, $lid2,$lid1, $lid1,$lid2);
	$aref = $sth_isSibling->fetchrow_arrayref();
	if (defined $aref) {
	    $sibs = $aref->[0];
	}
    }
    return $sibs;
}

#--------------------------------------------------------------------------------
sub load_records {
    my $fhash = shift;
    my $f = \%$fhash;

    chdir $uploads_dir || die "can't chdir to uploads directory $uploads_dir: $!";
    my $data = Text::CSV::Slurp->load(file => $f->{"filename"});
    my %update = ();
    my $cnt = 0;
    foreach my $href (@$data) {
	next if ($href->{"lender"} eq $href->{"borrower"});  # self-circ
#	if (is_sibling( $href->{"lender"}, $href->{"borrower"} )) {
#	    print STDERR $href->{"lender"} . " is a sibling of " . $href->{"borrower"} . "\n";
#	} else {
#	    print STDERR $href->{"lender"} . " is NOT a sibling of " . $href->{"borrower"} . "\n";
#	}
	next if (is_sibling( $href->{"lender"}, $href->{"borrower"} ));

	$cnt++;
	my $borrower_id;
	my $lender_id;
	
	my $rv = $sth_getid->execute($href->{"borrower"});
	my $aref = $sth_getid->fetchrow_arrayref();
	if (defined $aref) {
	    $borrower_id = $aref->[0];
	}
	$rv = $sth_getid->execute($href->{"lender"});
	$aref = $sth_getid->fetchrow_arrayref();
	if (defined $aref) {
	    $lender_id = $aref->[0];
	}
	
	if ($borrower_id && $lender_id) {
	    $update{$href->{"lender"}}{"loaned"} += $href->{"circ count"};
	    $update{$href->{"borrower"}}{"borrowed"} += $href->{"circ count"};
	}
    }
    #print Dumper(%update);
    $f->{"lines_in_csv"} = $cnt;
    my @report;
    $cnt = 0;
    foreach my $library (sort keys %update) {
	$cnt++;
	#print STDERR "$library\n";
	my %rec;
	$rec{"library"} = $library;
	$rec{"borrowed"} = $update{$library}{"borrowed"};
	$rec{"loaned"} = $update{$library}{"loaned"};
	my $rv = $sth_getid->execute($library);
	my $aref = $sth_getid->fetchrow_arrayref();
	if (defined $aref) {
	    my $id = $aref->[0];
	    # transaction time!
	    eval {
		$rv = $sth_currdata->execute($id);
		my $href = $sth_currdata->fetchrow_hashref();
		if (defined $href) {
		    # existing data in the libraries_untracked_ill table
		    $rv = $sth_update->execute($update{$library}{"borrowed"},$update{$library}{"loaned"},$id);
		    my $rows = $sth_update->rows;
		    $rv = ($rows == 0) ? "0E0" : $rows; # true if no error
		    $rec{"status"} = "$rv updated";
		} else {
		    # no existing data for this library
		    $rv = $sth_insert->execute($id,$update{$library}{"borrowed"},$update{$library}{"loaned"});
		    my $rows = $sth_insert->rows;
		    $rv = ($rows == 0) ? "0E0" : $rows; # true if no error
		    $rec{"status"} = "$rv created";
		}
		$dbh->commit;   # commit the changes if we get this far
	    };
	    if ($@) {
		print STDERR "$library: Transaction aborted because $@";
		# now rollback to undo the incomplete changes
		# but do it in an eval{} as it may also fail
		eval { $dbh->rollback };
		$rec{"error"} = "Transaction rolled back: $@";
	    }
	} else {
	    $rec{"error"} = "Does not exist in libraries table.";
	}
	push @report, \%rec;
    }
    $f->{"libraries"} = $cnt;
    $f->{"report"} = \@report;
}

