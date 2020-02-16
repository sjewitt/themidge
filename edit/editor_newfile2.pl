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

#check for no auth and redirect if no login:
if(getAuth() eq false)
{
    print "HTTP/1.1 302 Object moved\r\n";
    print "Location: " . $SITE_BASE_URL . "\r\n";
}
print "Content-type: text/html\r\n\r\n";



#generate empty radio array:
if(length($FORM{"fname"}) eq 0)
{
  #set up the form radio buttons for path using the global config directories array:
  #$path_radio_buttons = "<input type=\"radio\" name=\"path\" value=\"/\">/<br />\n";
  for(my $a = 0; $a < scalar(@SITE_SECTIONS); $a++)
  {
    $path_radio_buttons .= "<input type=\"radio\" name=\"path\" value=\"/" . $SITE_SECTIONS[$a]{path} . "/\">/" . $SITE_SECTIONS[$a]{path} . "<br />\n";
  }
}


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
#we can use the authorised user - held as a cookie value - to add to the metadata of the page:
$user = getCookie("user");
 
if(length($FORM{"fname"}) > 0)
{
  #loop over form vars - each element has the same name as the 'tag' defined in the config sub.
  $fname      = $FORM{"fname"};
  $linktext   = $FORM{"linktext"};
  $pagetitle  = $FORM{"pagetitle"};
  $description= $FORM{"description"};
  $keywords   = $FORM{"keywords"};
  $author     = $FORM{"author"};
  $path       = $FORM{"path"};

    #set up the form radio buttons for path using the global config directories array, this time with the selected one checked:
    $path_radio_buttons = "<input type=\"radio\" name=\"path\" value=\"/\" ";
    if($path eq "/")
    {
      $path_radio_buttons .= "checked=\"checked\"";
    }
    $path_radio_buttons .= ">/<br />\n";
    for(my $a = 0; $a < scalar(@SITE_SECTIONS); $a++)
    {
      $path_radio_buttons .= "<input type=\"radio\" name=\"path\" value=\"/" . $SITE_SECTIONS[$a]{path} . "/\" ";
      
      #determine which radio button will be selected:
      if($path eq "/".$SITE_SECTIONS[$a]{path}."/")
      {
        $path_radio_buttons .= "checked";
      }
      $path_radio_buttons .= ">/" . $SITE_SECTIONS[$a]{path} . "/<br />\n";
    }

    #replace excess newlines:
    $content    = replace($content,"\n","");
    
    #result message:
    $result     = "";
    
    #load XML template:
    $src_xml = getFile("template/content_template.xml");
  
    #replace the core XML template placeholders with submitted vars:
    $src_xml     = replace($src_xml,"{CMS_PAGETITLE}",    $pagetitle);
    $src_xml     = replace($src_xml,"{CMS_KEYWORDS}",     $keywords);
    $src_xml     = replace($src_xml,"{CMS_AUTHOR}",       $user);         #from logged in user above.
    $src_xml     = replace($src_xml,"{CMS_OWNER}",        $user);         #from logged in user above.
    $src_xml     = replace($src_xml,"{CMS_DESCRIPTION}",  $description);
    $src_xml     = replace($src_xml,"{CMS_LINKTEXT}",     $linktext);

    #now create the new XML file at submitted path:
    if(fileExists($path . $fname . ".xml") == 0)
    {
        #print "creating file...<br>";
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
        $result = "<p>File '". $path . $fname . ".pl' created successfully!</p>";
        $result .= "Select the content area to edit from the links below:<br />";
        
        #generate content editing links from list of editable areas
        #defined in the XML template:
        #[note to me: can I redo the XML functions to return a hashmap? or can I pass a wildcard?]
        
        for($counter=0;$counter<scalar(@TAGS_TO_RENDER);$counter++)
        {
          if($TAGS_TO_RENDER[$counter]{createeditlink} eq true)
          {
            $result .= "<a href=\"/edit/editor_editfile.pl?fname=". $path . $fname . ".xml&contentid=" . $TAGS_TO_RENDER[$counter]{tag} . "\">" . getXMLTagParameter($TAGS_TO_RENDER[$counter]{tag},$src_xml,"friendlyname") . "</a><br />";
          }
        }
     }
    else
    {
        $result = "File already exists. Cannot continue.";
    }
}

if(getUserAuth($RIGHTS_CREATE) eq true || getUserProperty("rights") eq $RIGHTS_ADMIN)
{
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
          <td class="title">Create new page</td>
      </tr>
      <tr>
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
                  <td><input type="text" name="pagetitle" value="$pagetitle"></td>
              </tr>
              <tr>
                  <td>HTML description:</td>
                  <td><input type="text" name="description" value="$description"></td>
              </tr>
              <tr>
                  <td>HTML keywords: (nnn,nnn,nnn)</td>
                  <td><input type="text" name="keywords" value="$keywords"></td>
              </tr>
              <!-- tr>
                  <td>HTML Author:</td>
                  <td><input type="text" name="author" value="$author"></td>
              </tr -->
              <tr>
                  <td valign="top"><b>Path:</b></td>
                  <td>
                      $path_radio_buttons
                  </td>
              </tr>
  
              <!-- tr>
                  <td colspan="2">
                  <textarea name="content" cols="40" rows="10">$content</textarea>
                  </td>
              </tr>
              <tr>
                  <td colspan="2">
                  <textarea style="font-family:tahoma;font-size:9pt;" name="altcontent" cols="60" rows="5">$altcontent</textarea>
                  </td>
              </tr>
              <tr -->
                  <td></td>
                  <td><input type="submit" value="Create"><input type="reset" value="Clear"></td>
              </tr>
              </form>
               <tr>
                  <td>Content:</td>
                  <td>$result</td>
              </tr>
          </table>
          <p>[<a href="#" onClick="window.close();">Close</a>]</p>
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
  <title>EDITOR: create new page</title>
  
  </head>
  <body>  
  <p>You do not have rights to create new pages.</p>
  <p>[<a href="#" onClick="window.close();">Close</a>]</p>
  </body>
  </html>
END_NORIGHTS
}
