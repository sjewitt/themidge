#!/usr/bin/perl
#include the library:
$document_root = $ENV{'DOCUMENT_ROOT'};
$incfile1 = $document_root . "include/subs.pl";
$incfile2 = $document_root . "include/subs_file.pl";
$incfile3 = $document_root . "include/subs_xml.pl";
$incfile4 = $document_root . "include/subs_string.pl";
$incfile5 = $document_root . "include/subs_render.pl";
$incfile6 = $document_root . "include/subs_config.pl";
$incfile7 = $document_root . "include/subs_auth.pl";
$incfile8 = $document_root . "include/subs_http.pl";
$incfile_edit = $document_root . "include/subs_edit.pl";

require $incfile1;
require $incfile2;
require $incfile3;
require $incfile4;
require $incfile5;
require $incfile6;
require $incfile7;
require $incfile8;
require $incfile_edit;

$ELEMENT_TO_EDIT = getRequest("contentid");
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
if(getUserAuth($RIGHTS_DELETE) eq true || getUserProperty("rights") eq $RIGHTS_ADMIN)
{
  print <<END_HTML;
  <html>
  <head>
  <script language="JavaScript" src="/script/edit.js"></script>
  <link rel="stylesheet" href="/styles/editstyle.css" type="text/css">
  <title>EDITOR: delete page</title>
  
  </head>
  <body>
  $ELEMENT_TO_EDIT
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
}
#if no rights, render appropriate message.
else
{
  print <<END_NORIGHTS;
  <html>
  <head>
  <link rel="stylesheet" href="/styles/editstyle.css" type="text/css">
  <title>EDITOR: delete page</title>
  
  </head>
  <body>  
  <p>You do not have rights to delete pages.</p>
  <p>[<a href="#" onClick="window.close();">Close</a>]</p>
  </body>
  </html>
END_NORIGHTS
}

