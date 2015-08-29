#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use CGI::Session;
use DBI;
use JSON;
#use Getopt::Long;
#use XML::LibXML;
#use REST::Client;
#use MIME::Base64;
use Data::Dumper;

use constant {
    LIBRARY => 0,
    STREET => 1,
    CITY => 2,
    PROVINCE => 3,
    POST_CODE => 4,
};

my $query = new CGI;
my $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
if (($session->is_expired) || ($session->is_empty)) {
    print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
    exit;
}
my $reqid = $query->param('reqid');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
                       "mapapp",
                       "maplin3db",
                       {AutoCommit => 1, 
                        RaiseError => 1, 
                        PrintError => 0,
                       }
    ) or die $DBI::errstr;

my $SQL = "select msg_from, msg_to from requests_active where request_id=? and status like '%Will-Supply%'";
my $aref = $dbh->selectrow_arrayref($SQL, undef, $reqid ) or die "could not get library ids for request # $reqid, $@";
my $from = $aref->[0];
my $to = $aref->[1];

$SQL = "select library, mailing_address_line1, city, province, post_code from libraries where oid=?";
my $from_aref = $dbh->selectrow_arrayref($SQL, { Slice => {} }, $from );
my $to_aref   = $dbh->selectrow_arrayref($SQL, { Slice => {} }, $to );
$dbh->disconnect;

#my %api = ();
#$api{username} = '1111111111111111';       # developer API keys
#$api{password} = '1111111111111111111111'; # use production keys when going live

my %shipment = ();
$shipment{group_id} = 'Interlibrary Loan';
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$shipment{expected_mailing_date} = sprintf("%4d-%02d-%02d", $year+1900, $mon+1, $mday);
$shipment{service_code} = 'DOM.LIB';

$shipment{sender} = {
    name => 'ILL department',
    company => $from_aref->[LIBRARY],
    contact_phone => '204-726-6870',
    address_line1 => $from_aref->[STREET],
    city => $from_aref->[CITY],
    province => $from_aref->[PROVINCE],
    postal_code => $from_aref->[POST_CODE],
    email_address => 'someone@somewhere.com',
};

$shipment{destination} = {
    name => 'ILL department',
    company => $to_aref->[LIBRARY],
    contact_phone => '204-822-4092',
    address_line1 => $to_aref->[STREET],
    city => $to_aref->[CITY],
    province => $to_aref->[PROVINCE],
    postal_code => $to_aref->[POST_CODE],
    email_address => 'someone.else@somewhere.else.com',
};

$shipment{requested_shipping_point} = $shipment{sender}->{postal_code};
$shipment{parcel_weight} = '1.2';  # in kg
$shipment{customer_ref1} = 'fILL reqeust id:' . $reqid;
$shipment{notification_email} = $shipment{destination}->{email_address};

#my %credentials = ();
#$credentials{customer_number} = '0000000000';  # this will come from DB (lender)
#$credentials{mobo} = $credentials{customer_number}; # "mailed on behalf of" - this will come from DB (borrower)
#$credentials{contract_id} = '0000000000';

print "Content-Type:application/json\n\n" . to_json( { shipment => \%shipment });
