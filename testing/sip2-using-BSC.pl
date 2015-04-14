#!/usr/bin/perl
use Biblio::SIP2::Client;
use Data::Dumper;

my %WMRL = (
    host => "206.187.24.42",
    port => 6102,
    );

my $bsc = Biblio::SIP2::Client->new( %WMRL );
$bsc->connect();
my $authorized_href = $bsc->verifyPatron("20967000590071","3296");
$bsc->disconnect();

print Dumper($authorized_href) . "\n";
