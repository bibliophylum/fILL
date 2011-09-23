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
	'lightning_request_form'   => 'lightning_request_process',
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


#--------------------------------------------------------------------------------
#
#
sub lightning_request_process {
    my $self = shift;
    my $q = $self->query;

    my $zname = $q->param('ztarget');
    $zname =~ s/^(.+) \(.+$/$1/;
    my $hr_zserver = $self->dbh->selectrow_hashref("SELECT id, email_address FROM zservers WHERE name=?", {}, $zname);
    
    my $hr_user = $self->dbh->selectrow_hashref("SELECT lid, email_address, library, mailing_address_line1, mailing_address_line2, mailing_address_line3 from libraries WHERE name=?", {}, $self->authen->username);
    
    my $from = "From: plslib1\@mts.net\n";
    my $to = "To: " . $hr_zserver->{'email_address'} . "\n";
    my $reply_to = "Reply-to: " . $hr_user->{'email_address'} . "\n";
    my $cc = "Cc: " . $hr_user->{'email_address'} . "\n";

    my $subject = "Subject: ILL Request: " . $q->param('title') . "\n";

    my $content = "This is an automatically generated request from MAPLIN-3\n\n";
    $content .= $hr_user->{'library'} . " would like to request the following item\nfrom ";
    $content .= $zname . ":\n-------------------------------------\n";
    $content .= "Title : " . $q->param('title') . "\n";
    $content .= "Author: " . $q->param('author') . "\n";
    $content .= "Call #: " . $q->param('callno') . "\n";
    $content .= "Medium: " . $q->param('medium') . ", ";
    $content .= "PubDate " . $q->param('date') . ", ";
    $content .= "ISBN " . $q->param('isbn') . "\n";

    $content .= "\n-------------------------------------\n";
    $content .= "Requesting library: " . $self->authen->username . "\n\n";
    $content .= $hr_user->{'library'} . "\n";
    $content .= $hr_user->{'mailing_address_line1'} . "\n" if (defined $hr_user->{'mailing_address_line1'});
    $content .= $hr_user->{'mailing_address_line2'} . "\n" if (defined $hr_user->{'mailing_address_line2'});
    $content .= $hr_user->{'mailing_address_line3'} . "\n" if (defined $hr_user->{'mailing_address_line3'});

    my $sent = $q->param('sent') || 0;
    my $error_sendmail = 0;
    my $sendmail = "/usr/sbin/sendmail -t";
    if ($q->param('send_email')) {
	eval {
	    open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
	    #    print SENDMAIL $from;
	    print SENDMAIL $reply_to;
	    print SENDMAIL $to;
	    print SENDMAIL $cc;
	    print SENDMAIL $subject;
	    print SENDMAIL "Content-type: text/plain\n\n";
	    print SENDMAIL $content;
	    close(SENDMAIL);
	};
	if ($@) {
	    # sendmail blew up
	    $self->log->debug("sendmail blew up");
	    $error_sendmail = 1;
	    $content =~ s/This is an automatically generated request from Maplin-4/Maplin had a problem sending email.\nThis is a MANUAL request./;
	    $content = "--- copy from here ---\n" . $content . "\n--- copy to here ---\n";
	} else {
	    #$self->log->debug("sendmail sent request");
	    #$self->_update_ILL_stats($lid, $zid, $loc, $callno, $pubdate);
	    $sent = 1;
	}
    }

    my $template = $self->load_tmpl('search/lightning_request.tmpl');	
    $template->param( pagetitle => "Maplin-4 Lightning Request",
		      username => $self->authen->username,
		      from => $from,
		      to => $to,
		      cc => $cc,
		      reply_to => $reply_to,
		      subject => $subject,
		      content => $content,
		      error_sendmail => $error_sendmail,
		      sent => $sent,
		      ztarget => $q->param('ztarget'),
		      title => $q->param('title'),
		      author => $q->param('author'),
		      callno => $q->param('callno'),
		      medium => $q->param('medium'),
		      date => $q->param('date'),
		      isbn => $q->param('isbn'),
	);
    return $template->output;
}



1; # so the 'require' or 'use' succeeds
