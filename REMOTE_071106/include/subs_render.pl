##############################
#PAGE RENDERING###############
##############################

#get the components of each page and assemble them:
#I NEED TO SORT OUT THE DEFAULTS LOGIC!! - as subs to check for each default so I can mix 'n' match.
sub getPage
{
  my $LOGGED_IN_USER = getAuth();
  #logger("user is authorised: $LOGGED_IN_USER");
  my $path = $_[0];
  my $file = $_[1];
  my $searchoutput = $_[2]; #this is only passed from search page. otherwise, it is not used.
  #print $searchoutput;
  
  #get XML data file for page:
  my $data = getFile($path . "/" . $file . ".xml");
  #print "<!-- $data -->";
  
  #get search request if any:
  my $qt = getRequest("qt");
  #force lower case:
  $qt  =~ tr /A-Z/a-z/;  #'tr'anslate.
  
  #vars holding default values:
  my $default_page;
  my $default_section = ""; #root
  my $LAYOUT_SOURCE = "GLOBAL"; #or SECTION or PAGE
  
  #output:
  my $output = "";
  
  #get layout template file:
  my $layout = getFile("template/layout.tmpl");   #$LAYOUT_SOURCE = "GLOBAL";
  
  #check for it in defaults.cfg:
  if(fileExists($path . "defaults.cfg"))
  {
    $default_data       = getFile($path . "defaults.cfg");
    if(length(getXMLData("layoutpage",$default_data)) ne 0)
    {
      $layout             = getFile("template/" . getXMLData("layoutpage",$default_data));
      $LAYOUT_SOURCE      = "SECTION";
    }
  } 
  
  #also, check for and use layout page defined in the page if present - eg index page.
  if(length(getXMLData("layoutpage",$data)) ne 0)
  {
    $layout = getFile("template/" . getXMLData("layoutpage",$data));
    $LAYOUT_SOURCE = "PAGE";
  }
  #print "<!-- LAYOUT SOURCE: $LAYOUT_SOURCE -->";

  
  #now check for a 'defaults.cfg' in the current directory:    
  #if a defaults.cfg exists, use values stored here
  #rather than stored as local defaults - ie initialised
  #when a new page is created:
  my $default_page;
  if(fileExists($path . "defaults.cfg"))
  {
    $default_data       = getFile($path . "defaults.cfg");
    $default_page       = getXMLData("defaultpage",$default_data);
    $default_section    = getXMLData("currentdirectory",$default_data);
    #$layout             = getFile("template/" . getXMLData("layoutpage",$default_data));
    #$LAYOUT_SOURCE      = "SECTION";
  }
  
  else
  {
    #get defaults from the page:
    $default_page = getXMLData("defaultpage",$data);
  }
  
  #print $layout;
  
  ###################################################################
  # nav stuff: These are dependant on the site build                #
  ###################################################################
  
  my $atRoot = "false";
  if($path eq "/" || !$path)
  {
    $atRoot = "true";
  }
  
  #BUILD A HOME LINK, OR LINKTEXT***********************************************
  my $homelink = "<a href=\"/\">Home</a>";
  #determine if on HOME
  #if($path eq "/" && )
  #print $default_page."<br>";
  #print getPureFileName($ENV{"SCRIPT_NAME"})."<br>";
  #print $path."<br>";
  my $atRoot = "false";
  if($path eq "/" || !$path)
  {
    $atRoot = "true";
  }
  if((getPureFileName($ENV{"SCRIPT_NAME"}) eq $default_page) && ($atRoot eq "true"))
  {
    $homelink = "<b>Home</b>";
  }
  #END HOMELINK.****************************************************************
  
  
  #get editlink if session cookie is set:
  my $editlink = "";
  
  #we also want a greeting:
  $USER_GREETING;   #NOT local...

  #GENERATE AN Editlink if logged in. Compare the users rights bitmask with the authorisation 
  #right for the particular tag. Render only if user has rights:
  $editlink = "";
  if($LOGGED_IN_USER eq true)
  {
    #print "getting user details and edit links<br>";
    #we want a greeting regardless of whether the user is editor or visitor:
    $USER_GREETING = "Welcome " . getUserProperty("fullname");
    #print getUserProperty("email")."<br>";
    #print getUserProperty("fullname")."<br>";
    #print getUserProperty("name")."<br>";
    #print getUserProperty("password")."<br>";
    
    $editlink .= "<tr><td class=\"content\">" . $USER_GREETING;
    if(getUserAuth($RIGHTS_CREATE) eq true || getUserProperty("rights") eq $RIGHTS_ADMIN)
    {
      $editlink .= " [<a href=\"#\" onClick=\"editPage('/edit/editor_newfile2.pl')\"><b>Create</b></a> new page] ";
    }
    
    if(getUserAuth($RIGHTS_DELETE) eq true || getUserProperty("rights") eq $RIGHTS_ADMIN)
    {
      #we don't want to delete the default page, otherwise going to directory will throw a 404 error.
      if(getPureFileName($ENV{"SCRIPT_NAME"}) ne $default_page)
      {
        $editlink .= " [<a onclick=\"javascript:return(confirm('Really delete this page?'));\" href=\"/edit/editor_deletefile.pl?page=" . substr($ENV{"SCRIPT_NAME"},0,index($ENV{"SCRIPT_NAME"},".")) . "\"><b>Delete</b></a> this page] ";
      }
    }
    $editlink .= "[<a href=\"/logout.pl?return=" . $ENV{"SCRIPT_NAME"} . "\">Logout</a>]</b></td><td></td></tr>";
  }
  ###################################################################################################################
  #replace CMS placeholders in layout template:
  #loop over global config array defining tags to render from XML file:
  #we also want icons by each editable element if logged in. These
  #will pass the element and what type of content it is to the edit content page.
  #the edit content page will then allow editing of this particular element.
  my $editicon = "";
  my $alttext = "";
  my $contenttype = "";
  
  #iterative replacement of content tags. These don't require any format, so a simple replace will do.
  #The navs are different - see below - and all require additional logic.
  for(my $i = 0; $i < scalar(@TAGS_TO_RENDER); $i++)
  {
    $editicon = "";
    $alttext = "";
    $img_start_tag = "";
    $img_end_tag = "";
    
    $contenttype = getXMLTagParameter($TAGS_TO_RENDER[$i]{'tag'},$data,"datatype");
    
    #if $contenttype is 'image', then we need to wrap image tags around the content - ONLY if there is content!
    if($contenttype eq "image")# && length(replaceNewline(getXMLData($TAGS_TO_RENDER[$i]{'tag'}) eq 0)
    {
      $img_start_tag = "<img src=\"/images/";
      $img_end_tag = "\">";
    }
    
    #only proceed if the current user is allowed to edit the particular tag:
    if(getUserAuth($TAGS_TO_RENDER[$i]{'bitmask'}) eq true || getUserProperty("rights") eq $RIGHTS_ADMIN)
    {
      #generate edit link for elements that have a datatype of text - ie editable:
      if($LOGGED_IN_USER eq true && ($contenttype eq "text" || $contenttype eq "string"))
      {
        $alttext = getXMLTagParameter($TAGS_TO_RENDER[$i]{'tag'},$data,"friendlyname");
        $editicon = "<a href=\"#\" onClick=\"editPage('/edit/editor_editfile.pl?fname=".$path.$file.".xml&contentid=" . $TAGS_TO_RENDER[$i]{'tag'} . "')\">";
        $editicon .= "<img src=\"/images/edit.gif\" alt=\"Edit " . $alttext . "\" style=\"border:none;\"></a>&nbsp;";
      }
      
      #generate edit link for elements that have a datatype of image - ie editable: GET DIFFERENT ICON!
      if($LOGGED_IN_USER eq true && $contenttype eq "image")
      {
        $alttext = getXMLTagParameter($TAGS_TO_RENDER[$i]{'tag'},$data,"friendlyname");
        $editicon = "<a href=\"#\" onClick=\"editPage('/edit/editor_editfile.pl?fname=".$path.$file.".xml&contentid=" . $TAGS_TO_RENDER[$i]{'tag'} . "')\">";
        $editicon .= "<img src=\"/images/edit.gif\" alt=\"Edit " . $alttext . "\" style=\"border:none;\"></a>&nbsp;";
      }
    }
    $layout = replace($layout,$TAGS_TO_RENDER[$i]{'placeholder'},$editicon . $img_start_tag . replaceNewline(getXMLData($TAGS_TO_RENDER[$i]{'tag'},$data).$img_end_tag));
    #print "checking for tag $TAGS_TO_RENDER[$i]{'tag'}:<br>\n";
    #print "<xmp>".getXMLData($TAGS_TO_RENDER[$i]{'tag'},$data)."</xmp>\n";
  }
 
  #replace the navs and other slots not in the config array:
  $layout     = replace($layout,"{CMS_TOPNAV}",           getFolderNavData());
  $layout     = replace($layout,"{CMS_LHNAV}",            getMidgeNav($default_page,getNavData(getPath($ENV{"SCRIPT_NAME"}))));
  $layout     = replace($layout,"{CMS_CURRFILE}",         getPureFileNameWithExtension($ENV{'SCRIPT_NAME'})); #get the current path to drop into the JS call
  $layout     = replace($layout,"{CMS_HOMELINK}",         $homelink);
  $layout     = replace($layout,"{ENV_SCRIPT_NAME}",      $ENV{'SCRIPT_NAME'});
  $layout     = replace($layout,"{CMS_QT}",               $qt);
  $layout     = replace($layout,"{CMS_SEARCHRESULTS}",     $searchoutput);
  

  #replace the edit link:
  $layout     = replace($layout,"{CMS_EDITLINK}",     $editlink);
  
  #return processed string:
  $output .= $layout;
  return $output;
}

