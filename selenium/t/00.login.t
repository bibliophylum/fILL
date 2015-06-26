#!/usr/bin/perl
use warnings;
use strict;
use Selenium::Remote::Driver;
use Selenium::Waiter;
use Selenium::Firefox;  # use FirefoxDriver without needing Selenium server running
use Test::More tests => 5;

my $localURL = "https://rigel.gotdns.org/cgi-bin/lightning.cgi";

my $d = Selenium::Firefox->new;
$d->get( $localURL );

#diag( $d->get_title );

ok( $d->get_title eq 'Log in to fILL', "At login page" );
ok( t_login("xxxx","yyyy") == 0, "Invalid login" );
ok( t_login("mwpl","mwpl") == 1, "Valid login" );
ok( t_logout() == 1, "Logout" );
ok( t_return_to_login() == 1, "Return to login" );

#diag( $d->get_title );

$d->quit();

#-------------------------------------------------------------------------------
sub t_login {
    my ($user,$pass) = @_;
    
    my $fieldUser = $d->find_element('authen_loginfield','id');
    $fieldUser->send_keys( $user );
    my $fieldPass = $d->find_element('authen_passwordfield','id');
    $fieldPass->send_keys( $pass );
    my $btnSubmit = $d->find_element('authen_loginbutton','id');
    $btnSubmit->click();

    if ( $d->get_title ne 'fILL Welcome' ) {
	return 0;
    }
    return 1;
}

#-------------------------------------------------------------------------------
sub t_logout {
    my $elem = wait_until { $d->find_element('Log Out','link_text') };
    my $lnkLogout = $d->find_element('Log Out','link_text');
    $lnkLogout->click();

    if ( $d->get_title ne 'fILL Logged Out' ) {
	return 0;
    }
    return 1;
}


#-------------------------------------------------------------------------------
sub t_return_to_login {
    my $form = $d->find_element('form','tag_name');
    $form->submit();

    sleep 3;  # shouldn't have to do this...

    my $elem = wait_until { $d->find_element('title','tag_name') };
    if ( $d->get_title ne 'Log in to fILL' ) {
	return 0;
    }
    return 1;
}


#-------------------------------------------------------------------------------
sub t_example {
    # wait_until will also catch dies and croaks
    my $elem = wait_until { $d->find_element_by_css('legend') };
    if ($elem) {
	print 'Text: ' . $elem->get_text . "\n";
    } else {
	print "We waited thirty seconds without finding css=legend\n";
    }
    return 1;
}
