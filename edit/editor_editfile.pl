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

#get the element that is to be edited:
$ELEMENT_TO_EDIT          = getRequest("contentid");
$ELEMENT_TO_EDIT_CAPTION  = "";  #set this from the friendlyname attribute of the element, below:
$ADD_NEWPAGE_LINK         = "";
if(getUserAuth($RIGHTS_CREATE) eq true || getUserProperty("rights") eq $RIGHTS_ADMIN)
{
  $ADD_NEWPAGE_LINK         = "Add a new page <a href=\"/edit/editor_newfile2.pl\">here</a>.";
}

#check for no auth and redirect if no login:
if(getAuth() eq false)
{
    print "HTTP/1.1 302 Object moved\r\n";
    print "Location: " . $SITE_BASE_URL . "\r\n";
}
print "Content-type: text/html\r\n";
print "Expires: 0\r\n\r\n";

#result message:
$result     = "";

#form enabled/disabled:
$FIELD_IS_ENABLED = "disabled=\"disabled\"";
$formvalue = "";  #reset this

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
    
    #set hidden field passing the field being edited:
    $ELEMENT_TO_EDIT = $FORM{"contentid"};
    $datatype = $FORM{'datatype'};
    $fname = $FORM{'fname'};
    $formvalue = $FORM{$ELEMENT_TO_EDIT}
}
else
{
    #get the initial file request value:
    $fname      = urlDecode(getRequest("fname"));
}
 
#execute if a filename is passed:
if(length($FORM{"fname"}) > 0 || length($fname) > 0)
{
    #continue if passed file exists:
    if(fileExists($path . $fname) == 1)
    {
        #set flag to enable form:
        $FIELD_IS_ENABLED = "";
        
        #get the data for the submitted file:
        $src_xml = getFile($path . "/" . $fname);
        #print "<xmp>".$src_xml."</xmp>";
        
        #we have $fname at this point, from either the initial url param, or from the POSTed value:
        #we can therefore set the friendlyname property:
        $ELEMENT_TO_EDIT_CAPTION = getXMLTagParameter($ELEMENT_TO_EDIT,$src_xml,friendlyname);
        
        #set vars from XML. we want to get the content of the passed XML content tag:
        $linktext           = getXMLData("linktext",    $src_xml);
        $pagetitle          = getXMLData("pagetitle",     $src_xml);
        $description        = getXMLData("description", $src_xml);
        $keywords           = getXMLData("keywords",    $src_xml);
        #if $formvalue has not been set - ie the form has not yet been submitted - set it from teh XML:
        if(length($formvalue) eq 0)
        {
          $formvalue        = getXMLData($ELEMENT_TO_EDIT,        $src_xml);
        }

        $content            = getXMLData($ELEMENT_TO_EDIT,        $src_xml);
        
        #replace excess newlines:
        $content    = replace($content,"\n","");
        #$content    = replace($content,"\r","");
        
        #print "tag content: ".$content . "<br>";
        #print "datatype before XML call: ".$datatype ."<br>";
        #get the datatype of the passed content tag, and render an appropriate HTML form element.
        #this call is only made if the value has not been passed on form submission:
        if(length($datatype) eq 0)
        {
          $datatype = getXMLTagParameter($ELEMENT_TO_EDIT,$src_xml,"datatype");
          #$content = $FORM{$ELEMENT_TO_EDIT};
        }
        #datatypes are "property", "text", "string", "image" or "core".
        #print "datatype after XML call: ".$datatype;
        ##########################################
        # GENERATE EDIT ELEMENTS BY CONTENT TYPE #
        ##########################################
        $CONTENT_ELEMENT = "";
        if($datatype eq "text")
        {
          #build textarea:
          $CONTENT_ELEMENT = "<textarea style=\"font-family:arial;font-size:9pt;\" name=\"$ELEMENT_TO_EDIT\" cols=\"82\" rows=\"12\">$formvalue</textarea>";
        }
        
        if($datatype eq "string")
        {
          $CONTENT_ELEMENT = "<input type=\"text\" name=\"$ELEMENT_TO_EDIT\" value=\"$formvalue\">";
          #build textbox:
        }
        
        if($datatype eq "image")
        {
          $CONTENT_ELEMENT = "<select name=\"$ELEMENT_TO_EDIT\">";
          $CONTENT_ELEMENT .= getImagesAsDropdown($content);
          #<input type=\"text\" name= value=\"$formvalue\">";
          #build textbox:
        }
        #print "<xmp>".$CONTENT_ELEMENT."</xmp>";
        if($FORM{"update"} eq "go")
        {
          #logger("BEGIN UPDATE:");
            $linktext         = $FORM{"linktext"};
            $pagetitle        = $FORM{"pagetitle"};
            $description      = $FORM{"description"};
            $keywords         = $FORM{"keywords"};

            $content          = $FORM{$ELEMENT_TO_EDIT};
            #print"<xmp>$content</xmp>";            #replace excess newlines:
            $content    = replace($content,"\n","");
            #logger("excess newline replaced...");
            #$content    = replace($content,"\r","");
            #print"<xmp>$content</xmp>"; 
            
            $fname      = $FORM{"fname"};
            $src_xml    = getFile($path . "/" . $fname);
            #logger("source XML obtained...");
            #update the XML:
            #logger("setting title...");
            $src_xml    = setXMLData("pagetitle",       $src_xml,   $pagetitle);
            #logger("setting linktext");
            $src_xml    = setXMLData("linktext",        $src_xml,   $linktext);
            #logger("setting descr...");
            $src_xml    = setXMLData("description",     $src_xml,   $description);
            #logger("setting keywords...");
            $src_xml    = setXMLData("keywords",        $src_xml,   $keywords);
            
            #logger("updating $ELEMENT_TO_EDIT");
            $src_xml    = setXMLData($ELEMENT_TO_EDIT,  $src_xml,   $content);
            #print"<xmp>$src_xml</xmp>"; 
            #logger("calling file update funtion");
            updateFile($fname,$src_xml);
            #logger("END UPDATE.");
        }
    }
    else
    {
        $result = "File does not exist. Cannot continue.";
    }
    #pass the name of the element - which is also the name of the form field:
    #note - we dont want to add an image to a string - such as a heading.
    if($datatype eq "text")
    {
      $imagelinks = getImagesForInsert($ELEMENT_TO_EDIT);
    }
}


