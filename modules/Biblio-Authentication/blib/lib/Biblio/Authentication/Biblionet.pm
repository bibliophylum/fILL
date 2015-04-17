package Biblio::Authentication::Biblionet;

use parent 'Biblio::Authentication';

=head1 NAME

Biblio::Authentication::Biblionet - check if patron credentials authorize against Biblionet library PAC

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Check if patron credentials authorize against Biblionet library PAC.

    use Biblio::Authentication::Biblionet;

    my $Biblionet = Biblio::Authentication::Biblionet->new(
        'url' => "http://aaa.bbb.ccc.ddd",
    );
    my $authorized_href = $Biblionet->verifyPatron( $barcode, $pin );

Biblio::Authentication::Biblionet looks for the 'Login' link on the library's PAC,
follows it to the login page, fills in the user credentials (as passed in
to verifyPatron), and checks to see if it ends up at a patron information
page.  If so, it logs out and returns.

=head1 SUBROUTINES/METHODS

=head2 new

my $Biblionet = Biblio::Authentication::Biblionet->new(
    'url' => "http://aaa.bbb.ccc.ddd",
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

my $authorized_href = $Biblionet->verifyPatron( $barcode, $pin );

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

    my $url = $self->{url};
    $url .= "/4DCGI/C4DI_com_post_formulaire?C4DI_login=" . $barcode . "&C4dI_mot_de_passe=" . $pin . "&C4DI_Nom_Requete=C4DI_com_demande_dossier_personnel";

    my $mech = WWW::Mechanize->new( autocheck => 1 );
    
    $mech->get( $url );
    if ($mech->success()) {
	# Logout link appears on every page?

	# get the patron's name:
	
	my $tree = HTML::TreeBuilder->new_from_content( $mech->content() );
	my @h4 = $tree->look_down(_tag => 'h4');
	foreach my $e (@h4) {
	    my $txt = $e->as_text();
	    if ($txt =~ /Dossier de/) {
		# Found it!
		my $pname = $txt;
		$pname =~ s/\s/ /g;
		$pname =~ s/\xa0/ /g;  # Biblionet includes a &nbsp; between name parts
		$pname =~ s/^Dossier de (.*)$/$1/;
		#print "txt [$txt], pname [$pname]\n";
		my %authorized = (
		    "validbarcode"  => 'Y',
		    "validpin"      => 'Y',
		    "patronname"    => $pname,
		    "screenmessage" => undef,
		    );
		$authref = \%authorized;
		last;
	    }
	}
	
	$tree->delete();
	
	if (!defined $authref) {
#	    print "no patron info\n";
	    my %authorized = (
		"validbarcode"  => 'N',
		"validpin"      => 'N',
		"patronname"    => undef,
		"screenmessage" => "Invalid user number or password",
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

1; # End of Biblio::Authentication::Biblionet
