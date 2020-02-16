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
$image = getRequest("image");
$field = getRequest("field");

print <<END_HTML;
<html>
<head>
<link rel="stylesheet" href="/styles/style.css" type="text/css">
<title>Image preview</title>
<script language="JavaScript" src="/script/edit.js"></script>
</head>
<body>
<img src="$image">
<br>

<a href="#" onClick="insertAtCursor(opener.document.newpage.$field,'$image',true)">Add this image</a><br />
<a href="#" onClick="window.close();">Done</p>
</body>
</html>
END_HTML
