#!/usr/bin/perl

use DBI;
#use MARC::Record;

$dsn = "DBI:mysql:database=maplin;";
$dbh = DBI->connect($dsn, "mapapp", "maplin3db");

#my $sql = "SELECT id, target_id, found_at_server, title, author FROM marc WHERE sessionid=? ORDER BY ?";
#$marc_aref = $self->dbh->selectall_arrayref($sql,
#					    undef,
#					    "7f062339fc1dc7e5cf565100b5093508",
#					    "title"
#    );

#my $sth = $dbh->prepare($sql);
#$sth->execute("7f062339fc1dc7e5cf565100b5093508", "title");
#while (my $ref = $sth->fetchrow_hashref()) {
#    print "Found a row: id = $ref->{'id'}\n\ttitle = $ref->{'title'}\n\tauthor = $ref->{'author'}\n\n";
#}
#while (my $ref = $sth->fetchrow_arrayref()) {
#    print "Found a row: id = $ref->[0]\n\ttitle = $ref->[4]\n\tauthor = $ref->[5]\n\n";
#}
#$sth->finish();

#my $sql = "SELECT id, title, author FROM marc ORDER BY ?";
my $sql = "SELECT id, title, author FROM marc ORDER BY title";
my $sth = $dbh->prepare($sql);
#$sth->execute('title');
$sth->execute();
while (my $ref = $sth->fetchrow_arrayref()) {
    print "Found a row: id = $ref->[0]\n\ttitle = $ref->[1]\n\tauthor = $ref->[2]\n\n";
}
$sth->finish();


# Disconnect from the database.
$dbh->disconnect();
