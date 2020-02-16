#!/usr/bin/perl
print "Content-type: text/html\r\n\r\n";
$document_root = $ENV{'DOCUMENT_ROOT'};
if(length($document_root) == 0){$document_root = "C:/DEV/webtest/";}
$incfile = $document_root . "include/subs.pl";
require $incfile;
print getPage("test", "item2");

