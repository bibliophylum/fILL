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
    "select lid, patron_authentication_method from libraries where city=?", 
    { Slice => {} }, 
    $query->param('city')
    );

if ($lib_href) {
    if ($lib_href->{patron_authentication_method} eq 'sip2') {
	my $href = $dbh->selectrow_hashref(
	    "select enabled from library_sip2 where lid=?", 
	    { Slice => {} }, 
	    $lib_href->{lid}
	    );
	$lib_href->{enabled} = $href->{enabled};
    } elsif (($lib_href->{patron_authentication_method} eq 'L4U') 
	     || ($lib_href->{patron_authentication_method} eq 'FollettDestiny')
	     || ($lib_href->{patron_authentication_method} eq 'TLC')
	     || ($lib_href->{patron_authentication_method} eq 'Biblionet') 
	     || ($lib_href->{patron_authentication_method} eq 'Dummy')) {
	my $href = $dbh->selectrow_hashref(
	    "select enabled from library_nonsip2 where lid=?", 
	    { Slice => {} }, 
	    $lib_href->{lid}
	    );
	$lib_href->{enabled} = $href->{enabled};
    }
}
$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { ea => $lib_href } );
