#!/usr/bin/perl

use strict;
use warnings;

use jQuery::File::Upload;

my $j_fu = jQuery::File::Upload->new;
$j_fu->upload_dir('/opt/fILL/brm_uploads');
$j_fu->max_file_size(5242880); # set a max file size of 5MB, for sanity
# should just accept .mrc and .items files...
$j_fu->max_number_of_files(20); # user must delete some files when limit reached
# filenames will look like "23887.mrc" and "23887.items", and will be unique.
$j_fu->use_client_filename(1);

$j_fu->handle_request;
$j_fu->print_response;

