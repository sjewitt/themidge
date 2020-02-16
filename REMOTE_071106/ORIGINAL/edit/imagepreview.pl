#!/usr/bin/perl
print "Content-type: text/html\r\n\r\n";
$document_root = $ENV{'DOCUMENT_ROOT'};
if(length($document_root) == 0){$document_root = "C:\/DEV\/webtest\/";}
$incfile = $document_root . "include/subs.pl";
require $incfile;
$image = getRequest("image");

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

<a href="#" onClick="insertAtCursor(opener.document.newpage.content,'$image',true)">Add this image</a><br />
<a href="#" onClick="window.close();">Done</p>
</body>
</html>
END_HTML