if(getUserAuth($RIGHTS_EDIT) eq true || getUserProperty("rights") eq $RIGHTS_ADMIN)
{
  print <<END_HTML;
  <html>
  <head>
  <script language="JavaScript" src="/script/edit.js"></script>
  <link rel="stylesheet" href="/styles/editstyle.css" type="text/css">
  <title>EDITOR: edit existing page</title>
  
  </head>
  <body>
  <table border="1" cellpadding="0" cellspacing="0">
      <tr>
          <td valign="top" class="content">
          <b>Standard page properties:</b>
          <table border="1" cellpadding="0" cellspacing="0">
              <form name="newpage" method="post" action="$ENV{"SCRIPT_NAME"}">
              <input type="hidden" name="fname" value="$fname" $FIELD_IS_ENABLED>
              <input type="hidden" name="update" value="go" $FIELD_IS_ENABLED>
              <input type="hidden" name="contentid" value="$ELEMENT_TO_EDIT">
              <input type="hidden" name="datatype" value="$datatype">
              <tr>
                  <td><span style="color:#d00;">Linktext:</span></td>
                  <td><input style="font-family:arial;font-size:9pt;" type="text" name="linktext" value="$linktext" $FIELD_IS_ENABLED></td>
                  <td><span style="color:#d00;">Title:</span></td>
                  <td><input style="font-family:arial;font-size:9pt;" type="text" name="pagetitle" value="$pagetitle" $FIELD_IS_ENABLED></td>
              </tr>
              <tr>
                  <td><span style="color:#d00;">Description:</span></td>
                  <td><input style="font-family:arial;font-size:9pt;" type="text" name="description" value="$description" $FIELD_IS_ENABLED></td>
                  <td><span style="color:#d00;">Keywords:</td>
                  <td><input style="font-family:arial;font-size:9pt;" type="text" name="keywords" value="$keywords" $FIELD_IS_ENABLED></td>
              </tr>
              <tr>
                  <td colspan="4"><span style="color:#d00;">$ELEMENT_TO_EDIT_CAPTION content:</span><br />
                  $CONTENT_ELEMENT
                  </td>
              </tr>
              <tr>
                  <td colspan="4">
                  <input type="button" value="Update" onClick="submitAndRefresh()" $FIELD_IS_ENABLED>
                  <input type="reset" value="Clear" $FIELD_IS_ENABLED></td>
              </tr>
              </form>
          </table>
              $result
              $ADD_NEWPAGE_LINK
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
}


#if no rights, render appropriate message.
else
{
  print <<END_NORIGHTS;
  <html>
  <head>
  <link rel="stylesheet" href="/styles/editstyle.css" type="text/css">
  <title>EDITOR: edit page</title>
  
  </head>
  <body>  
  <p>You do not have rights to edit pages.</p>
  <p>[<a href="#" onClick="window.close();">Close</a>]</p>
  </body>
  </html>
END_NORIGHTS
}
