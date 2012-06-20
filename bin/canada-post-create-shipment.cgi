#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use DBI;
use XML::LibXML;
use REST::Client;
use MIME::Base64;
use JSON;
use Data::Dumper;

use constant {
    LIBRARY => 0,
    STREET => 1,
    CITY => 2,
    PROVINCE => 3,
    POST_CODE => 4,
};

my $query = new CGI;
my $reqid = $query->param('reqid');
my $weight = $query->param('weight');
my $notifyOnShipment = $query->param('notifyShipment');
my $notifyOnException = $query->param('notifyException');
my $notifyOnDelivery = $query->param('notifyDelivery');

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

$SQL = "select library, mailing_address_line1, city, province, post_code from libraries where lid=?";
my @from_ary = $dbh->selectrow_array($SQL, undef, $from );
#print "FROM ($from):\n";
#print "\t" . $from_ary[LIBRARY] . "\n\t" . $from_ary[STREET] . "\n\t" .$from_ary[CITY] . ", " . $from_ary[PROVINCE] . "  " . $from_ary[POST_CODE] . "\n";

my @to_ary = $dbh->selectrow_array($SQL, undef, $to );
#print "\nTO ($to):\n";
#print "\t" . $to_ary[LIBRARY] . "\n\t" . $to_ary[STREET] . "\n\t" .$to_ary[CITY] . ", " . $to_ary[PROVINCE] . "  " . $to_ary[POST_CODE] . "\n";

my %api = ();
$api{username} = '8683f23ad38e2dba';       # developer API keys
$api{password} = 'ebc41a5e1a5f35bf88b4cd'; # use production keys when going live

my %shipment = ();
$shipment{group_id} = 'Interlibrary Loan';
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$shipment{expected_mailing_date} = sprintf("%4d-%02d-%02d", $year+1900, $mon+1, $mday);
$shipment{service_code} = 'DOM.LIB';

$shipment{sender_name} = 'ILL department';
$shipment{sender_company} = $from_ary[LIBRARY];
$shipment{sender_contact_phone} = '204-726-6870';
$shipment{sender_address_line1} =  $from_ary[STREET];
$shipment{sender_city} = $from_ary[CITY];
$shipment{sender_province} = $from_ary[PROVINCE];
$shipment{sender_postal_code} = $from_ary[POST_CODE];
$shipment{sender_email_address} = 'David.Christensen@gov.mb.ca';

$shipment{destination_name} = 'ILL department';
$shipment{destination_company} = $to_ary[LIBRARY];
$shipment{destination_contact_phone} = '204-822-4092';
$shipment{destination_address_line1} = $to_ary[STREET];
$shipment{destination_city} = $to_ary[CITY];
$shipment{destination_province} = $to_ary[PROVINCE];
$shipment{destination_postal_code} = $to_ary[POST_CODE];
$shipment{destination_email_address} = 'David.A.Christensen@gmail.com';

$shipment{requested_shipping_point} = $shipment{sender_postal_code};
$shipment{parcel_weight} = $weight;  # in kg
$shipment{customer_ref1} = 'fILL reqeust id:' . $reqid;
$shipment{notification_email} = $shipment{destination_email_address};

$shipment{notifyOnShipment} = $notifyOnShipment;
$shipment{notifyOnException} = $notifyOnException;
$shipment{notifyOnDelivery} = $notifyOnDelivery;

my %credentials = ();
$credentials{customer_number} = '0001682093';  # this will come from DB (lender)
$credentials{mobo} = $credentials{customer_number}; # "mailed on behalf of" - this will come from DB (borrower)
$credentials{contract_id} = '0040065629';

