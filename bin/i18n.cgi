#!/usr/bin/perl

use utf8;
use CGI;
#use CGI::Session;   # i18n.cgi does not require any session data....
use DBI;
use JSON;

# Setup for UTF-8 mode.
binmode STDOUT, ":utf8:";
$ENV{'PERL_UNICODE'}=1;

my $query = new CGI;
#my $session;
#if (($ENV{GATEWAY_INTERFACE}) && ($ENV{GATEWAY_INTERFACE} =~ /CGI/)) {  # only worry about session if we're a cgi
#    $session = CGI::Session->load(undef, $query, {Directory=>"/tmp"});
#    if (($session->is_expired) || ($session->is_empty)) {
#        print "Content-Type:application/json\n\n" . to_json( { success => 0, message => 'invalid session' } );
#        exit;
#    }
#}

my $page = $query->param('page');
my $lang = $query->param('lang');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->{pg_enable_utf8} = -1;  # *every* string coming back from Pg has utf-8 flag set
                              # (db encoding is UTF-8)

$dbh->do("SET client_encoding = 'UTF8'");

my $retval = 0;
my $i18n = $dbh->selectall_arrayref(
    "select category,id,text from i18n where page=? and lang=?",
    { Slice => {} },
    $page, $lang
    );

my %data_perl;
if (@$i18n) { 
    foreach my $line (@$i18n) {
	$data_perl{ $line->{category} }{ $line->{id} } = $line->{text};
    }
    $retval = 1;
}

# Now get common header / footer translations
my $common = $dbh->selectall_arrayref(
    "select category,id,text from i18n where page='public' and lang=? and category='header'",
    { Slice => {} },
    $lang
    );
foreach my $line (@$common) {
    $data_perl{ "js_lang_data" }{ $line->{id} } = $line->{text};
}

$dbh->disconnect;

print "Content-Type:application/json; charset=utf-8\n\n" . to_json( { success => $retval,
								      i18n => \%data_perl
								    } );
