#!/usr/bin/perl

use strict;
use warnings;

use jQuery::File::Upload;

my $j_fu = jQuery::File::Upload->new;
$j_fu->upload_dir('/opt/fILL/ill_uploads');
$j_fu->max_file_size(5242880); # set a max file size of 5MB, for sanity
# should just accept .mrc and .items files...
$j_fu->max_number_of_files(20); # user must delete some files when limit reached
# filenames will look like "2015-03-16.csv", and will be unique.
$j_fu->use_client_filename(1);

$j_fu->handle_request;
$j_fu->print_response;

