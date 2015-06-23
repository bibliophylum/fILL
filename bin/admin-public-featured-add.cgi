#!/usr/bin/perl
use strict;
use warnings;

use CGI;
use CGI::Session;
use DBI;
use JSON;
use WWW::Mechanize;
#use Data::Dumper;

my $query = new CGI;
my $session;
if (($ENV{GATEWAY_INTERFACE}) && ($ENV{GATEWAY_INTERFACE} =~ /CGI/)) {  # only worry about session if we're a cgi
    $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
    if (($session->is_expired) || ($session->is_empty)) {
	print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
	exit;
    }
}

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

# see if we can get cover image from The Open Library
# eg: http://covers.openlibrary.org/b/isbn/0385472579-M.jpg
my $cover;
if ($query->param('isbn')) {
    my $isbn = $query->param('isbn');
    my $mech = WWW::Mechanize->new();
    my $coverOk = $mech->get( "http://covers.openlibrary.org/b/isbn/" . $isbn . "-M.jpg",
			      ":content_file" => "/opt/fILL/htdocs/img/covers/" . $isbn . ".jpg" );
    if ($coverOk) {
	$cover = "/img/covers/" . $isbn . ".jpg";
    }
}

my $SQL = "insert into featured (isbn,title,author,cover) values (?,?,?,?)";

my $retval = $dbh->do( $SQL, undef, 
		       $query->param('isbn'),
		       $query->param('title'),
		       $query->param('author'),
		       $cover
    );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { success => $retval } );
