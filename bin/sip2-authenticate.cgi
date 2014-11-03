#!/usr/bin/perl
use warnings;
use strict;
use Biblio::SIP2::Client;
use JSON;
use CGI;
use DBI;
use Data::Dumper;

my $query = new CGI;

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
                       "mapapp",
                       "maplin3db",
                       {AutoCommit => 1, 
                        RaiseError => 1, 
                        PrintError => 0,
                       }
    ) or die $DBI::errstr;

#$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $SQL = "select host,port,terminator,sip_server_login,sip_server_password from library_sip2 where lid=?";
my $href = $dbh->selectrow_hashref($SQL,undef,$query->param('lid'));
$dbh->disconnect;

#print STDERR Dumper($href);

if ($href) {
    # need to translate from postgresql field name to SIP2 field name
    if ($href->{terminator}) {
	$href->{msgTerminator} = $href->{terminator};
    }
} else {
    # no SIP2 server, so bail
    bail("Library does not support SIP2 authentication");
}

my $bsc = Biblio::SIP2::Client->new( %$href );
$bsc->connect();

# if SIP2 server requires login (untested):
if ($href->{sip_server_login}) {
    my $msg = $bsc->msgLogin($href->{sip_server_login},$href->{sip_server_password});
    my $response = $bsc->get_message( $msg );
    my $parsed = $bsc->parseLoginResponse( $response );

    if ($parsed->{'fixed'}{'Ok'} == 1) {
	# good to go
    } else {
	# invalid SIP2 server credentials, so bail
	bail("Library SIP2 server login failed");
    }
}

#$bsc->setPatron("20967000590071","3296");
$bsc->setPatron($query->param('barcode'),$query->param('pin'));

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

# Note: don't return the patron name when invalid PIN
my %authorized = (
    "validbarcode"  => $parsed->{'variable'}{'BL'} || undef,
    "validpin"      => $parsed->{'variable'}{'CQ'} || undef,
    "patronname"    => $parsed->{'variable'}{'CQ'} ? ($parsed->{'variable'}{'CQ'} eq 'Y' ? $parsed->{'variable'}{'AE'} : undef) : undef,
    "screenmessage" => $parsed->{'variable'}{'AF'} || undef,
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
sub bail {
    my $msg = shift;
    my %authorized = (
	"valid-barcode"  => "N",
	"valid-pin"      => "N",
	"patron-name"    => undef,
	"screen-message" => "#" . $msg,  # normal screen messages start with '#'
	);

    print "Content-Type:application/json\n\n" . to_json( { authorized => { %authorized } } );
    exit;
}

#---------------------------------------------------------------
# for debugging...
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
