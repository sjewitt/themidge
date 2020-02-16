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

#form enabled/disabled:
$FIELD_IS_ENABLED = "disabled=\"disabled\"";

#GENERATE LINKS TO CURRENT PAGES TO EDIT:
$editlinks = getEditLinks("","","/");
$editlinks .= getEditLinks("/meat/","&nbsp;&nbsp;","/meat");
$editlinks .= getEditLinks("/fish/","&nbsp;&nbsp;","/fish");
$editlinks .= getEditLinks("/vegetables/","&nbsp;&nbsp;","/vegetables");
$editlinks .= getEditLinks("/chicken/","&nbsp;&nbsp;","/chicken");
$editlinks .= getEditLinks("/cocktails/","&nbsp;&nbsp;","/cocktails");
$editlinks .= getEditLinks("/desserts/","&nbsp;&nbsp;","/desserts");

if($ENV{'REQUEST_METHOD'} eq 'POST')
{
    #get form vars if posted:
    read(STDIN, $postdata,$ENV{'CONTENT_LENGTH'});
    @pairs = split(/&/, $postdata);
    foreach $pair (@pairs) 
    {
        ($name, $value) = split(/=/, $pair);
        $value =~ tr/+/ /;
        $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
        $FORM{$name} = $value;
    }
}
else
{
    #get the initial file request value:
    $fname      = urlDecode(getRequest("fname"));
}

if(length($FORM{"fname"}) > 0 || length($fname) > 0)
{
    #print "filename submitted<br>";
    if(fileExists($path . $fname) == 1)
    {
        #set flag to enable form:
        $FIELD_IS_ENABLED = "";
        
        #get the data for the submitted file:
        $src_xml = getFile($path . "/" . $fname);

        #set vars from XML:
        $linktext   = getXMLData("linktext",    $src_xml);
        $title      = getXMLData("heading",     $src_xml);
        $descr      = getXMLData("description", $src_xml);
        $kwds       = getXMLData("keywords",    $src_xml);
        $auth       = getXMLData("author",      $src_xml);
        $content    = getXMLData("body",        $src_xml);
        
        if($FORM{"update"} eq "go")
        {
            $linktext   = $FORM{"linktext"};
            $title      = $FORM{"title"};
            $descr      = $FORM{"descr"};
            $kwds       = $FORM{"kwds"};
            $auth       = $FORM{"auth"};
            $content    = $FORM{"content"};
            
            #replace excess newlines:
            $content    = replace($content,"\n","");
            $fname      = $FORM{"fname"};
            $src_xml    = getFile($path . "/" . $fname);
            
            #update the XML:
            $src_xml    = setXMLData("heading",    $src_xml,   $title);
            $src_xml    = setXMLData("linktext",   $src_xml,   $linktext);
            $src_xml    = setXMLData("description",$src_xml,   $descr);
            $src_xml    = setXMLData("keywords",   $src_xml,   $kwds);
            $src_xml    = setXMLData("author",     $src_xml,   $auth);
            $src_xml    = setXMLData("body",       $src_xml,   $content);

            updateFile($fname,$src_xml);
        }
    }
    else
    {
        $result = "File does not exist. Cannot continue.";
    }
    $imagelinks = getImagesForInsert();
}

print <<END_HTML;
<html>
<head>
<script language="JavaScript" src="/script/edit.js"></script>
<link rel="stylesheet" href="/styles/editstyle.css" type="text/css">
<title>EDITOR: edit existing page</title>

</head>
<body>
<table border="0" cellpadding="0" cellspacing="0">
    <tr>
        <td width="180" class="title">Pages</td>
        <td class="title">Page properties</td>
        <td class="title">Images</td>
    </tr>
    <tr>
        <td width="180" valign="top" class="content">
        $editlinks
        </td>
        <td valign="top" class="content">
        <p><b>Update page properties:</b></p>
        <table>
            <form name="newpage" method="post" action="$ENV{"SCRIPT_NAME"}">
            <input type="hidden" name="update" value="go" $FIELD_IS_ENABLED>
            <tr>
                <td>Data file:</td>
                <td>$fname<input type="hidden" name="fname" value="$fname" $FIELD_IS_ENABLED></td>
            </tr>
            <tr>
                <td>linktext:</td>
                <td><input style="font-family:tahoma;font-size:9pt;" type="text" name="linktext" value="$linktext" $FIELD_IS_ENABLED></td>
            </tr>
            <tr>
                <td>page title:</td>
                <td><input style="font-family:tahoma;font-size:9pt;" type="text" name="title" value="$title" $FIELD_IS_ENABLED></td>
            </tr>
            <tr>
                <td>HTML description:</td>
                <td><input style="font-family:tahoma;font-size:9pt;" type="text" name="descr" value="$descr" $FIELD_IS_ENABLED></td>
            </tr>
            <tr>
                <td>HTML keywords: (nnn,nnn,nnn)</td>
                <td><input style="font-family:tahoma;font-size:9pt;" type="text" name="kwds" value="$kwds" $FIELD_IS_ENABLED></td>
            </tr>
            <tr>
                <td>HTML Author:</td>
                <td><input style="font-family:tahoma;font-size:9pt;" type="text" name="auth" value="$auth" $FIELD_IS_ENABLED></td>
            </tr>
            <tr>
                <td colspan="2">Content:</td>
            </tr>
            <tr>
                <td colspan="2">
                <textarea style="font-family:tahoma;font-size:9pt;" name="content" cols="60" rows="10">$content</textarea>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                <input type="button" value="Update" onClick="submitAndRefresh()" $FIELD_IS_ENABLED>
                <input type="reset" value="Clear" $FIELD_IS_ENABLED></td>
            </tr>
            </form>
        </table>
            $result
            Add a new page <a href="/edit/editor_newfile2.pl">here</a>.
            <p>[<a href="#" onClick="window.close();">Close</a>]</p>
        </td>
        <td valign="top" class="content">
        <p><b>Add images:</b></p>
        <p>Choose from the available images here. Click on the '+' to add.</p>
        $imagelinks</td>
    </tr>
</table>
</body>
<html>
END_HTML
