#!/usr/bin/perl
$document_root = $ENV{'DOCUMENT_ROOT'};
if(length($document_root) == 0){$document_root = "C:\/DEV\/webtest\/";}
$incfile = $document_root . "include/subs.pl";
require $incfile;

#check for currently logged in:
$logged_in = getAuth();
#$logged_in = false;

#have login details been POSTed?
if(($ENV{'REQUEST_METHOD'} eq 'POST') or ($logged_in eq true))
{
    $user = "";
    $pwd = "";
    #get form vars if posted:
    read(STDIN, $postdata,$ENV{'CONTENT_LENGTH'});
    @pairs = split(/&/, $postdata);
    
    foreach $pair (@pairs) 
    {
        ($name, $value) = split(/=/, $pair);
        $value =~ tr/+/ /;
        $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
        $FORM{$name} = $value;
        if($name eq "user")
        {
            $user = $value;
        }
        
        if($name eq "pwd")
        {
            $pwd = $value;
        }
    }
    
    #do user/pwd match auth user?
    if(($user eq "clare" && $pwd eq "clareix") or ($logged_in eq true))
    {
        $logged_in = true;
        print "Set-Cookie:authorised=yes\r\n";
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
        <td class="title">Authorised</td>
    </tr>
    <tr>
        <td class="content">
            $user logged in OK.<br />
            Click <a href="/">here</a> to continue.
        </td>
</table>
</body>
END_OK_HTML
    }
    else
    {
        print "Content-type: text/html\r\n\r\n";
        print <<END_NOT_OK_HTML;
<html>
<head>
<link rel="stylesheet" href="/styles/style.css" type="text/css">
<title>Login failed</title>
</head>
<body>
<table border="0" cellpadding="0" cellspacing="0">
    <tr>
        <td class="title">Not authorised</td>
    </tr>
    <tr>
        <td class="content">
            Password or username is not correct.<br />
            Click <a href="/login.pl">here</a> to try again.
        </td>
</table>
</body>
END_NOT_OK_HTML
    }
}

#otherwise, render form:
else
{
    print "Content-type: text/html\r\n\r\n";

print <<END_HTML;
<html>
<head>
<link rel="stylesheet" href="/styles/style.css" type="text/css">
<title>Login</title>
</head>
<body>
<form name="login" method="POST" action="">
<table border="0" cellpadding="0" cellspacing="0">
    <tr>
        <td colspan="2" class="title">Login</td>
    </tr>
    <tr>
        <td class="content">
            <table>
                <tr>
                    <td width="180">Name</td>
                    <td><input type="text" name="user" value=""></td>
                </tr>
                <tr>
                    <td width="180">Password</td>
                    <td><input type="password" name="pwd" value=""></td>
                </tr>
                <tr>
                    <td colspan="2"><input type="submit" value="Log In"></td>
                </tr>          
            </table>
        </td>
</table>
</form>    
END_HTML
}
