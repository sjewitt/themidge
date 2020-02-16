#!/usr/bin/perl
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

$returnurl = getRequest("return");
        $logged_in = false;
        print "Set-Cookie:authorised=no\r\n";
        print "Set-Cookie:user=nobody\r\n";
        print "Content-type: text/html\r\n\r\n";
        print <<END_OK_HTML;
<html>
<head>
<link rel="stylesheet" href="/styles/style.css" type="text/css">
<title>Login OK</title>
</head>
<body>
<table border="0" cellpadding="0" cellspacing="0">
    <tr>
        <td class="title">Logged out</td>
    </tr>
    <tr>
        <td class="content">
            logged out OK.<br />
            Click <a href="$returnurl">here</a> to continue.    
        </td>
</table>
</body>
END_OK_HTML
