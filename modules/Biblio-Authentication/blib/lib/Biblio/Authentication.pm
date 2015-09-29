package Biblio::Authentication;

use 5.006;
use strict;
use warnings FATAL => 'all';
use WWW::Mechanize;
use HTML::TreeBuilder 5 -weak;

=head1 NAME

Biblio::Authentication - base class for integrated library system authentication

=head1 VERSION

Version 0.03

=cut

our $VERSION = '0.03';


=head1 SYNOPSIS

Don't use this class itself; use (or create) a class specific to the ILS you're authenticating against.

Derived classes use whatever is appropriate to handle the authentication (e.g. SIP2, RESTful API, screen-scrape using WWW::Mechanize, etc)

For example:

Check if patron credentials authorize against L4U library PAC.

    use Biblio::Authentication::L4U;

    my $authenticator = Biblio::Authentication::L4U->new(
        'url' => "http://aaa.bbb.ccc.ddd/4dcgi/gen_2002/Lang=Def",
    );
    my $authorized_href = $authenticator->verifyPatron( $barcode, $pin );

There is a dummy authenticator available, Biblio::Authentication::Dummy, which can be used for testing your code that requires authetication.
    my $authenticator = Biblio::Authentication::Dummy();
    my $authorized_href = $authenticator->verifyPatron( $barcode, $pin );
The dummy authenticator always returns a positive (i.e. patron is authenticated) result.

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

    # Private
    $self->{authorized} = {
	"validbarcode"  => 'N',
	"validpin"      => 'N',
	"patronname"    => undef,
	"screenmessage" => undef,
    };
    $self->{userAgent} = 'fILL-authentication'; # used by www::mechanize authenticators

    bless ($self, $class);
    return $self;
}

=head2 verifyPatron

Each derived class must implement the verifyPatron method.

my $authorized_href = $authenticator->verifyPatron( $barcode, $pin );

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

    return $self->{authorized};
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

1; # End of Biblio::Authentication