#generic function to return paths to folders defined in config sub:
sub getFolderNavData
{
  my $currsection = getPath($ENV{"SCRIPT_NAME"});
  my $self        = $ENV{"SCRIPT_NAME"};
  my $currdefault = getXMLData("defaultpage",getFile($currsection . "/defaults.cfg"));
  my $result = "&nbsp;";
  for(my $a=1;$a<scalar(@SITE_SECTIONS);$a++)
  {
    if($currsection eq $SITE_SECTIONS[$a]{path})
    {
      if(getPureFileName($self) eq $currdefault || $self eq "/index.pl")
      {
        $result .= "<b>" . $SITE_SECTIONS[$a]{linktext} . "</b>&nbsp;";
      }
      
      else
      {
        $result .= "<a href=\"/" . $SITE_SECTIONS[$a]{path} . "\" title=\"" . $SITE_SECTIONS[$a]{linktext} . "\"><b>" . $SITE_SECTIONS[$a]{linktext} . "</b></a>&nbsp;";
      }
    }
    
    else
    {        
      $result .= "<a href=\"/" . $SITE_SECTIONS[$a]{path} . "\" title=\"" . $SITE_SECTIONS[$a]{linktext} . "\">" . $SITE_SECTIONS[$a]{linktext} . "</a>&nbsp;";
    }
  }
  return $result;
}

##############################
#END PAGE RENDERING###########
##############################

1;  #must always return 1.
