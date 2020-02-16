#!/usr/bin/perl
#include the library:
$document_root = $ENV{'DOCUMENT_ROOT'};
if(length($document_root) == 0){$document_root = "C:\/DEV\/webtest\/";}
$incfile = $document_root . "include/subs.pl";
require $incfile;

#check for no auth and redirect if no login:
if(getAuth() eq false)
{
    print "HTTP/1.1 302 Object moved\r\n";
    print "Location: http://www.themidge.co.uk/\r\n";
}
print "Content-type: text/html\r\n\r\n";

#result message:
$result     = "";
$path       = "";
#get the file request value:
$fname      = urlDecode(getRequest("page"));
#print $fname."<br>";
@pathparts = split(/\//,$fname);
$pathpart_length = @pathparts;
if($pathpart_length > 2)
{
  $path = "/" . @pathparts[1];
}
#print $path;
#print "filename submitted<br>";
if(fileExists($fname . ".xml") == 1)
{
    $result = "File $fname exists. Deleting...";
    #delete both the XML and the perl file:
    unlink($document_root . $fname . ".pl");
    unlink($document_root . $fname . ".xml");
}
else
{
    $result = "File does not exist. Cannot continue.";
}

print <<END_HTML;
<html>
<head>
<script language="JavaScript" src="/script/edit.js"></script>
<link rel="stylesheet" href="/styles/editstyle.css" type="text/css">
<title>EDITOR: delete page</title>

</head>
<body>
<table border="0" cellpadding="0" cellspacing="0">
    <tr>
        <td class="title">Deleting Page '$fname'</td>
    </tr>
    <tr>
        <td valign="top" class="content">
        <p><b>Result:</b></p>
            $result
            <p>[<a href="$path/">Close</a>]</p>
        </td>
    </tr>
</table>
</body>
<html>
END_HTML
