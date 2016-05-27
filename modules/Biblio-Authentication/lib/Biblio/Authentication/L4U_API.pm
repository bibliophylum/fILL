package Biblio::Authentication::L4U_API;

use parent 'Biblio::Authentication';
use WWW::Mechanize::XML;

=head1 NAME

Biblio::Authentication::L4U_API - check if patron credentials authorize against L4U library API

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Check if patron credentials authorize against L4U library API.

    use Biblio::Authentication::L4U_API;

    my $L4U = Biblio::Authentication::L4U_API->new(
        'url' => "http://aaa.bbb.ccc.ddd/4DACTION/Overdrive_Auth",
    );
    my $authorized_href = $L4U->verifyPatron( $barcode, $pin );

Biblio::Authentication::L4U_API uses the L4U Overdrive authentication
API, which returns an XML snippet:
<?xml version="1.0" encoding="UTF-8"?>
<AuthorizeResponse>
  <Status>1</Status>
</AuthorizeResponse>

=head1 SUBROUTINES/METHODS

=head2 new

my $L4U = Biblio::Authentication::L4U_API->new(
    'url' => "http://aaa.bbb.ccc.ddd/4DACTION/Overdrive_Auth",
);

'url' is the URL to the library's public catalogue.

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    my %parms = @_;

    my $self  = $class->SUPER::new(@_);

    return $self;
}

=head2 verifyPatron

my $authorized_href = $L4U_API->verifyPatron( $barcode, $pin );

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

    my $mech = WWW::Mechanize::XML->new( autocheck => 1 );
    $mech->add_header( 'User-agent' => $self->{userAgent} );    
    
    $mech->get( $self->{url} . "?ccode=" . $barcode . "&pin=" . $pin );
    if ($mech->success()) {
	my $dom = $mech->xml();

	my $patronStatus = $dom->getElementsByTagName('Status');
	if ($patronStatus->string_value() eq "1") {
	    # successful login
	    my %authorized = (
		"validbarcode"  => 'Y',
		"validpin"      => 'Y',
		"patronname"    => $barcode,
		"screenmessage" => undef,
		);
	    $self->{'authorized'} = \%authorized;

	} else {
	    my %authorized = (
		"validbarcode"  => 'N',
		"validpin"      => 'N',
		"patronname"    => undef,
		"screenmessage" => "Invalid card or PIN",
		);
	    $self->{'authorized'} = \%authorized;
	}

    } else {
	my %authorized = (
	    "validbarcode"  => 'N',
	    "validpin"      => 'N',
	    "patronname"    => undef,
	    "screenmessage" => "Unable to access library's authentication system",
	    );
	$self->{'authorized'} = \%authorized;
    }
    
#    print STDERR Dumper($self->{'authorized'});
    return $self->{'authorized'};
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
