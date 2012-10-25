#!/usr/bin/perl

use CGI;
use DBI;
use JSON;

my $query = new CGI;
my $lid = $query->param('lid');

my $dbh = DBI->connect("dbi:Pg:database=maplin;host=localhost;port=5432",
		       "mapapp",
		       "maplin3db",
		       {AutoCommit => 1, 
			RaiseError => 1, 
			PrintError => 0,
		       }
    ) or die $DBI::errstr;

$dbh->do("SET TIMEZONE='America/Winnipeg'");

my $SQL_completed = "select rc.rcid, r.name, rc.range_start, rc.range_end, rc.report_file as download from reports r left join reports_complete rc on r.rid=rc.rid where lid=? order by rc.report_file";
my $SQL_queued = "select r.name, rq.range_start, rq.range_end, rq.ts as submitted from reports r left join reports_queue rq on r.rid=rq.rid where lid=? order by rq.ts";

my $aref_completed = $dbh->selectall_arrayref($SQL_completed, { Slice => {} }, $lid );
my $aref_queued    = $dbh->selectall_arrayref($SQL_queued,    { Slice => {} }, $lid );

$dbh->disconnect;

print "Content-Type:application/json\n\n" . to_json( { reports => { completed => $aref_completed,
								    queued => $aref_queued
						       }});
