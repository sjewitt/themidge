#!/usr/bin/perl
$document_root = $ENV{'DOCUMENT_ROOT'};
if(length($document_root) == 0){$document_root = "C:\/DEV\/webtest\/";}
$incfile = $document_root . "include/subs.pl";
require $incfile;
$returnurl = getRequest("return");
        $logged_in = false;
        print "Set-Cookie:authorised=no\r\n";
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
