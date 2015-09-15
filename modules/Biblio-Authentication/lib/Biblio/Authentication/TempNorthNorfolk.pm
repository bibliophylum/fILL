package Biblio::Authentication::TempNorthNorfolk;

use parent 'Biblio::Authentication';

=head1 NAME

Biblio::Authentication::Dummy - an authentication module that always says yes

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Check if patron credentials authorize against Dummy library PAC.

    use Biblio::Authentication::Dummy;

    my $Dummy = Biblio::Authentication::Dummy->new();
    my $authorized_href = $Dummy->verifyPatron( $barcode, $pin );

Biblio::Authentication::Dummy is a dummy authenticator (for testing) which
always says 'yes, this is a valid patron'.

=head1 SUBROUTINES/METHODS

=head2 new

my $Dummy = Biblio::Authentication::Dummy->new();

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    my %parms = @_;

    my $self  = $class->SUPER::new(@_);

    return $self;
}

=head2 verifyPatron

my $authorized_href = $Dummy->verifyPatron( $barcode, $pin );

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

    my %authorized = (
	"validbarcode"  => 'Y',
	"validpin"      => 'Y',
	"patronname"    => "MMNN $barcode",
	"screenmessage" => undef,
	);
    $self->{'authorized'} = \%authorized;

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

1; # End of Biblio::Authentication::Dummy
