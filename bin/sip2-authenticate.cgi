#!/usr/bin/perl
use warnings;
use strict;
use Biblio::SIP2::Client;
use JSON;
use CGI;
use CGI::Session;
use DBI;
use Data::Dumper;

my $query = new CGI;
my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
if (($session->is_expired) || ($session->is_empty)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
    exit;
}

#print STDERR $query->Dump;

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

my $authorized_href;
my $bsc = Biblio::SIP2::Client->new( %$href );
$bsc->connect();
$authorized_href = $bsc->verifyPatron($query->param('barcode'),$query->param('pin'));
$bsc->disconnect();

print "Content-Type:application/json\n\n" . to_json( { authorized => { %$authorized_href } } );


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
