#!/usr/bin/perl
print "Content-type: text/html\r\n\r\n";
$document_root = $ENV{'DOCUMENT_ROOT'};
$incfile1 = $document_root . "include/subs.pl";
$incfile2 = $document_root . "include/subs_file.pl";
$incfile3 = $document_root . "include/subs_xml.pl";
$incfile4 = $document_root . "include/subs_string.pl";
$incfile5 = $document_root . "include/subs_render.pl";
$incfile6 = $document_root . "include/subs_config.pl";

require $incfile1;
require $incfile2;
require $incfile3;
require $incfile4;
require $incfile5;
require $incfile6;
print getPage("/fish/", "crispyfishcakes");

