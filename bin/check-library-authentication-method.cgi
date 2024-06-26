#!/usr/bin/perl
use warnings;
use strict;
use JSON;
use CGI;
#use CGI::Session;
use DBI;

my $query = new CGI;
# This cgi is used on login... there is no session established until after authentication
#my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
#if (($session->is_expired) || ($session->is_empty)) {
#    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
#    exit;
#}

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
                       "mapapp",
                       "maplin3db",
                       {AutoCommit => 1, 
                        RaiseError => 1, 
                        PrintError => 0,
                       }
    ) or die $DBI::errstr;

my $lib_href = $dbh->selectrow_hashref(
#    "select oid, patron_authentication_method from org where city=?", 
    "select oid, patron_authentication_method from org where org_name=?", 
    { Slice => {} }, 
#    $query->param('city')
    scalar $query->param('org_name')
    );

if ($lib_href) {
    if ($lib_href->{patron_authentication_method} eq 'sip2') {
	my $href = $dbh->selectrow_hashref(
	    "select enabled, login_text, barcode_label_text, pin_label_text from library_sip2 where oid=?", 
	    { Slice => {} }, 
	    $lib_href->{oid}
	    );
	$lib_href->{enabled} = $href->{enabled};
	$lib_href->{login_text} = $href->{login_text};
	$lib_href->{barcode_label_text} = $href->{barcode_label_text};
	$lib_href->{pin_label_text} = $href->{pin_label_text};

    } elsif (($lib_href->{patron_authentication_method} eq 'L4U') 
	     || ($lib_href->{patron_authentication_method} eq 'FollettDestiny')
	     || ($lib_href->{patron_authentication_method} eq 'TLC')
	     || ($lib_href->{patron_authentication_method} eq 'Biblionet') 
	     || ($lib_href->{patron_authentication_method} eq 'TempNorthNorfolk') 
	     || ($lib_href->{patron_authentication_method} eq 'Dummy')) {
	my $href = $dbh->selectrow_hashref(
	    "select enabled, login_text, barcode_label_text, pin_label_text from library_nonsip2 where oid=?", 
	    { Slice => {} }, 
	    $lib_href->{oid}
	    );
	$lib_href->{enabled} = $href->{enabled};
	$lib_href->{login_text} = $href->{login_text};
	$lib_href->{barcode_label_text} = $href->{barcode_label_text};
	$lib_href->{pin_label_text} = $href->{pin_label_text};
    }
}
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { ea => $lib_href } );
