#!/usr/bin/perl
use warnings;
use strict;
use Biblio::SIP2::Client;
#use Data::Dumper;
use JSON;

my %Insignia = ( 
    host => "216.55.201.10",
    port => 2112,
#    library => "Insignia",
    msgTerminator => "\r",
    debug => 0
    );

my %WMRL = (
    host => "206.187.24.42",
    port => 6102,
#    library => "WMRL",
    );

my $bsc = Biblio::SIP2::Client->new( %WMRL );
$bsc->connect();

# if SIP2 server requires login:
#my $msgX = $bsc->msgLogin("sipLogin","sipPassword");
#my $responseX = $bsc->get_message( $msgX );
#print STDERR "SIP2 server login response: [" . $responseX . "]\n";
#my $parsedX = $bsc->parseLoginResponse( $responseX );
##print STDERR "login response:\n" . $loginResponse . "\n";
#print_parsed_response($parsedX);

$bsc->setPatron("20967000590071","3296");

my $msg = $bsc->msgPatronStatusRequest();
my $response = $bsc->get_message( $msg );
my $parsed = $bsc->parsePatronStatusResponse( $response );
#print_parsed_response($parsed);

# BL - valid patron, Y or N
# CQ - valid password, Y or N
# AO - institution id eg: "mbw"
# AA - patron barcode
# AE - patron name eg:"Christensen, David A."
# AF - screen message eg: "#Incorrect password."

my %authorized = (
    "valid-patron"   => $parsed->{'variable'}{'BL'},
    "valid-barcode"  => $parsed->{'variable'}{'CQ'},
    "patron-name"    => $parsed->{'variable'}{'AE'},
    "screen-message" => $parsed->{'variable'}{'AF'},
    );

# just for testing:
#$msg = $bsc->msgPatronInformation( 'none' );
#$response = $bsc->get_message( $msg );
#$parsed = $bsc->parsePatronInfoResponse( $response );
#print_parsed_response($parsed);

$msg = $bsc->msgEndPatronSession();
$response = $bsc->get_message( $msg );
$parsed = $bsc->parseEndSessionResponse( $response );

$bsc->disconnect();

print "Content-Type:application/json\n\n" . to_json( { authorized => { %authorized } } );


#---------------------------------------------------------------
sub print_parsed_response {
    my $parsed = shift;

    print "Fixed:\n";
    my $href = $parsed->{'fixed'};
    foreach my $key (keys %$href) { 
	print "$key\t"; 
	if (ref( $href->{$key} ) eq "ARRAY") {
	    print "\n";
	    foreach my $elem (@{$href->{$key}}) {
		$elem =~ s/\r//;
		print "\t$elem\n";
	    }
	} else {
	    $href->{$key} =~ s/\r//;
	    print "[" . $href->{$key} . "]\n"; 
	}
    }

    print "Variable:\n";
    $href = $parsed->{'variable'};
    foreach my $key (keys %$href) { 
	print "$key\t"; 
	if (ref( $href->{$key} ) eq "ARRAY") {
	    print "\n";
	    foreach my $elem (@{$href->{$key}}) {
		$elem =~ s/\r//;
		print "\t$elem\n";
	    }
	} else {
	    $href->{$key} =~ s/\r//;
	    print "[" . $href->{$key} . "]\n"; 
	}
    }
}
