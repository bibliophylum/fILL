#!/usr/bin/perl
use warnings;
use strict;
use Cwd;
use 5.012; # so readdir assigns to $_ in a lone while test
use utf8;
use MARC::Batch;
use MARC::File;
use MARC::File::USMARC;
use MARC::Record;
use Getopt::Long;
use Text::CSV::Slurp;
use DBI;
use DBD::Pg qw(:pg_types);
use JSON;
use File::Copy qw(move);
use Data::Dumper;

my $uploads_dir = '/opt/fILL/brm_uploads';
my $archive_dir = '/opt/fILL/brm_loaded';
chdir $uploads_dir || die "can't chdir to uploads directory $uploads_dir: $!";

my %files;
opendir(my $dh, $uploads_dir) || die "can't opendir $uploads_dir: $!";
while(readdir $dh) {
    next unless -f "$uploads_dir/$_";
    next unless /^\d{4,6}/; # uploaded files will be named like "12788.mrc" and "12788.items"
    my $basename = $_;
    $basename =~ s/^(\d{4,6}).*$/$1/;
    next if (exists $files{ $basename }); 

    $files{ $basename }{"basename"} = $basename;
    if (-e "$uploads_dir/$basename.mrc") {
	$files{ $basename }{"marcfile"} = "$basename.mrc";
	if (-e "$uploads_dir/$basename.items") {
	    $files{ $basename }{"itemfile"} = "$basename.items";
	    $files{ $basename }{"itemlog"} = "$basename.items.log";
	} else {
	    $files{ $basename }{"itemfile"} = undef;
	}
    } else {
	$files{ $basename }{"marcfile"} = undef;
    }
}
closedir $dh;

foreach my $bn (keys %files) {
    if ((defined $files{$bn}{"marcfile"}) && (defined $files{$bn}{"itemfile"})) {
	add_copies_to_marc( \%{ $files{$bn} } );
	load_records_to_rotation_manager( \%{ $files{$bn} } );
	move( $files{ $bn }{"marcfile"}, "$archive_dir/" . $files{ $bn }{"marcfile"} );
	move( $files{ $bn }{"itemfile"}, "$archive_dir/" . $files{ $bn }{"itemfile"} );
	move( $files{ $bn }{"itemlog"}, "$archive_dir/" . $files{ $bn }{"itemlog"} ); # debugging....
	move( $files{ $bn }{"clean"}, "$archive_dir/" . $files{ $bn }{"clean"} );
    }
}
print "Content-Type:application/json\n\n" . to_json( \%files );



#--------------------------------------------------------------------------------
sub add_copies_to_marc {
    my $fhash = shift;
    my $f = \%$fhash;

    # load the items (returns arrayref of hashrefs)
    my $data = Text::CSV::Slurp->load(file => $f->{"itemfile"});
    my %items;
    foreach my $href (@$data) {
	$items{ $href->{"Record ID"} } = $href;                  # DAVID: changed this back to "Record ID" from TCN as per new Evergreen 3.x copy bucket export.  2020.08.28
	$items{ $href->{"Record ID"} }->{"Barcode"} =~ s/^\s+//; # hmm... csv file's barcode field is oddly padded with leading and trailing spaces.
	$items{ $href->{"Record ID"} }->{"Barcode"} =~ s/\s+$//; #  Clean those up.
    }
    open(ITEMOUTLOG,">",$f->{"itemlog"}) or die "Can't open " . $f->{"itemlog"} . " item log for output: $!";
    print ITEMOUTLOG Dumper(%items);
    close(ITEMOUTLOG);

    # first get the count of records in the file
    $f->{"records_in_file"} = CountRecs( $f->{"marcfile"} );

    my $batch;
    $batch = MARC::Batch->new( 'USMARC', $f->{"marcfile"} );
    $batch->strict_off();
    $batch->warnings_off();

    $f->{"clean"} = sprintf("%s.clean",$f->{"basename"});
    open(MARCOUTF,">",$f->{"clean"}) or die "Can't open " . $f->{"clean"} . " clean MARC for output: $!";
    binmode(MARCOUTF, ":utf8");
    my $marc;
    
    my @atc = ();
    my $cnt = 1;
    while ($marc = $batch->next() ) {
	#print "\r            \r" . $cnt++;

	# Clean up the record.
	my @f997 = $marc->field( '997' );
	foreach my $fld (@f997) {
	    $marc->delete_field( $fld );
	}
	my @f949 = $marc->field( '949' );
	foreach my $fld (@f949) {
	    $marc->delete_field( $fld );
	}    
	my @f852 = $marc->field( '852' );
	foreach my $fld (@f852) {
	    $marc->delete_field( $fld );
	}
	
	# add holding
	my $recid = $marc->field('901')->subfield('a');
	my $f949 = MARC::Field->new('949', ' ', ' ',
				    'b' => $items{ $recid }->{"Barcode"},
				    'd' => $items{ $recid }->{"Call Number"},
				    'm' => $items{ $recid }->{"Location"},
	    );
	$marc->insert_fields_ordered( $f949 );

	print MARCOUTF $marc->as_usmarc();
	
	# Get the report info
	my %rec;
	$rec{"author"} = $marc->author() ? $marc->author() : " No author listed.";
	$rec{"callno"} = $marc->subfield("949",'d');
	$rec{"barcode"} = $marc->subfield("949",'b');
	$rec{"title"} = $marc->title();
	push @atc, \%rec;
    }

    my @sorted = sort { $a->{author} cmp $b->{author} } @atc;
    $f->{"process_report"} = \@sorted;
    close MARCOUTF;
    return;
}