my $xml = <<"EOXML";
<?xml version="1.0" encoding="UTF-8"?>
<shipment xmlns="http://www.canadapost.ca/ws/shipment">
    <group-id>$shipment{group_id}</group-id>
    <requested-shipping-point>$shipment{requested_shipping_point}</requested-shipping-point>
    <expected-mailing-date>$shipment{expected_mailing_date}</expected-mailing-date>
    <delivery-spec>
        <service-code>$shipment{service_code}</service-code>
        <sender>
            <name>$shipment{sender_name}</name>
            <company>$shipment{sender_company}</company>
            <contact-phone>$shipment{sender_contact_phone}</contact-phone>
            <address-details>
                <address-line-1>$shipment{sender_address_line1}</address-line-1>
                <city>$shipment{sender_city}</city>
                <prov-state>$shipment{sender_province}</prov-state>
                <country-code>CA</country-code>
                <postal-zip-code>$shipment{sender_postal_code}</postal-zip-code>
            </address-details>
        </sender>
        <destination>
            <name>$shipment{destination_name}</name>
            <company>$shipment{destination_company}</company>
            <address-details>
                <address-line-1>$shipment{destination_address_line1}</address-line-1>
                <city>$shipment{destination_city}</city>
                <prov-state>$shipment{destination_province}</prov-state>
                <country-code>CA</country-code>
                <postal-zip-code>$shipment{destination_postal_code}</postal-zip-code>
            </address-details>
        </destination>
        <parcel-characteristics>
            <weight>$shipment{parcel_weight}</weight>
        </parcel-characteristics>
        <notification>
            <email>$shipment{notification_email}</email>
            <on-shipment>$shipment{notifyOnShipment}</on-shipment>
            <on-exception>$shipment{notifyOnException}</on-exception>
            <on-delivery>$shipment{notifyOnDelivery}</on-delivery>
        </notification>
        <references>
            <customer-ref-1>fILL request id: $reqid</customer-ref-1>
        </references>
        <preferences>
            <show-packing-instructions>false</show-packing-instructions>
        </preferences>
        <settlement-info>
           <paid-by-customer>$credentials{mobo}</paid-by-customer>
           <contract-id>$credentials{contract_id}</contract-id>
           <intended-method-of-payment>Account</intended-method-of-payment>
        </settlement-info>
    </delivery-spec>
    <return-spec>
        <service-code>$shipment{service_code}</service-code>
        <return-recipient>
            <name>$shipment{sender_name}</name>
            <company>$shipment{sender_company}</company>
            <address-details>
                <address-line-1>$shipment{sender_address_line1}</address-line-1>
                <city>$shipment{sender_city}</city>
                <prov-state>$shipment{sender_province}</prov-state>
                <postal-zip-code>$shipment{sender_postal_code}</postal-zip-code>
            </address-details>
        </return-recipient>
        <return-notification>$shipment{sender_email_address}</return-notification>
    </return-spec>
</shipment>
EOXML
    ;

# Production
#my $REST_url = "https://soa-gw.canadapost.ca/rs/$mailed_by/$mobo/shipment";
# Development
my $REST_url = "https://ct.soa-gw.canadapost.ca/rs/$credentials{customer_number}/$credentials{mobo}/shipment";

#print "$xml\n\n";

my $client = REST::Client->new();
$client->addHeader( 'Content-Type', 'application/vnd.cpc.shipment-v2+xml' );
$client->addHeader( 'Accept', 'application/vnd.cpc.shipment-v2+xml' );
$client->addHeader( 'Accept-language', 'en-CA' );
$client->addHeader( 'Authorization', "Basic " . encode_base64("$api{username}:$api{password}") );
$client->POST( $REST_url, $xml );

my $parser = XML::LibXML->new();
my $doc = $parser->parse_string($client->responseContent());

my $xc = XML::LibXML::XPathContext->new( $doc->documentElement() );
$xc->registerNs( canadapost => 'http://www.canadapost.ca/ws/shipment');

my %cp_response = ();
$cp_response{status} = $xc->findvalue('//canadapost:shipment-status');

if ($cp_response{status} eq 'created') {
    $cp_response{tracking_pin} = $xc->findvalue('//canadapost:tracking-pin');
    my ($links) = $xc->findnodes('//canadapost:links');
    foreach my $link ( $xc->findnodes('./canadapost:link',$links )) {
	my $rel = $link->findvalue('@rel');
	my $href = $link->findvalue('@href');
	my $media = $link->findvalue('@media-type');

	$cp_response{$link->findvalue('@rel')} = { href => $link->findvalue('@href'), media => $link->findvalue('@media-type') };
    }
    $dbh->do("update request set canada_post_endpoint=? where id=?", undef, $cp_response{"self"}{"href"}, $reqid);
}

$dbh->disconnect;

#print STDERR Dumper(\%cp_response);
print "Content-Type:application/json\n\n" . to_json( { cp_response => \%cp_response });
exit;

