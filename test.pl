#!/usr/bin/perl
print "Content-type: text/html\r\n\r\n";
$document_root = $ENV{'DOCUMENT_ROOT'};
$incfile1 = $document_root . "include/subs.pl";
$incfile2 = $document_root . "include/subs_file.pl";
$incfile3 = $document_root . "include/subs_xml.pl";
$incfile4 = $document_root . "include/subs_string.pl";
$incfile5 = $document_root . "include/subs_render.pl";
$incfile6 = $document_root . "include/subs_config.pl";
$incfile7 = $document_root . "include/subs_auth.pl";
$incfile8 = $document_root . "include/subs_http.pl";

require $incfile1;
require $incfile2;
require $incfile3;
require $incfile4;
require $incfile5;
require $incfile6;
require $incfile7;
require $incfile8;

if ($ENV{'REQUEST_METHOD'} eq "POST")
  {
    #foreach $key (sort keys(%ENV)) 
    #{
    #  print "$key = $ENV{$key}<br />";
    #}
    $data;
    print "POSTed content length: ". $ENV{"CONTENT_LENGTH"} . "<br>";
    $len = $ENV{'CONTENT_LENGTH'};
    read STDIN, $data, $len;
    #print $data;
     
  }



print getRequest("upfile");
print <<END_HTML;
<form method='POST' enctype='multipart/form-data' action='$ENV{SCRIPT_NAME}'>

File to upload: <input type="text" name="upfile"><br>
Notes about the file: <input type="text" name="note"><br>
<br>
<input type="submit" value="Press"> to upload the file!
</form>
END_HTML
