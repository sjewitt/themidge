#!/usr/bin/perl

$document_root = $ENV{'DOCUMENT_ROOT'};
if(length($document_root) == 0){$document_root = "C:\/DEV\/webtest\/";}

$incfile = $document_root . "include/subs.pl";
require $incfile;
$ch1 = "";
$ch2 = "";
$ch3 = "";
$ch4 = "";
$ch5 = "";
$ch6 = "";
$ch7 = "";

#check for no auth and redirect if no login:
if(getAuth() eq false)
{
    print "HTTP/1.1 302 Object moved\r\n";
    print "Location: http://www.themidge.co.uk/\r\n";
}
$imagelinks = getImagesForInsert();
print "Content-type: text/html\r\n\r\n";
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

if(length($FORM{"fname"}) > 0)
{
    #get request values:
    $fname      = $FORM{"fname"};
    $linktext   = $FORM{"linktext"};
    $title      = $FORM{"title"};
    $descr      = $FORM{"descr"};
    $kwds       = $FORM{"kwds"};
    $auth       = $FORM{"auth"};
    $path       = $FORM{"path"};
    $content    = $FORM{"content"};
    
    #determine which radio button will be selected:
    if($path eq "/"){           $ch1 = "checked";}
    if($path eq "/meat/"){      $ch2 = "checked";}
    if($path eq "/fish/"){      $ch3 = "checked";}
    if($path eq "/vegetables/"){$ch4 = "checked";}
    if($path eq "/chicken/"){   $ch5 = "checked";}
    if($path eq "/cocktails/"){ $ch6 = "checked";}
    if($path eq "/desserts/"){  $ch7 = "checked";}

    #replace excess newlines:
    $content    = replace($content,"\n","");
    
    #result message:
    $result     = "";
    
    #load XML template:
    $src_xml = getFile("template/content_template.xml");
  
    #replace the XML template placeholders with submitted vars:
    $src_xml     = replace($src_xml,"{CMS_PAGETITLE}",    $title);
    $src_xml     = replace($src_xml,"{CMS_KEYWORDS}",     $kwds);
    $src_xml     = replace($src_xml,"{CMS_AUTHOR}",       $auth);
    $src_xml     = replace($src_xml,"{CMS_DESCRIPTION}",  $descr);
    $src_xml     = replace($src_xml,"{CMS_LINKTEXT}",     $linktext);
    $src_xml     = replace($src_xml,"{CMS_CONTENT}",      $content);

    #now create the new XML file at submitted path:
    #print $fname;
    if(fileExists($path . $fname . ".xml") == 0)
    {
        $result = createFile($fname . ".xml",$path,$src_xml);
    }
    else
    {
        $result = "XML datafile already exists. Cannot continue."
    }
    
    #create the source .pl file:
    $src_pl_stub = getFile("template/stub_src_template.tmpl");
    if(fileExists($path . $fname . ".pl") == 0)
    {
        #now replace the CMS tags with the appropriate values:
        $src_pl_stub = replace($src_pl_stub,"{CMS_PATHONLY}",   $path);
        $src_pl_stub = replace($src_pl_stub,"{CMS_FILENAME}",   $fname);
        createFile($fname . ".pl",$path,$src_pl_stub);
        $result = "File '". $path . $fname . ".pl' created successfully!<br />";
    }
    else
    {
        $result = "File already exists. Cannot continue.";
    }
}
print <<END_HTML;
<html>
<head>
<script language="JavaScript" src="/script/edit.js"></script>
<link rel="stylesheet" href="/styles/editstyle.css" type="text/css">
<title>EDITOR: create new page</title>

</head>
<body>
<table border="0" cellpadding="0" cellspacing="0">
    <tr>
        <td width="180" class="title">&nbsp;</td>
        <td class="title">Create new page</td>
        <td class="title">Images</td>
    </tr>
    <tr>
        <td width="180" valign="top" class="content">
        <p><b>Notes</b></p>
        Add properties and content 
        for the new page. You may
        edit this and other pages  
        <a href="/edit/editor_editfile.pl">here</a>.
        <p>[<a href="#" onClick="window.close();">Close</a>]</p>
        </td>
        <td valign="top" class="content">
        
        <p><b>New page properties:</b></p>
        <table>
            <form name="newpage" method="post" action="$ENV{"SCRIPT_NAME"}">
            <tr>
                <td>filename: (no extension)</td>
                <td><input type="text" name="fname" value="$fname"></td>
            </tr>
            <tr>
                <td>linktext:</td>
                <td><input type="text" name="linktext" value="$linktext"></td>
            </tr>
            <tr>
                <td>page title:</td>
                <td><input type="text" name="title" value="$title"></td>
            </tr>
            <tr>
                <td>HTML description:</td>
                <td><input type="text" name="descr" value="$descr"></td>
            </tr>
            <tr>
                <td>HTML keywords: (nnn,nnn,nnn)</td>
                <td><input type="text" name="kwds" value="$kwds"></td>
            </tr>
            <tr>
                <td>HTML Author:</td>
                <td><input type="text" name="auth" value="$auth"></td>
            </tr>
            <tr>
                <td valign="top"><b>Path:</b></td>
                <td>
                    <input type="radio" name="path" $ch1 value="/"> / <br />
                    <input type="radio" name="path" $ch2 value="/meat/"> /meat/ <br />
                    <input type="radio" name="path" $ch3 value="/fish/"> /fish/ <br />
                    <input type="radio" name="path" $ch4 value="/vegetables/"> /vegetables/ <br />
                    <input type="radio" name="path" $ch5 value="/chicken/"> /chicken/ <br />
                    <input type="radio" name="path" $ch6 value="/cocktails/"> /cocktails/ <br />
                    <input type="radio" name="path" $ch7 value="/desserts/"> /desserts/ <br />
                </td>
            </tr>
            <tr>
                <td colspan="2">Content:</td>
            </tr>
            <tr>
                <td colspan="2">
                <textarea name="content" cols="40" rows="10">$content</textarea>
                </td>
            </tr>
            <tr>
                <td></td>
                <td><input type="submit" value="Create"><input type="reset" value="Clear"></td>
            </tr>
            </form>
        </table>

        </td>
        <td valign="top" class="content">
        <p><b>Add images:</b></p>
        <p>Choose from the available images here. Click on the '+' to add.</p>
        $imagelinks
        
        <p><b>Result:</b></p>
            $result
        </td>
    </tr>
</table>
</body>
<html>
END_HTML
