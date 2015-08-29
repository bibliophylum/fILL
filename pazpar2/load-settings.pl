#!/usr/bin/perl

use warnings;
use strict;
use DBI;
use Data::Dumper;

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
                       "mapapp",
                       "maplin3db",
                       {AutoCommit => 1, 
                        RaiseError => 1, 
                        PrintError => 0,
                       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $sth_getid = $dbh->prepare("select lid from libraries where name=?");
my $sth_insert = $dbh->prepare("insert into library_z3950 (lid,server_address,server_port,database_name,request_syntax,elements,nativesyntax,xslt,index_keyword,index_author,index_title,index_subject,index_isbn,index_issn,index_date,index_series) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");

my $settingsDir = "./settings-available";
opendir(my $dh, $settingsDir) || die "can't opendir $settingsDir: $!";
my @xml = grep { /\.xml$/ && -f "$settingsDir/$_" } readdir($dh);
closedir $dh;

foreach my $settingsFile (@xml) {
    my %data;
    open(FH, "<", "$settingsDir/$settingsFile") or die "cannot open < $settingsFile: $!";
    while (<FH>) {
	/^\<settings/ 
                           and ($data{server_address},$data{server_port},$data{database_name}) = $_ =~ /^\<settings target=\"(.*):(\d+)\/(.*)\"\>/;

	/name=\"symbol\"/  and ($data{symbol}) = $_ =~ /value=\"(.*)\"/;
	/pz:name/          and ($data{library}) = $_ =~ /value=\"(.*)\"/;
	/pz:cclmap:term/   and ($data{index_keyword}) = $_ =~ /value=\"(.*)\"/;
	/pz:cclmap:au/     and ($data{index_author}) = $_ =~ /value=\"(.*)\"/;
	/pz:cclmap:ti/     and ($data{index_title}) = $_ =~ /value=\"(.*)\"/;
	/pz:cclmap:su/     and ($data{index_subject}) = $_ =~ /value=\"(.*)\"/;
	/pz:cclmap:isbn/   and ($data{index_isbn}) = $_ =~ /value=\"(.*)\"/;
	/pz:cclmap:issn/   and ($data{index_issn}) = $_ =~ /value=\"(.*)\"/;
	/pz:cclmap:date/   and ($data{index_date}) = $_ =~ /value=\"(.*)\"/;
	/pz:cclmap:series/ and ($data{index_series}) = $_ =~ /value=\"(.*)\"/;

	/pz:requestsyntax/ and ($data{request_syntax}) = $_ =~ /value=\"(.*)\"/;
	/pz:elements/      and ($data{elements}) = $_ =~ /value=\"(.*)\"/;
	/pz:nativesyntax/  and ($data{nativesyntax}) = $_ =~ /value=\"(.*)\"/;
	/pz:xslt/          and ($data{xslt}) = $_ =~ /value=\"(.*)\"/;
    }
    close FH;

    if ($data{"symbol"}) {
	print $data{"library"};

	my $lid;
	my $rv = $sth_getid->execute($data{"symbol"});
	my $aref = $sth_getid->fetchrow_arrayref();
	if (defined $aref) {
	    $lid = $aref->[0];
	}
	unless ($lid) {
	    print ": No db entry for library symbol " . $data{"symbol"} . "\n";
	    print Dumper(\%data) . "\n";
	    next;
	}

	$rv = $sth_insert->execute( $lid,
				    $data{server_address},
				    $data{server_port},
				    $data{database_name},
				    $data{request_syntax},
				    $data{elements},
				    $data{nativesyntax},
				    $data{xslt},
				    $data{index_keyword},
				    $data{index_author},
				    $data{index_title},
				    $data{index_subject},
				    $data{index_isbn},
				    $data{index_issn},
				    $data{index_date},
				    $data{index_series}
	    );
	print " inserted: $rv\n";
    } else {
	print "Could not process file $settingsFile\n";
    }
}

$sth_getid->finish;
$sth_insert->finish;
$dbh->disconnect;
