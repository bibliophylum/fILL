package Biblio::Authentication::L4U;

use 5.006;
use strict;
use warnings FATAL => 'all';
use WWW::Mechanize;
use HTML::TreeBuilder 5 -weak;

=head1 NAME

Biblio::Authentication::L4U - check if patron credentials authorize against L4U library PAC

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Check if patron credentials authorize against L4U library PAC.

    use Biblio::Authentication::L4U;

    my $L4U = Biblio::Authentication::L4U->new(
        'url' => "http://aaa.bbb.ccc.ddd/4dcgi/gen_2002/Lang=Def",
    );
    my $authorized_href = $L4U->verifyPatron( $barcode, $pin );

Biblio::Authentication::L4U looks for the 'Login' link on the library's PAC,
follows it to the login page, fills in the user credentials (as passed in
to verifyPatron), and checks to see if it ends up at a patron information
page.  If so, it logs out and returns.

=head1 SUBROUTINES/METHODS

=head2 new

my $L4U = Biblio::Authentication::L4U->new(
    'url' => "http://aaa.bbb.ccc.ddd/4dcgi/gen_2002/Lang=Def",
);

'url' is the URL to the library's public catalogue.

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    my %parms = @_;

    my $self  = {};

    # Public variables for configuration
    $self->{url}          = $parms{'url'};
    $self->{library}      = $parms{'library'} || '';

    bless ($self, $class);
    return $self;
}

=head2 verifyPatron

my $authorized_href = $L4U->verifyPatron( $barcode, $pin );

verifyPatron returns a hash reference to a hash that looks like:
		my %authorized = (
		    "validbarcode"  => 'Y',
		    "validpin"      => 'Y',
		    "patronname"    => "Test Patron",
		    "screenmessage" => undef,
		    );
The 'screenmessage' gives additional information on login failure.

=cut

sub verifyPatron {
    my $self = shift;
    my ($barcode, $pin) = @_;

    my $authref;

    my $mech = WWW::Mechanize->new( autocheck => 1 );
    
    $mech->get( $self->{url} );
    if ($mech->success()) {
	my $loginLink = $mech->find_link( class => "LoginTab" );
	if ($loginLink) {
	    $mech->follow_link( url => $loginLink->url() );
	    my $resp = $mech->submit_form(
		form_name => 'theForm',
		fields    => { web_ClientCode  => $barcode, web_ClientPIN => $pin},
		button    => 'Login'
		);
#	    print STDERR "Form submitted.  Response:\n";
#	    print STDERR "\tcode: " . $resp->status_line . "\n";
	    my $tree = HTML::TreeBuilder->new_from_content( $mech->content() );
	    my $e = $tree->look_down(_tag => 'div', id => 'ClientCard');
	    if ($e) {
		# successful login
		my $pnameHeader = $e->look_down(_tag => 'h2');
		my %authorized = (
		    "validbarcode"  => 'Y',
		    "validpin"      => 'Y',
		    "patronname"    => $pnameHeader->as_text(),
		    "screenmessage" => undef,
		    );
		$authref = \%authorized;

		# play nice and logout
		my $logoutLink = $mech->find_link( class => "LogoutTab" );
		if ($logoutLink) {
		    $mech->follow_link( url => $logoutLink->url() );
		    my $reallyLogoutLink = $mech->find_link( text => 'Yes, Logout and delete my session' );
		    if ($reallyLogoutLink) {
			$mech->follow_link( url => $reallyLogoutLink->url() );
		    }
		}

	    } else {
		my %authorized = (
		    "validbarcode"  => 'N',
		    "validpin"      => 'N',
		    "patronname"    => undef,
		    "screenmessage" => "Invalid card or PIN",
		    );
		$authref = \%authorized;
	    }
	    $tree->delete();
	} else {
	    my %authorized = (
		"validbarcode"  => 'N',
		"validpin"      => 'N',
		"patronname"    => undef,
		"screenmessage" => "Unable to access library login page",
		);
	    $authref = \%authorized;
	}
    } else {
	my %authorized = (
	    "validbarcode"  => 'N',
	    "validpin"      => 'N',
	    "patronname"    => undef,
	    "screenmessage" => "Unable to access library web site",
	    );
	$authref = \%authorized;
    }
    
#    print STDERR Dumper(%authorized);
    return $authref;
}

=head1 AUTHOR

David Christensen, C<< <David.A.Christensen at gmail.com> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2015 David Christensen.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Biblio::Authentication::L4U
