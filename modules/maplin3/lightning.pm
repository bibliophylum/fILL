package maplin3::lightning;
use warnings;
use strict;
use base 'maplin3base';
use ZOOM;
use MARC::Record;
use Data::Dumper;
#use Fcntl qw(LOCK_EX LOCK_NB);

#--------------------------------------------------------------------------------
# Define our runmodes
#
sub setup {
    my $self = shift;
    $self->start_mode('lightning_search_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'lightning_search_form'    => 'lightning_search_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub lightning_search_process {
    my $self = shift;
    my $q = $self->query;

    my $template = $self->load_tmpl('search/lightning.tmpl');	
#    $template->param( pagetitle => "Maplin-4 Lightning Search",
#		      username => $self->authen->username,
#		      sessionid => $self->session->id(),
#	);
    return $template->output;
}




1; # so the 'require' or 'use' succeeds
