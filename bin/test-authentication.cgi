#!/usr/bin/perl
use warnings;
use strict;
#use Biblio::SIP2::Client;
use Biblio::Authentication::SIP2;
use Biblio::Authentication::Biblionet;
use Biblio::Authentication::FollettDestiny;
use Biblio::Authentication::L4U;
use Biblio::Authentication::TLC;
use Biblio::Authentication::Dummy;   # for testing
use JSON;
use CGI;
use CGI::Session;
use DBI;
use Data::Dumper;

my $query = new CGI;
my $session;
if (($ENV{GATEWAY_INTERFACE}) && ($ENV{GATEWAY_INTERFACE} =~ /CGI/)) {  # only worry about session if we're a cgi
    $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
    if (($session->is_expired) || ($session->is_empty)) {
	print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
	exit;
    }
}

my $oid = $query->param('oid');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
                       "mapapp",
                       "maplin3db",
                       {AutoCommit => 1, 
                        RaiseError => 1, 
                        PrintError => 0,
                       }
    ) or die $DBI::errstr;

#$dbh->do("SET TIMEZONE='America/Winnipeg'");

# is this a SIP2 library?
my $lib_href = $dbh->selectrow_hashref("select patron_authentication_method, org_name from org where oid=?", undef, $oid);

my $authorized_href;

if ($lib_href) {
    my $pat_href = $dbh->selectrow_hashref("select barcode, pin from library_test_patron where oid=?", undef, $oid);

    if ($pat_href) {
	if ($lib_href->{patron_authentication_method} eq 'sip2') {
	    $authorized_href = checkSip2(undef, undef, 
					 $pat_href->{barcode}, $pat_href->{pin}, 
					 $oid);
	} else {
	    $authorized_href = checkNonSip2(undef, undef, 
					    $pat_href->{barcode}, $pat_href->{pin}, 
					    $oid, 
					    $lib_href->{patron_authentication_method});
	}
    } else {
	# no test patron found
	my %authorized = (
	    "validbarcode"  => "N",
	    "validpin"      => "N",
	    "patronname"    => undef,
	    "screenmessage" => "#no test patron found!",  # normal screen messages start with '#'
	    );
	$authorized_href = \%authorized;
    }
    $authorized_href->{'authentication_method'} = $lib_href->{patron_authentication_method};
} else {
    # no authentication method found
    my %authorized = (
	"validbarcode"  => "N",
	"validpin"      => "N",
	"patronname"    => undef,
	"screenmessage" => "#no authetication method found!",  # normal screen messages start with '#'
	);
	$authorized_href = \%authorized;
}

my $status = $authorized_href->{'screenmessage'} ? $authorized_href->{'screenmessage'} : "Success!";

$dbh->do("update library_test_patron set last_tested=now(), test_result=? where oid=?",
    undef, $status, $oid);

my $ts = $dbh->selectrow_hashref("select last_tested from library_test_patron where oid=?", undef, $oid);
$authorized_href->{'lasttested'} = $ts->{last_tested};
$authorized_href->{'status'} = $status;

print "Content-Type:application/json\n\n" . to_json( { result => $authorized_href } );



#--------------------------------------------------------------------------------
#
#
sub checkSip2 {
    my ($username, $password, $barcode, $pin, $oid) = @_;  # username and password should be undefined if this is a sip2 authen

    my $SQL = "select host,port,terminator,sip_server_login,sip_server_password,validate_using_info from library_sip2 where oid=?";
    my $href = $dbh->selectrow_hashref($SQL,undef,$oid);

    if (defined $href) {
	# need to translate from postgresql field name to SIP2 field name
	if ($href->{terminator}) {
	    $href->{msgTerminator} = $href->{terminator};
	}
    } else {
	# no SIP2 server, so bail
	my %authorized = (
	    "validbarcode"  => "N",
	    "validpin"      => "N",
	    "patronname"    => undef,
	    "screenmessage" => "#no SIP2 server found!",  # normal screen messages start with '#'
	    );
	return undef;
    }

    $href->{debug} = 0;
    my $authenticator = Biblio::Authentication::SIP2->new( %$href );
    my $authorized_href = $authenticator->verifyPatron($barcode,$pin);

    return $authorized_href;
}

#--------------------------------------------------------------------------------
#
#
sub checkNonSip2 {
    my ($username, $password, $barcode, $pin, $oid, $authmethod) = @_;

    my $SQL = "select url from library_nonsip2 where oid=? and auth_type=?";
    my $href = $dbh->selectrow_hashref($SQL,undef,$oid,$authmethod);

    if (!defined $href) {
	my %authorized = (
	    "valid-barcode"  => "N",
	    "valid-pin"      => "N",
	    "patron-name"    => undef,
	    "screen-message" => "#unable to determine authentication method",  # normal screen messages start with '#'
	    );
	return \%authorized;
    }

    my $authenticator;
    if ($authmethod eq 'Biblionet') {
	$authenticator = Biblio::Authentication::Biblionet->new( %$href );

    } elsif ($authmethod eq 'FollettDestiny') {
	$authenticator = Biblio::Authentication::FollettDestiny->new( %$href );

    } elsif ($authmethod eq 'L4U') {
	$authenticator = Biblio::Authentication::L4U->new( %$href );

    } elsif ($authmethod eq 'TLC') {
	$authenticator = Biblio::Authentication::TLC->new( %$href );

    } elsif ($authmethod eq 'Dummy') {
	$authenticator = Biblio::Authentication::Dummy->new( %$href );
    }

    if (!defined $authenticator) {
	my %authorized = (
	    "valid-barcode"  => "N",
	    "valid-pin"      => "N",
	    "patron-name"    => undef,
	    "screen-message" => "#unknown authenticator",  # normal screen messages start with '#'
	    );
	return \%authorized;
    }

    my $authorized_href = $authenticator->verifyPatron($barcode,$pin);

    return $authorized_href;
}

$dbh->disconnect;


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
