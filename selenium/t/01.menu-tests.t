#!/usr/bin/perl
use warnings;
use strict;
use Selenium::Remote::Driver;
use Selenium::Waiter;
use Selenium::Firefox;  # use FirefoxDriver without needing Selenium server running
use Test::More tests => 12;

my $localURL = "https://rigel.gotdns.org/cgi-bin/lightning.cgi";

my $d = Selenium::Firefox->new;
$d->get( $localURL );

ok( setup() == 1, "Set up environment" );

ok( t_menu_borrow() == 1, "Borrowing menu" );
subtest 'Borrowing submenus' => sub {
    plan tests => 9;
    # because 'search' is the default submenu, we start with the next one
    # and finish by going back to 'search'
    ok( t_borrow_newPatronRequests() == 1, "'new patron requests' page load" );
    ok( t_borrow_pending() == 1, "'pending' page load" );
    ok( t_borrow_unfilled() == 1, "'unfilled' page load" );
    ok( t_borrow_holdsPlaced() == 1, "'holds placed' page load" );
    ok( t_borrow_receiving() == 1, "'receiving' page load" );
    ok( t_borrow_renewals() == 1, "'renewals' page load" );
    ok( t_borrow_returns() == 1, "'returns' page load" );
    ok( t_borrow_overdue() == 1, "'overdue' page load" );
    ok( t_borrow_search() == 1, "'search' page load" );
};
ok( t_menu_lend() == 1, "Lending menu" );
subtest 'Lending submenus' => sub {
    plan tests => 7;
    ok( t_lend_respond() == 1, "'respond' page load" );
    ok( t_lend_onHold() == 1, "'on hold' page load" );
    ok( t_lend_shipping() == 1, "'shipping' page load" );
    ok( t_lend_renewalRequests() == 1, "'renewal requests' page load" );
    ok( t_lend_lost() == 1, "'lost' page load" );
    ok( t_lend_checkins() == 1, "'checkins' page load" );
    ok( t_lend_pullList() == 1, "'pull list' page load" );
};
ok( t_menu_current() == 1, "Current menu" );
ok( t_menu_history() == 1, "History menu" );
ok( t_menu_myaccount() == 1, "Account menu" );
subtest 'Lending submenus' => sub {
    plan tests => 5;
    ok( t_myaccount_libraryBarcodes() == 1, "'library barcodes' page load" );
    ok( t_myaccount_patronList() == 1, "'patron list' page load" );
    ok( t_myaccount_wishList() == 1, "'wish list' page load" );
    ok( t_myaccount_testMyZServer() == 1, "'test my zserver' page load" );
    ok( t_myaccount_settings() == 1, "'settings' page load" );
};
ok( t_menu_reports() == 1, "Reports menu" );
subtest 'Reports submenus' => sub {
    plan tests => 3;
    ok( t_info_reports() == 1, "'reports' page load" );
    ok( t_info_averageTimes() == 1, "'average times' page load" );
    ok( t_info_contacts() == 1, "'contacts' page load" );
};

ok( teardown() == 1, "Tear down" );
$d->quit();

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
sub t_menu_borrow {
    my $lnk = $d->find_element('menu_borrow','id');
    $lnk->click();
    return $d->get_title eq 'fILL Lightning Search';
}

#-------------------------------------------------------------------------------
sub t_borrow_newPatronRequests {
    # does the <li> exist with the proper id?
    my $li = $d->find_element('menu_borrow_new_patron_requests','id');
    return 0 unless ($li);
    # does the link exist with the proper text, and does clicking it 
    # take us to the right page?
    my $lnk = $d->find_element('New patron requests','link_text');
    $lnk->click();
    return $d->get_title eq 'New requests from your patrons';
}

#-------------------------------------------------------------------------------
sub t_borrow_pending {
    my $li = $d->find_element('menu_borrow_pending','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Pending','link_text');
    $lnk->click();
    return $d->get_title eq 'ILL requests with no response yet';
}

#-------------------------------------------------------------------------------
sub t_borrow_unfilled {
    my $li = $d->find_element('menu_borrow_unfilled','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Unfilled','link_text');
    $lnk->click();
    return $d->get_title eq 'Unfilled ILL requests';
}

#-------------------------------------------------------------------------------
sub t_borrow_holdsPlaced {
    my $li = $d->find_element('menu_borrow_holds','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Holds placed','link_text');
    $lnk->click();
    return $d->get_title eq 'Lenders have placed holds';
}

#-------------------------------------------------------------------------------
sub t_borrow_receiving {
    my $li = $d->find_element('menu_borrow_receive','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Receiving','link_text');
    $lnk->click();
    return $d->get_title eq 'Receive items to fill your requests';
}

#-------------------------------------------------------------------------------
sub t_borrow_renewals {
    my $li = $d->find_element('menu_borrow_renewals','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Renewals','link_text');
    $lnk->click();
    return $d->get_title eq 'Ask for renewals on borrowed items';
}

#-------------------------------------------------------------------------------
sub t_borrow_returns {
    my $li = $d->find_element('menu_borrow_returns','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Returns','link_text');
    $lnk->click();
    return $d->get_title eq 'Return items to lending libraries';
}

#-------------------------------------------------------------------------------
sub t_borrow_overdue {
    my $li = $d->find_element('menu_borrow_overdue','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Overdue','link_text');
    $lnk->click();
    return $d->get_title eq 'Overdue items to be returned to lender';
}

