package fILL::charts;

use 5.006;
use strict;
use warnings FATAL => 'all';
use GD;
use GD::Graph::pie;
use MIME::Base64;
use DBI;
use PDF::API2;
use Data::Dumper;

=head1 NAME

fILL::charts - The great new fILL::charts!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use fILL::charts;

    my $foo = fILL::charts->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 CONSTANTS

Constants used to make measurements easier.  See http://rick.measham.id.au/pdf-api2/
There are 72 postscript points in an inch; there are 25.4 millimeters in an inch.

=cut
use constant mm => 25.4 / 72;
use constant in => 1 / 72;
use constant pt => 1;

=head1 SUBROUTINES/METHODS

#--------------------------------------------------------------------------------
=head2 new

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    my $self  = {};
    bless ($self, $class);

    $self->_init(@_);

    return $self;
}

#--------------------------------------------------------------------------------
=head2 _init

=cut

sub _init {
    my $self = shift;
#    $self->{param}->{oid} = 84;
#    $self->{param}->{month} = 4;
#    $self->{param}->{year} = 2015;
    while (my ($key, $value) = splice @_, 0, 2) {
	$self->{param}->{$key} = $value;
    }
    # should complain if oid, month and year are not valid values....
    $self->{parms_ok} = 1;
    $self->{report_created} = 0;

    $self->{dbh} = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
				"mapapp",
				"maplin3db",
				{AutoCommit => 1, 
				 RaiseError => 1, 
				 PrintError => 0,
				}
	) or die $DBI::errstr;
    #$dbh->do("SET TIMEZONE='America/Winnipeg'");

    $self->{data} = [];
    $self->{data}[0] = []; # labels
    $self->{data}[1] = []; # data
    {
	no warnings 'qw';
	$self->{receivedColours} = [ qw( #E0E6F8 #CED8F6 #A9BCF5 #819FF7 #5882FA #2E64FE ) ];
	$self->{unfilledColours} = [ qw( #F3E2A9 #F5DA81 #F7D358 #FACC2E #FFBF00 #DBA901 #F2F5A9 #F3F781 #F4FA58 #F7FE2E #FFFF00 #F5D0A9 #F7BE81 #FAAC58 #FE9A2E #FF8000) ];
    }
    $self->{colours} = [];
    $self->{legendText} = [];

    # GD / GD::Graph working areas
    $self->{work}->{pie} = undef;
    $self->{work}{legend} = undef;
    
    # GD final images
    $self->{chart}->{borrowing} = undef;
    $self->{chart}->{lending} = undef;

    # PDF
    $self->{pdf} = undef;
    $self->{'pdf-file'} = sprintf("%d-%4d%02d.pdf",
				  $self->{param}->{oid},
				  $self->{param}->{year},
				  $self->{param}->{month}
	);
}

#--------------------------------------------------------------------------------
=head2 create_report

=cut

sub create_report {
    my $self = shift;
    my $filename = shift;

    # Ok... do the work:
    $self->create_lending_chart();
    $self->create_borrowing_chart();
#    $self->create_pdf( $filename );
    $self->{report_created} = 1;
}

#--------------------------------------------------------------------------------
=head2 set

=cut

sub set {
    my $self = shift;

    while (my ($key, $value) = splice @_, 0, 2) {
	$self->{param}->{$key} = $value;
    }
    # should complain if oid, month and year are not valid values....
    $self->{parms_ok} = 1;
    $self->{report_created} = 0;

    undef $self->{data};
    $self->{data} = [];
    $self->{data}[0] = []; # labels
    $self->{data}[1] = []; # data

    $self->{colours} = [];
    $self->{legendText} = [];

    # GD / GD::Graph working areas
    $self->{work}->{pie} = undef;
    $self->{work}{legend} = undef;
    
    # GD final images
    $self->{chart}->{borrowing} = undef;
    $self->{chart}->{lending} = undef;
}

#--------------------------------------------------------------------------------
=head2 get_borrowing_chart

=cut

sub get_borrowing_chart {
    my $self = shift;

#    return $self->{chart}->{borrowing}->png;
    return encode_base64($self->{chart}->{borrowing});
}

#--------------------------------------------------------------------------------
=head2 get_lending_chart

=cut

sub get_lending_chart {
    my $self = shift;

#    return $self->{chart}->{lending}->png;
    return encode_base64($self->{chart}->{lending});
}

#--------------------------------------------------------------------------------
=head2 create_borrowing_chart

=cut

sub create_borrowing_chart {
    my $self = shift;

    undef $self->{data};
    $self->{data} = [];
    $self->{data}[0] = []; # labels
    $self->{data}[1] = []; # data
    undef $self->{colours};
    $self->{colours} = [];

    $self->_get_borrowing_received();
    $self->_get_borrowing_unfilled();
    $self->_create_pie_chart(
	"borrowing",
	"borrowing.png",
	"Borrowing " . $self->{param}->{year} . "-" . sprintf("%02d",$self->{param}->{month})
	);
}

#--------------------------------------------------------------------------------
=head2 create_lending_chart

=cut

sub create_lending_chart {
    my $self = shift;

    undef $self->{data};
    $self->{data} = [];
    $self->{data}[0] = []; # labels
    $self->{data}[1] = []; # data
    undef $self->{colours};
    $self->{colours} = [];

    $self->_get_lending_shipped();
    $self->_get_lending_unfilled();
    $self->_create_pie_chart(
	"lending",
	"lending.png",
	"Lending " . $self->{param}->{year} . "-" . sprintf("%02d",$self->{param}->{month})
	);
}

#--------------------------------------------------------------------------------
=head2 _create_pie_chart

=cut

sub _create_pie_chart {
    my $self = shift;
    my $whichChart = shift;
    my $fname = shift;
    my $title = shift;

    $self->_calculate_percentages();
    $self->_create_pie($title);
    #$self->_create_big_pie();
    $self->_create_legend();
    $self->_combine();

    $self->{chart}->{$whichChart} = $self->{img}->png;

#    open(my $out, '>', $fname) or
#	die "Cannot open '" . $fname . "' for write: $!";
#    binmode $out;
#    print $out $self->{img}->png;
#    close $out;
}


#--------------------------------------------------------------------------------
=head2 _combine

=cut

sub _combine {
    my $self = shift;

    # GD::Graph::Pie doesn't seem to do PNG format...
    my $pie = GD::Image->newFromGifData($self->{work}->{pie}->gd->gif);
#    my $pie = GD::Image->newFromJpegData($self->{work}->{pie}->gd->jpeg);

    my ($pW, $pH) = $pie->getBounds();

    if (($pW != 250) && ($pH != 260)) {
	$self->{work}->{pie} = new GD::Image( 250, 260 );
	$self->{work}->{pie}->copyResampled( $pie,       # src img 
					      0,0,        # dest x,y
					      0,0,        # src x,y
					      250,260,    # destW, destH
					      $pW,$pH     # srcW, srcH
	    );
    } else {
	$self->{work}->{pie} = $pie;
    }

    my ($bPw, $bPh) = $self->{work}->{pie}->getBounds();
    my ($legW, $legH) = $self->{work}->{legend}->getBounds();
    $self->{img} = new GD::Image( $bPw > $legW ? $bPw : $legW, $bPh+$legH);
    $self->{img}->copy($self->{work}->{pie},      # src img
		       0,0,                        # dest coords to paste (upper left)
		       0,0, $bPw,$bPh              # src region upper left x,y and width,height
	);
    $self->{img}->copy($self->{work}->{legend},   # src img
		       0,$bPh+1,                   # dest coords to paste (upper left)
		       0,0, $legW,$legH            # src region upper left x,y and width,height
	);
}

#--------------------------------------------------------------------------------
=head2 _create_pie

=cut

sub _create_pie {
    my $self = shift;
    my $title = shift;

    $self->{work}->{pie} = new GD::Graph::pie( 250, 260 );

    $self->{work}->{pie}->set( 
	title => $title,
	label => 'Legend',
	dclrs => $self->{colours},
	axislabelclr => 'black',
	pie_height => 36,
	'3d' => 0,
	l_margin => 10,
	r_margin => 10,
	# approximate boundary conditions for start_angle
	#start_angle => -85,
	#start_angle => 15,
	suppress_angle => 360 * 0.03, # 3%, in degrees
	transparent => 0,
	);

    $self->{work}->{pie}->set_value_font(GD::Font->Giant);

    $self->{work}->{pie}->plot($self->{data});
#    $self->save_chart($self->{work}->{pie}, 'my-pie');
}

#--------------------------------------------------------------------------------
=head2 create_big_pie ... debugging.  Trying to lose jaggies by creating a big image and resizing

=cut

sub _create_big_pie {
    my $self = shift;
    my $title = shift;
#    $self->{work}->{pie} = new GD::Graph::pie( 250, 260 );
    $self->{work}->{pie} = new GD::Graph::pie( 2500, 2600 );

    $self->{work}->{pie}->set( 
	title => "Borrowing " . $self->{param}->{year} . "-" . sprintf("%02d",$self->{param}->{month}),
	label => 'Legend',
	dclrs => $self->{colours},
	axislabelclr => 'black',
#	pie_height => 36,
	pie_height => 360,
	'3d' => 0,
#	l_margin => 10,
#	r_margin => 10,
	l_margin => 100,
	r_margin => 100,
	# approximate boundary conditions for start_angle
	#start_angle => -85,
	#start_angle => 15,
	
	transparent => 0,
	);

#    $self->{work}->{pie}->set_value_font(GD::Font->Giant);
    $self->{work}->{pie}->set_label_font('/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf',100);
    $self->{work}->{pie}->set_value_font('/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf',100);

    $self->{work}->{pie}->plot($self->{data});
#    $self->save_chart($self->{work}->{pie}, 'my-pie');
}

#--------------------------------------------------------------------------------
=head2 _create_legend

=cut

sub _create_legend {
    my $self = shift;

    my $imgHeight = scalar( @{$self->{data}[0]} ) * 20;
    $self->{work}->{legend} = new GD::Image(250,$imgHeight);
    $self->{work}->{legend}->colorAllocate(255,255,255);
    $self->{work}->{legend}->rectangle(0,0,249,$imgHeight-1,$self->{work}->{legend}->colorAllocate(0,0,0));

    my $black = $self->{work}->{legend}->colorAllocate(0,0,0);
    my $x1 = 2;
    my $y1 = 2;
    my $x2 = 18;
    my $y2 = 18;
    my $max = scalar( @{$self->{data}[0]} );
    for (my $cn = 0; $cn < $max; $cn++) {
	# turn html hex colour ("#XXYYZZ") into RGB:
	my @rgb = map $_, unpack 'C*', pack 'H*', substr $self->{colours}[$cn],1;
#	foreach (@rgb) { print STDERR "\t$_,"; } print "\n";
	my $thiscolor = $self->{work}->{legend}->colorAllocate($rgb[0],$rgb[1],$rgb[2]);
	
	$self->{work}->{legend}->filledRectangle($x1,$y1, $x2,$y2, $thiscolor);

	$self->{work}->{legend}->string(gdSmallFont,$x2+2,$y1+2,$self->{legendText}[$cn],$black);

	$y1 = ($cn+1) * 20;
	$y2 = $y1 + 18;
    }
    
#    open(my $out, '>', "borrowingLegend.png") or
#	die "Cannot open 'borrowingLegend.png' for write: $!";
#    binmode $out;
#    # Convert the image to PNG and print it on standard output
#    print $out $self->{work}->{legend}->png;
#    close $out;
}

#--------------------------------------------------------------------------------
=head2 _calculate_percentages

=cut

sub _calculate_percentages {
    my $self = shift;

    undef $self->{legendText};
    $self->{legendText} = [];

    # get total number of requests
    my $total = 0;
    foreach my $c (@{$self->{data}[1]}) {
	$total += $c;
    }
    my $max = scalar( @{$self->{data}[0]} );
    if ($total > 0) {
	for (my $i = 0; $i < $max; $i++) {
	    my $percent = sprintf("%.0f%%", ($self->{data}[1][$i] / $total) * 100);
	    push $self->{legendText}, $self->{data}[0][$i] . ": " . $self->{data}[1][$i] . " ($percent)";
	    $self->{data}[0][$i] = $percent;
	}
    }
}

#--------------------------------------------------------------------------------
=head2 _get_borrowing_received

=cut

sub _get_borrowing_received {
    my $self = shift;
    my $SQL = "select
 extract(YEAR from ts) as year,
 extract(MONTH from ts) as monthnum,
 to_char(ts,'Month') as month,
 case when s.call_number ~ E'[[:digit:]]+[.][[:digit:]]*' then 'NF'
      when s.call_number ~ E'[[:digit:]]{3} [[:alpha:]][[:alpha:]]+' then 'NF'
      when s.call_number ~ 'NF ' then 'NF'
      when s.call_number ~ 'Non(-| )' then 'NF'
      when s.call_number ~ 'DVD' then 'AV'
      when s.call_number ~ 'CD' then 'AV'
      else 'FIC'
 end as type,
 count(distinct rc.chain_id) as items_count 
from
 request_closed rc
 left join requests_history h on h.request_id=rc.id
 left join sources_history s on s.request_id = rc.id  
where
 h.msg_from=?
 and h.status='Received'
 and extract(YEAR from ts)=?
 and extract(MONTH from ts)=? 
group by year, monthnum, month, type  
order by year, monthnum, month, type
";

    my $aryref = $self->{dbh}->selectall_arrayref($SQL, { Slice => {} }, 
						  $self->{param}->{oid}, 
						  $self->{param}->{year}, 
						  $self->{param}->{month});

    my $colourCnt = 0;
    foreach my $row (@$aryref) {
	push $self->{data}[0], "Received " . $row->{type};
	push $self->{data}[1], $row->{items_count};
	push $self->{colours}, $self->{receivedColours}[$colourCnt++];
    }
}


#--------------------------------------------------------------------------------
=head2 _get_borrowing_unfilled

=cut

sub _get_borrowing_unfilled {
    my $self = shift;
#-- need to count only the requests where NO response was "filled"....
    my $SQL = "select
 extract(YEAR from ts) as year,
 extract(MONTH from ts) as monthnum,
 to_char(ts,'Month') as month,
 case when s.call_number ~ '\\d+\\.\\d*' then 'NF'
      when s.call_number ~ '\\d{3} \\D\\D+' then 'NF'
      when s.call_number ~ 'NF ' then 'NF'
      when s.call_number ~ 'Non(-| )' then 'NF'
      when s.call_number ~ 'DVD' then 'AV'
      when s.call_number ~ 'CD' then 'AV'
      else 'FIC'
 end as type,
 count(distinct rc.chain_id) as items_count 
from
 request_closed rc
 left join requests_history h on h.request_id=rc.id
 left join sources_history s on s.request_id = rc.id  
where
 h.msg_from=?
 and h.status like '%Unfilled%'
 and rc.chain_id not in (
   select chain_id
    from request_closed rc2
         left join requests_history h2 on h2.request_id=rc2.id
    where rc2.chain_id = rc.chain_id
         and h2.status = 'Shipped' 
 )
 and extract(YEAR from ts)=?
 and extract(MONTH from ts)=? 
group by year, monthnum, month, type  
order by year, monthnum, month, type
";

    my $aryref = $self->{dbh}->selectall_arrayref($SQL, { Slice => {} }, 
						  $self->{param}->{oid}, 
						  $self->{param}->{year}, 
						  $self->{param}->{month});

    my $colourCnt = 0;
    foreach my $row (@$aryref) {
	push $self->{data}[0], "Unfilled " . $row->{type};
	push $self->{data}[1], $row->{items_count};
	push $self->{colours}, $self->{unfilledColours}[$colourCnt++];
    }
}

#--------------------------------------------------------------------------------
=head2 _get_lending_shipped

=cut

sub _get_lending_shipped {
    my $self = shift;
    my $SQL = "select
 extract(YEAR from ts) as year,
 extract(MONTH from ts) as monthnum,
 to_char(ts,'Month') as month,
 count(distinct rc.chain_id) as items_count 
from
 request_closed rc
 left join requests_history h on h.request_id=rc.id
 left join sources_history s on s.request_id = rc.id  
where
 h.msg_from=?
 and h.status='Shipped'
 and extract(YEAR from ts)=?
 and extract(MONTH from ts)=? 
group by year, monthnum, month  
order by year, monthnum, month
";

    my $href = $self->{dbh}->selectrow_hashref($SQL, { Slice => {} }, 
					       $self->{param}->{oid}, 
					       $self->{param}->{year}, 
					       $self->{param}->{month});

    push $self->{data}[0], "Shipped";
    push $self->{data}[1], $href->{items_count};
    push $self->{colours}, $self->{receivedColours}[0]; # I know... "received" colours.
}


#--------------------------------------------------------------------------------
=head2 _get_lending_unfilled

=cut

sub _get_lending_unfilled {
    my $self = shift;

    my $SQL = "select
 extract(YEAR from ts) as year,
 extract(MONTH from ts) as monthnum,
 to_char(ts,'Month') as month,
 h.status,
 count(h.status) as status_count 
from
 request_closed rc
 left join requests_history h on h.request_id=rc.id
 left join sources_history s on s.request_id = rc.id  
where
 h.msg_from=?
 and h.status like '%Unfilled%'
 and extract(YEAR from ts)=?
 and extract(MONTH from ts)=? 
group by year, monthnum, month, status   
order by year, monthnum, month, status
";

    my $aryref = $self->{dbh}->selectall_arrayref($SQL, { Slice => {} }, 
						  $self->{param}->{oid}, 
						  $self->{param}->{year}, 
						  $self->{param}->{month});

    my $colourCnt = 0;
    foreach my $row (@$aryref) {
	$row->{status} =~ s/ILL-Answer\|Unfilled\|//;
	push $self->{data}[0], "Unfilled " . $row->{status};
	push $self->{data}[1], $row->{status_count};
	push $self->{colours}, $self->{unfilledColours}[$colourCnt++];
    }
}

#--------------------------------------------------------------------------------
=head2 save_chart

=cut

sub save_chart
{
    my $self = shift;
    my $chart = shift or die "Need a chart!";
    my $name = shift or die "Need a name!";

    my $ext = $chart->export_format;

    open(my $out, '>', "$name.$ext") or
	die "Cannot open '$name.$ext' for write: $!";
    binmode $out;
    print $out $chart->gd->$ext();
    close $out;
}

#--------------------------------------------------------------------------------
=head2 text_block

From Rick Measham's excellent tutorial, Using PDF::API2, and licensed under the LGPL v2.1

text_block() is (c) Rick Measham, 2004-2007.  The latest version can be found in the tutorial located at http://rick.measham.id.au/pdf-api2/

The basic syntax of the function is:
($width_of_last_line, $ypos_of_last_line, $left_over_text) = text_block(

    $text_handler_from_page,
    $text_to_place,
    -x        => $left_edge_of_block,

    -y        => $baseline_of_first_line,
    -w        => $width_of_block,

    -h        => $height_of_block,
   [-lead     => $font_size * 1.2 | $distance_between_lines,]
   [-parspace => 0 | $extra_distance_between_paragraphs,]
   [-align    => "left|right|center|justify|fulljustify",]
   [-hang     => $optional_hanging_indent,]

);
=cut

sub text_block {

    my $text_object = shift;
    my $text        = shift;

    my %arg = @_;
    
    # Get the text in paragraphs
    my @paragraphs = split( /\n/, $text );
    
    # calculate width of all words
    my $space_width = $text_object->advancewidth(' ');
    
    my @words = split( /\s+/, $text );
    my %width = ();
    foreach (@words) {
	next if exists $width{$_};
	$width{$_} = $text_object->advancewidth($_);
    }
    
    my $ypos = $arg{'-y'};
    my @paragraph = split( / /, shift(@paragraphs) );
    
    my $first_line      = 1;
    my $first_paragraph = 1;
    
    my $endw;

    # while we can add another line
    
    while ( $ypos >= $arg{'-y'} - $arg{'-h'} + $arg{'-lead'} ) {
	
	unless (@paragraph) {
	    last unless scalar @paragraphs;
	    
	    @paragraph = split( / /, shift(@paragraphs) );
	    
	    $ypos -= $arg{'-parspace'} if $arg{'-parspace'};
	    last unless $ypos >= $arg{'-y'} - $arg{'-h'};
	    
	    $first_line      = 1;
	    $first_paragraph = 0;
	}
	
	my $xpos = $arg{'-x'};
	
	# while there's room on the line, add another word
	my @line = ();
	
	my $line_width = 0;
	if ( $first_line && exists $arg{'-hang'} ) {
	    
	    my $hang_width = $text_object->advancewidth( $arg{'-hang'} );
	    
	    $text_object->translate( $xpos, $ypos );
	    $text_object->text( $arg{'-hang'} );
	    
	    $xpos       += $hang_width;
	    $line_width += $hang_width;
	    $arg{'-indent'} += $hang_width if $first_paragraph;
	    
	}
	elsif ( $first_line && exists $arg{'-flindent'} ) {
	    
	    $xpos       += $arg{'-flindent'};
	    $line_width += $arg{'-flindent'};
	    
	}
	elsif ( $first_paragraph && exists $arg{'-fpindent'} ) {
	    
	    $xpos       += $arg{'-fpindent'};
	    $line_width += $arg{'-fpindent'};
	    
	}
	elsif ( exists $arg{'-indent'} ) {
	    
	    $xpos       += $arg{'-indent'};
	    $line_width += $arg{'-indent'};
	    
	}
	
	while ( @paragraph
		and $line_width + ( scalar(@line) * $space_width ) +
		$width{ $paragraph[0] } < $arg{'-w'} )
	{
	    
	    $line_width += $width{ $paragraph[0] };
	    push( @line, shift(@paragraph) );
	    
	}
	
	# calculate the space width
	my ( $wordspace, $align );
	if ( $arg{'-align'} eq 'fulljustify'
             or ( $arg{'-align'} eq 'justify' and @paragraph ) )
	{
	    
	    if ( scalar(@line) == 1 ) {
		@line = split( //, $line[0] );
		
	    }
	    $wordspace = ( $arg{'-w'} - $line_width ) / ( scalar(@line) - 1 );
	    
	    $align = 'justify';
	}
	else {
	    $align = ( $arg{'-align'} eq 'justify' ) ? 'left' : $arg{'-align'};
	    
	    $wordspace = $space_width;
	}
	$line_width += $wordspace * ( scalar(@line) - 1 );
	
	if ( $align eq 'justify' ) {
	    foreach my $word (@line) {
		
		$text_object->translate( $xpos, $ypos );
		$text_object->text($word);
		
		$xpos += ( $width{$word} + $wordspace ) if (@line);
		
	    }
	    $endw = $arg{'-w'};
	}
	else {
	    
	    # calculate the left hand position of the line
	    if ( $align eq 'right' ) {
		$xpos += $arg{'-w'} - $line_width;
		
	    }
	    elsif ( $align eq 'center' ) {
		$xpos += ( $arg{'-w'} / 2 ) - ( $line_width / 2 );
		
	    }
	    
	    # render the line
	    $text_object->translate( $xpos, $ypos );
	    
	    $endw = $text_object->text( join( ' ', @line ) );
	    
	}
	$ypos -= $arg{'-lead'};
	$first_line = 0;
	
    }
    unshift( @paragraphs, join( ' ', @paragraph ) ) if scalar(@paragraph);
    
    return ( $endw, $ypos, join( "\n", @paragraphs ) )
}

#--------------------------------------------------------------------------------
=head2 create_pdf

=cut

sub create_pdf {
    my $self = shift;

    # NOTE that PDF coords are from lower left (i.e. cartesian)

    $self->{pdf} = PDF::API2->new( -file => $self->{'pdf-file'} );
    my $pdf = $self->{pdf};  # less typing...
    my $page = $pdf->page;
    # mediabox width and height:
#    $page->mediabox( 105/mm, 148/mm);
    $page->mediabox( 'Letter' );   # 612pt x 792pt, aka 215.9 mm x 279.4 mm
    # cropbox left, bottom, right, top:
#    $page->cropbox( 7.5/mm, 7.5/mm, 97.5/mm, 140.5/mm );

    $self->{font} = {
	'Helvetica' => {
	    'Bold'   => $self->{pdf}->corefont('Helvetica-Bold',    -encoding => 'latin1'),
	    'Roman'  => $self->{pdf}->corefont('Helvetica',         -encoding => 'latin1'),
	    'Italic' => $self->{pdf}->corefont('Helvetica-Oblique', -encoding => 'latin1'),
	},
	'Times' => {
	    'Bold'   => $self->{pdf}->corefont( 'Times-Bold',    -encoding => 'latin1' ),
	    'Roman'  => $self->{pdf}->corefont( 'Times',         -encoding => 'latin1' ),
	    'Italic' => $self->{pdf}->corefont( 'Times-Italic',  -encoding => 'latin1' ),
	},
    };
    
    # Headline
    # grab a text handler:
    my $headline_text = $page->text;
    $headline_text->font( $self->{font}{'Helvetica'}{'Bold'}, 18/pt );
    $headline_text->fillcolor('black');
    # move the cursor:
#    $headline_text->translate( 95/mm, 131/mm );
    $headline_text->translate( 10/mm, 265/mm );
    $headline_text->text('[Branch/System] fILL Monthly Report [Month/Year]');

    # Body text
    my $left_column_text = $page->text;
    $left_column_text->font( $self->{font}{'Times'}{'Roman'}, 6/pt );
    $left_column_text->fillcolor('black');
#    my ($endw, $ypos, $paragraph) = text_block(
#	$left_column_text,
#	"Borrowing From Other Libraries In [Month,Year], the [Branch or System] patrons mad [#] ILL requests to other libraries.  From those requests:",
#	-x => 10/mm,
#	-y => 119/mm,
#	-w => 41.5/mm,
#	-h => 110/mm - ( 119/mm - 7/pt ),
#	-lead     => 7/pt,
#	-parspace => 0/pt,
#	-align    => 'justify',
#	);
    my ($endw, $ypos, $paragraph) = text_block(
	$left_column_text,
	"Borrowing From Other Libraries In [Month,Year], the [Branch or System] patrons mad [#] ILL requests to other libraries.  From those requests:",
	-x => 10/mm,
	-y => 119/mm,
	-w => 41.5/mm,
	-h => 110/mm - ( 119/mm - 7/pt ),
	-lead     => 7/pt,
	-parspace => 0/pt,
	-align    => 'justify',
	);

    # graph
    my $img = $page->gfx;
    my $png = $pdf->image_png( $self->{chart}->{borrowing}->png );
    $img->image( $png, 54/mm, 66/mm, 41/mm, 55/mm );
    $pdf->save;
    $pdf->end();
}



=head1 AUTHOR

David Christensen, C<< <David.A.Christensen at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-fill-pdfreports at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=fILL-charts>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc fILL::charts


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=fILL-charts>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/fILL-charts>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/fILL-charts>

=item * Search CPAN

L<http://search.cpan.org/dist/fILL-charts/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2015 David Christensen.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; version 2 dated June, 1991 or at your option
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

A copy of the GNU General Public License is available in the source tree;
if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA


=cut

1; # End of fILL::charts
