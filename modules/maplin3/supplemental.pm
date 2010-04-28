package maplin3::supplemental;
use strict;
use base 'maplin3base';
use CGI::Application::Plugin::Stream (qw/stream_file/);
use ZOOM;


#--------------------------------------------------------------------------------
# Define our runmodes
#
sub setup {
    my $self = shift;
    $self->start_mode('worldlanguages_form');
    $self->error_mode('error');
    $self->mode_param('rm');
    $self->run_modes(
	'audiovisual_form'      => 'audiovisual_process',
	'worldlanguages_form'   => 'worldlanguages_process',
	);
}

#--------------------------------------------------------------------------------
#
#
sub worldlanguages_process {
    my $self = shift;
    my $q = $self->query;

    my $error_sendmail = 0;
    my $email_href;
    my $ask = 1;

    if ($q->param("do_request")) {
	$ask = 0;
	$email_href->{from} = "From: plslib1\@mts.net\n";
	$email_href->{to} = "To: David.Christensen\@gov.mb.ca\n";  # WPL email address goes here
	
	my $sql = "SELECT email_address, library, mailing_address_line1, mailing_address_line2, mailing_address_line3 from libraries WHERE name=?";
	my $library_href = $self->dbh->selectrow_hashref($sql, undef, $self->authen->username);

	$email_href->{reply_to} = "Reply-to: " . $library_href->{email_address} . "\n";
	$email_href->{cc} = "Cc: " . "David.Christensen\@gov.mb.ca" . "\n";   # WPL email address goes here
	$email_href->{subject} = "Subject: Block request from $library_href->{library}\n";
	
	my $content = "This is a supplementary block request generated from MAPLIN\n\n";
	$content .= $library_href->{library} . " would like to request a World Languages block:\n\n";
	$content .= "Language: " . $q->param("language") . "\n";
	$content .= "Reading level: " . $q->param("level") . "\n";
	$content .= "Type of material: " . $q->param("blocktype") . "\n";
	if ($q->param("additional_information")) {
	    $content .= "Additional information: " . $q->param("additional_information") . "\n";
	}
	$content .= "\n$library_href->{library}\n";
	$content .= "$library_href->{mailing_address_line1}\n";
	$content .= "$library_href->{mailing_address_line2}\n";
	$content .= "$library_href->{mailing_address_line3}\n";
	$email_href->{content} = $content;
	
	eval {
	    my $sendmail = "/usr/sbin/sendmail -t";
	    open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
	    # print SENDMAIL $from;
	    print SENDMAIL $email_href->{reply_to};
	    print SENDMAIL $email_href->{to};
	    print SENDMAIL $email_href->{cc};
	    print SENDMAIL $email_href->{subject};
	    print SENDMAIL "Content-type: text/plain\n\n";
	    print SENDMAIL $email_href->{content};
	    close(SENDMAIL);
	};
	if ($@) {
	    # sendmail blew up
	    $self->log->debug("sendmail blew up");
	    $error_sendmail = 1;
	    $email_href->{content} =~ s/This is a supplementary block request generated from MAPLIN/MAPLIN had a problem sending email.\nThis is a MANUAL request./;
	    $email_href->{content} = "--- copy from here ---\n" . $email_href->{content} . "\n--- copy to here ---\n";
	} else {
	    $self->log->debug("sendmail sent request");
	}
    }

    my $template = $self->load_tmpl('supplemental/multilingual_blocks.tmpl');
    $template->param(USERNAME  => $self->authen->username,
		     ASK => $ask,
		     #FROM => $email_href->{from},
		     TO => $email_href->{to},
		     CC => $email_href->{cc},
		     REPLY_TO => $email_href->{reply_to},
		     SUBJECT => $email_href->{subject},
		     CONTENT => $email_href->{content},
		     ERROR_SENDMAIL => $error_sendmail,
		     );
    return $template->output;
}


