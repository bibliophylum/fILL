#!/usr/bin/perl

use ZOOM;

# Set up connections
my @z;       # connections
my @r;       # results
my @servers; # servers list
@servers = ('library.gov.mb.ca:210/maplin',
	    '207.161.70.103:5556/LSPacZ',
	    '24.76.2.248:210/Main',
	    '216.130.92.141:210/Melita_ILS',
    );
for (my $i = 0; $i < @servers; $i++) {
    $z[$i] = new ZOOM::Connection($servers[$i], 0,
				  async => 1, # asynchronous mode
				  count => 1, # piggyback retrieval count
				  preferredRecordSyntax => "usmarc");
    $r[$i] = $z[$i]->search_pqf("\@attr 1=4 mineral");
}

while (($i = ZOOM::event(\@z)) != 0) {
    $ev = $z[$i - 1]->last_event();
    print("connection ", $i-1, ": ", ZOOM::event_str($ev), "\n");
    if ($ev == ZOOM::Event::ZEND) {
	$size = $r[$i-1]->size();
	print "connection ", $i-1, ": $size hits\n";
	print $r[$i-1]->record(0)->render() if $size > 0;
    }
}

