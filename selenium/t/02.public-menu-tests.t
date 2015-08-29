#!/usr/bin/perl
use warnings;
use strict;
use Selenium::Remote::Driver;
use Selenium::Waiter;
use Selenium::Firefox;  # use FirefoxDriver without needing Selenium server running
use Test::More tests => 8;

my $localURL = "https://rigel.gotdns.org/cgi-bin/public.cgi";

my $d = Selenium::Firefox->new;
$d->get( $localURL );

ok( setup() == 1, "Set up environment" );

ok( t_menu_myaccount() == 1, "MyAccount menu" );
ok( t_menu_current() == 1, "CurrentBorrowing menu" );
ok( t_menu_about() == 1, "About menu" );
ok( t_menu_help() == 1, "Help menu" );
ok( t_menu_faq() == 1, "FAQ menu" );
ok( t_menu_contact() == 1, "Contact menu" );

ok( teardown() == 1, "Tear down" );
$d->quit();

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
sub t_menu_myaccount {
    my $lnk = $d->find_element('menu_myaccount','id');
    $lnk->click();
    return $d->get_title eq 'fILL patron account';
}

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
sub t_menu_current {
    my $lnk = $d->find_element('menu_current','id');
    $lnk->click();
    return $d->get_title eq 'Current interlibrary loans';
}

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
sub t_menu_about {
    my $lnk = $d->find_element('menu_about','id');
    $lnk->click();
    return $d->get_title eq 'About fILL';
}

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
sub t_menu_help {
    my $lnk = $d->find_element('menu_help','id');
    $lnk->click();
    return $d->get_title eq 'Help fILL';
}

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
sub t_menu_faq {
    my $lnk = $d->find_element('menu_faq','id');
    $lnk->click();
    return $d->get_title eq 'FAQ fILL';
}

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
sub t_menu_contact {
    my $lnk = $d->find_element('menu_contact','id');
    $lnk->click();
    return $d->get_title eq 'Contact';
}


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
sub setup {
    my $rv = chooseLibrary();
    if ($rv == 1) {
	$rv = login("david","david");
    }
    return $rv;
}

#-------------------------------------------------------------------------------
sub teardown {
    my $rv = logout();
    return $rv;
}

#-------------------------------------------------------------------------------
sub chooseLibrary {

    # need to use a library which has a 'dummy' authentication method
    # (real testing of authentication will happen elsewhere)

    my $rv;
    my $elem = wait_until { $d->find_element('region_PLS Testing','id') };
    my $region = $d->find_element('region_PLS Testing','id');
    $rv = $region ? 1 : 0;
    if ($region) {
	$region->click();
	$elem = wait_until { $d->find_element('oid_101','id') };
	my $homeLib = $d->find_element('oid_101','id');
	$rv = $homeLib ? 1 : 0;
	if ($homeLib) {
	    $homeLib->click();
	}
    }
    return 1;
}

#-------------------------------------------------------------------------------
sub login {
    my ($user,$pass) = @_;

    my $fieldUser = $d->find_element('authen_barcode','id');
    $fieldUser->send_keys( $user );
    my $fieldPass = $d->find_element('authen_pin','id');
    $fieldPass->send_keys( $pass );
    my $btnSubmit = $d->find_element('authen_loginbutton','id');
    $btnSubmit->click();

    if ( $d->get_title ne 'fILL Public Search' ) {
	return 0;
    }
    return 1;
}

#-------------------------------------------------------------------------------
sub logout {
    my $lnkLogout = $d->find_element('Log Out','link_text');
    $lnkLogout->click();

    if ( $d->get_title ne 'fILL Logged Out' ) {
	return 0;
    }
    return 1;
}