#--------------------------------------------------------------------------------
#
#
sub audiovisual_process {
    my $self = shift;
    my $q = $self->query;

    my $error_sendmail = 0;
    my $email_href;
    my $ask = 1;

    if ($q->param("do_request")) {
	$ask = 0;

	my %sources = ( "pre1960-DVD" => "MESM", # Melita
			"post1960-DVD" => "MCB", # Carman
			"bw-DVD" => "MESM",
			"nfb-DVD" => "MCB",
			"childrens-DVD" => "MTH",# Thompson
			"biography-DVD" => "MVE",# Virden
			"howto-DVD" => "MVE",
			"history-DVD" => "MVE",
			"ae-DVD" => "MVE",
			"travel-DVD" => "MVE",

			"pre1960-VHS" => "MESM", # Melita
			"post1960-VHS" => "MCB", # Carman
			"bw-VHS" => "MESM",
			"nfb-VHS" => "MCB",
			"childrens-VHS" => "MTH",# Thompson
			"biography-VHS" => "MVE",# Virden
			"howto-VHS" => "MVE",
			"history-VHS" => "MVE",
			"ae-VHS" => "MVE",
			"travel-VHS" => "MVE",

			"adultfic-CD" => "MESM",
			"adultnonfic-CD" => "MESM",
			"junior-CD" => "MWOW",   # Winkler

			"adultfic-CASS" => "MWOW",
			"adultnonfic-CASS" => "MWOW",
			"juniorfic-CASS" => "MWOW",
			"juniornonfic-CASS" => "MWOW"
	    );

	my $sql = "SELECT email_address, library FROM libraries WHERE name=?";
	my $source_href = $self->dbh->selectrow_hashref($sql, undef, $sources{ $q->param("blocktype") });

	$email_href->{from} = "From: plslib1\@mts.net\n";
	$email_href->{to} = "To: David.Christensen\@gov.mb.ca\n";  # source_href->{email_adress} goes here
	
	$sql = "SELECT email_address, library, mailing_address_line1, mailing_address_line2, mailing_address_line3 from libraries WHERE name=?";
	my $library_href = $self->dbh->selectrow_hashref($sql, undef, $self->authen->username);

	$email_href->{reply_to} = "Reply-to: " . $library_href->{email_address} . "\n";
	$email_href->{cc} = "Cc: " . "David.Christensen\@gov.mb.ca" . "\n";   # source_href->{email_address} goes here
	$email_href->{subject} = "Subject: Block request from $library_href->{library}\n";
	
	my $content = "This is a supplementary block request generated from MAPLIN\n\n";
	$content .= $library_href->{library} . " would like to request an AudioVisual block from $source_href->{library}:\n\n";
	$content .= "Block type: " . $q->param("blocktype") . "\n";
	if ($q->param("additional_information")) {
	    $content .= "Additional information: " . $q->param("additional_information") . "\n";
	}
	$content .= "\n$library_href->{library}\n";
	$content .= "$library_href->{mailing_address_line1}\n";
	$content .= "$library_href->{mailing_address_line2}\n";
	$content .= "$library_href->{mailing_address_line3}\n";
	$email_href->{content} = $content;
	
	eval {
	    my $sendmail = "/usr/sbin/sendmail -t";
	    open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
	    # print SENDMAIL $from;
	    print SENDMAIL $email_href->{reply_to};
	    print SENDMAIL $email_href->{to};
	    print SENDMAIL $email_href->{cc};
	    print SENDMAIL $email_href->{subject};
	    print SENDMAIL "Content-type: text/plain\n\n";
	    print SENDMAIL $email_href->{content};
	    close(SENDMAIL);
	};
	if ($@) {
	    # sendmail blew up
	    $self->log->debug("sendmail blew up");
	    $error_sendmail = 1;
	    $email_href->{content} =~ s/This is a supplementary block request generated from MAPLIN/MAPLIN had a problem sending email.\nThis is a MANUAL request./;
	    $email_href->{content} = "--- copy from here ---\n" . $email_href->{content} . "\n--- copy to here ---\n";
	} else {
	    $self->log->debug("sendmail sent request");
	}
    }

    my $template = $self->load_tmpl('supplemental/audiovisual_blocks.tmpl');
    $template->param(USERNAME  => $self->authen->username,
		     ASK => $ask,
		     #FROM => $email_href->{from},
		     TO => $email_href->{to},
		     CC => $email_href->{cc},
		     REPLY_TO => $email_href->{reply_to},
		     SUBJECT => $email_href->{subject},
		     CONTENT => $email_href->{content},
		     ERROR_SENDMAIL => $error_sendmail,
		     );
    return $template->output;
}



1; # so the 'require' or 'use' succeeds