#--------------------------------------------------------------------------------
# Note the need to specify bytea type. Otherwise the text won't be escaped,
# it'll be sent assuming it's text in client_encoding, so NULLs will cause the
# string to be truncated.  If it isn't valid utf-8 you'll get an error. If it
# is, it might not be stored how you want.
#
# So specify {pg_type => DBD::Pg::PG_BYTEA} .
#
sub load_records_to_rotation_manager {
    my $fhash = shift;
    my $f = \%$fhash;

    my $cnt = 0;
    my $oid = 101; # magic number.  library id for default library to load recs to.
    my $holdingsField = '949';
    my %holdingsSubfields = ( "barcode" => 'b',
			      "callno" => 'd'
	);

    my $file = MARC::File::USMARC->in( $f->{"clean"} );
    unless ($file) {
	$f->{"marcfileloaderror"} = $MARC::File::ERROR;
	#print "marc file load error: " . $f->{"marcfileloaderror"} . "\n";
	return 1;
    }

    my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
			   "mapapp",
			   "maplin3db",
			   {AutoCommit => 1, 
			    RaiseError => 1, 
			    PrintError => 1,
			   }
	);

    
    my @report;
    $f->{"records_loaded"} = 0;
    $f->{"records_processed_for_loading"} = 0;
    while ( my $marc = $file->next() ) {
	my %rec;

	#print $marc->as_formatted();
	$rec{"title"} = $marc->title();
	$rec{"author"} = $marc->author();
	$rec{"callno"} = $marc->subfield( $holdingsField, $holdingsSubfields{"callno"} );
	$rec{"barcode"} = $marc->subfield( $holdingsField, $holdingsSubfields{"barcode"} );
	$rec{"status"} = "No barcode, skipped" unless (defined $rec{"barcode"});

	if (defined $rec{"barcode"}) {
	    my $sth = $dbh->prepare("insert into rotations (barcode, title, author, callno, current_library, marc) select ?,?,?,?,?,? where not exists (select 1 from rotations where barcode=?)");
	    $sth->bind_param(1, $rec{"barcode"});
	    $sth->bind_param(2, $rec{"title"});
	    $sth->bind_param(3, $rec{"author"});
	    $sth->bind_param(4, $rec{"callno"});
	    $sth->bind_param(5, $oid);
	    my $usmarc = $marc->as_usmarc();
	    $sth->bind_param(
		6, 
		utf8::is_utf8($usmarc) ? Encode::encode_utf8($usmarc) : $usmarc, 
		{ pg_type => DBD::Pg::PG_BYTEA }
		);
	    $sth->bind_param(7, $rec{"barcode"});
	    my $rv = $sth->execute();

	    if (defined $rv) {
		if ($rv eq '0E0') { $rec{"status"} = "Duplicate barcode"; } 
		else { $rec{"status"} = "[$rv] inserted"; 	$f->{"records_loaded"} += 1; }
	    }
	}
	push @report, \%rec;
	$f->{"records_processed_for_loading"} += 1;
    }
    $dbh->disconnect;
    $f->{"load_report"} = \@report;
    $file->close();
    return 0;
}


#---------------------------------------------------------------------------
# utility functions
#---------------------------------------------------------------------------
sub CountRecs {
    my $marcfilename = shift;
    my $iCount = 0;
    my $file = MARC::File::USMARC->in( $marcfilename );
    while ( my $marc = $file->skip() ) {
	$iCount++;
    }
    return $iCount;
}