#-------------------------------------------------------------------------------
sub t_borrow_search {
    my $li = $d->find_element('menu_borrow_lightning','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Search','link_text');
    $lnk->click();
    return $d->get_title eq 'fILL Lightning Search';
}


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
sub t_menu_lend {
    my $lnk = $d->find_element('menu_lend','id');
    $lnk->click();
    return $d->get_title eq 'Pull-list';
}

#-------------------------------------------------------------------------------
sub t_lend_respond {
    my $li = $d->find_element('menu_lend_respond','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Respond','link_text');
    $lnk->click();
    return $d->get_title eq 'Respond to ILL requests';
}

#-------------------------------------------------------------------------------
sub t_lend_onHold {
    my $li = $d->find_element('menu_lend_holds','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('On hold','link_text');
    $lnk->click();
    return $d->get_title eq 'On hold';
}

#-------------------------------------------------------------------------------
sub t_lend_shipping {
    my $li = $d->find_element('menu_lend_shipping','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Shipping','link_text');
    $lnk->click();
    return $d->get_title eq 'Shipping';
}

#-------------------------------------------------------------------------------
sub t_lend_renewalRequests {
    my $li = $d->find_element('menu_lend_renewal_requests','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Renewal requests','link_text');
    $lnk->click();
    return $d->get_title eq 'Respond to renewal requests';
}

#-------------------------------------------------------------------------------
sub t_lend_lost {
    my $li = $d->find_element('menu_lend_lost','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Lost','link_text');
    $lnk->click();
    return $d->get_title eq 'Lost items reported by borrowers';
}

#-------------------------------------------------------------------------------
sub t_lend_checkins {
    my $li = $d->find_element('menu_lend_checkins','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Check-ins','link_text');
    $lnk->click();
    return $d->get_title eq 'Loan items to be checked back into your ILS';
}

#-------------------------------------------------------------------------------
sub t_lend_pullList {
    my $li = $d->find_element('menu_lend_pull','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Pull list','link_text');
    $lnk->click();
    return $d->get_title eq 'Pull-list';
}


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
sub t_menu_current {
    my $lnk = $d->find_element('menu_current','id');
    $lnk->click();
    return $d->get_title eq 'Current ILLs';
}


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
sub t_menu_history {
    my $lnk = $d->find_element('menu_history','id');
    $lnk->click();
    return $d->get_title eq 'ILL history';
}


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
sub t_menu_myaccount {
    my $lnk = $d->find_element('menu_myaccount','id');
    $lnk->click();
    return $d->get_title eq 'fILL MyAccount Settings';
}

#-------------------------------------------------------------------------------
sub t_myaccount_libraryBarcodes {
    my $li = $d->find_element('menu_myaccount_library_barcodes','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Library barcodes','link_text');
    $lnk->click();
    return $d->get_title eq 'mwpl barcodes from ILS';
}

#-------------------------------------------------------------------------------
sub t_myaccount_patronList {
    my $li = $d->find_element('menu_myaccount_patrons','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Patron list','link_text');
    $lnk->click();
    return $d->get_title eq 'Patrons using public fILL';
}

#-------------------------------------------------------------------------------
sub t_myaccount_wishList {
    my $li = $d->find_element('menu_myaccount_acquisitions','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Wish list','link_text');
    $lnk->click();
    return $d->get_title eq 'fILL acquisitions list';
}

#-------------------------------------------------------------------------------
sub t_myaccount_testMyZServer {
    my $li = $d->find_element('menu_myaccount_test_zserver','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Test my zServer','link_text');
    $lnk->click();

    my $elem = wait_until { $d->find_element('title','tag_name') };
    return $d->get_title eq 'fILL MyAccount test zServer';
}

#-------------------------------------------------------------------------------
sub t_myaccount_settings {
    my $li = $d->find_element('menu_myaccount_settings','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Settings','link_text');
    $lnk->click();
    return $d->get_title eq 'fILL MyAccount Settings';
}


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
sub t_menu_reports {
    my $lnk = $d->find_element('menu_info','id');
    $lnk->click();
    my $elem = wait_until { $d->find_element('title','tag_name') };
    return $d->get_title eq 'fILL Info Contacts';
}

#-------------------------------------------------------------------------------
sub t_info_reports {
    my $li = $d->find_element('menu_info_reports','id');
    return 0 unless ($li);
    # There are two "Reports" links - main menu and submenu.
    #my $lnk = $d->find_element('Reports','link_text');
    my $lnk = $d->find_element("#menu_info_reports > a","css");
    $lnk->click();
    my $elem = wait_until { $d->find_element('title','tag_name') };
    return $d->get_title eq 'fILL Info Stats Report';
}

#-------------------------------------------------------------------------------
sub t_info_averageTimes {
    my $li = $d->find_element('menu_info_average_times','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Average times','link_text');
    $lnk->click();
    my $elem = wait_until { $d->find_element('title','tag_name') };
    return $d->get_title eq 'Average Handling Times';
}

#-------------------------------------------------------------------------------
sub t_info_contacts {
    my $li = $d->find_element('menu_info_contacts','id');
    return 0 unless ($li);
    my $lnk = $d->find_element('Contacts','link_text');
    $lnk->click();
    my $elem = wait_until { $d->find_element('title','tag_name') };
    return $d->get_title eq 'fILL Info Contacts';
}


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
sub setup {
    my $rv = login("mwpl","mwpl");
    return $rv;
}

#-------------------------------------------------------------------------------
sub teardown {
    my $rv = logout();
    return $rv;
}

#-------------------------------------------------------------------------------
sub login {
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
sub logout {
    my $lnkLogout = $d->find_element('Log Out','link_text');
    $lnkLogout->click();

    if ( $d->get_title ne 'fILL Logged Out' ) {
	return 0;
    }
    return 1;
}


