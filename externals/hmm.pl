#!/usr/bin/perl

my $sendmail = "/usr/sbin/sendmail -t";
my $reply_to = "Reply-to: David.A.Christensen\@gmail.com\n";
my $subject  = "Subject: Hmm.\n";
my $content  = "This is a test.\n";
my $to       = "To: plslib1\@mts.net\n";
my $cc       = "Cc: David.A.Christensen\@gmail.com\n";
my $from     = "From: plslib1\@mts.net\n";


open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
print SENDMAIL $from;
print SENDMAIL $reply_to;
print SENDMAIL $subject;
print SENDMAIL $to;
print SENDMAIL $cc;
print SENDMAIL "Content-type: text/plain\n\n";
print SENDMAIL $content;
close(SENDMAIL);

print $from;
print $reply_to;
print $subject;
print $to;
print $cc;
print "Content-type: text/plain\n\n";
print $content;
