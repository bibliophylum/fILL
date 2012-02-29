#!/usr/bin/perl

use DBI;

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 0, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    );


# Get list of library ids db
$ary_ref = $dbh->selectcol_arrayref( "SELECT lid FROM libraries WHERE lid is not null ORDER BY lid" );
my $num_libraries = @$ary_ref;
for (my $i = 0; $i < $num_libraries; $i++) {
    print "lid: " . $ary_ref->[$i] . "\n";
    eval {
	for (my $j = 0; $j < $num_libraries; $j++) {
	    $dbh->do("INSERT INTO library_barcodes (lid, borrower, barcode) VALUES (?,?,?)",
		     undef,
		     $ary_ref->[$i],
		     $ary_ref->[$j],
		     'not configured',
		);
	}
	$dbh->commit;   # commit the changes if we get this far
    };
    if ($@) {
      warn "Transaction aborted because $@";
      # now rollback to undo the incomplete changes
      # but do it in an eval{} as it may also fail
      eval { $dbh->rollback };
  }
}
