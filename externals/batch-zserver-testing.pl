#!/usr/bin/perl
#
# install package libio-captureoutput-perl
#
use strict;
use warnings;
use DBI;
use IO::CaptureOutput qw(capture_exec);
use Getopt::Long;
use Data::Dumper;

my $help;
GetOptions ("help" => \$help);

if ($help) {
    print "usage: $0\n";
    exit;
}

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 0, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    );

my $libraries = $dbh->selectall_arrayref(
    "select library, name from libraries order by library", undef,
    );
$dbh->disconnect;

open(OUTF,'>',"bst.txt") or die "cannot open > bst.txt: $!";
open(ERRF,'>',"bst.err") or die "cannot open > bst.err: $!";

foreach my $library (@$libraries) {
    print $library->[0] . "\t" . $library->[1] . "\n";    
    my @args = ("/opt/fILL/bin/check-zserver-connectivity.cgi", "libsym=$library->[1]", "log=0");
    my ($stdout, $stderr, $success, $exit_code) = capture_exec(@args);
    if ($success) {
	$stdout =~ s|Content-Type:application/json\n\n||;
	print OUTF $stdout . "\n";
	print ERRF $stderr . "\n";
    }
}
    
close ERRF;
close OUTF;




