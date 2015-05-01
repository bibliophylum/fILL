#!/usr/bin/perl
use strict;
use warnings;

use CGI;
use CGI::Session;
use DBI;
use JSON;
use File::Copy;
use Data::Dumper;

my $query = new CGI;
my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
if (($session->is_expired) || ($session->is_empty)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
    exit;
}

my $libsym = $query->param('libsym');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

my $servers_aref;
if ($libsym eq 'ALL') {
    $servers_aref = $dbh->selectall_arrayref("select l.name from library_z3950 z left join libraries l on l.lid=z.lid");
} else {
    # make sure there *is* a z39.50 server for this library...
    $servers_aref = $dbh->selectall_arrayref("select l.name from library_z3950 z left join libraries l on l.lid=z.lid where l.name=?", undef, $libsym);
}
#print STDERR Dumper($servers_aref);

my $retval = 1;
foreach my $sym (@$servers_aref) {
    #print STDERR "server: $sym->[0]\n";

    my $z = $dbh->selectrow_hashref("select l.lid,l.name,l.library,z.server_address,z.server_port,z.database_name,z.request_syntax,z.elements,z.nativesyntax,z.xslt,z.index_keyword,z.index_author,z.index_title,z.index_subject,z.index_isbn,z.index_issn,z.index_date,z.index_series,z.enabled from library_z3950 z left join libraries l on z.lid=l.lid where l.name=? order by l.library", undef, $sym->[0] );
#    print STDERR Dumper($z) . "\n";

    my $s = "";
    $s .= "<!-- " . $z->{library} . " -->\n";
    $s .= "<settings target=\"" . $z->{server_address} . ":" . $z->{server_port} . "/" . $z->{database_name} . "\">\n";
    $s .= '  <set name="pz:name" value="' . $z->{library} . "\"/>\n";
    $s .= '  <set name="symbol" value="' . $z->{name} . "\"/>\n";
    if ($z->{enabled}) {
	# default is enabled
    } else {
	$s .= '  <set name="pz:allow" value="0"/>' . "\n";
    }

    $s .= "\n";
    $s .= "  <!-- mapping for unqualified search -->\n";
    $s .= '  <set name="pz:cclmap:term" value="' . $z->{index_keyword} . "\"/>\n";
    $s .= "\n";
    $s .= "  <!-- field-specific mappings -->\n";
    $s .= '  <set name="pz:cclmap:au" value="' . $z->{index_author} . "\"/>\n";
    $s .= '  <set name="pz:cclmap:ti" value="' . $z->{index_title} . "\"/>\n";
    $s .= '  <set name="pz:cclmap:su" value="' . $z->{index_subject} . "\"/>\n";
    $s .= '  <set name="pz:cclmap:isbn" value="' . $z->{index_isbn} . "\"/>\n";
    $s .= '  <set name="pz:cclmap:issn" value="' . $z->{index_issn} . "\"/>\n";
    $s .= '  <set name="pz:cclmap:date" value="' . $z->{index_date} . "\"/>\n";
    if ($z->{index_series}) {
	$s .= '  <set name="pz:cclmap:series" value="' . $z->{index_series} . "\"/>\n";
    }
    $s .= "\n";
    $s .= "  <!-- Retrieval settings -->\n";
    $s .= "\n";
    $s .= '  <set name="pz:requestsyntax" value="' . $z->{request_syntax} . "\"/>\n";
    $s .= '  <set name="pz:elements" value="' . $z->{elements} . "\"/>\n";
    $s .= "\n";
    $s .= "  <!-- Result normalization settings -->\n";
    $s .= "\n";
    $s .= '  <set name="pz:nativesyntax" value="' . $z->{nativesyntax} . "\"/>\n";
    $s .= '  <set name="pz:xslt" value="' . $z->{xslt} . "\"/>\n";
    $s .= "\n";
    $s .= "</settings>\n";

#    print $s;

    my $basename = $z->{library};
    $basename =~ s/ /_/g;
    $basename =~ s/\.//g;
    $basename =~ s/:/-/g;
    my $filename  = "/opt/fILL/pazpar2/tmp/" . $basename . ".xml";
    my $linkname  = "/opt/fILL/pazpar2/settings/" . $basename . ".xml";
    my $availname = "/opt/fILL/pazpar2/settings-available/" . $basename . ".xml";

    open(XMLFILE, ">", $filename) or die "cannot open > $filename: $!";
    print XMLFILE $s;
    close XMLFILE;

    my $isActive;
    if (-l $linkname) { $isActive = 1; unlink $linkname; }
    if (-f $availname) { unlink $availname; }
    move($filename,$availname);
#    if ($isActive) { symlink($availname,$linkname); }
    symlink($availname,$linkname);
}


$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
