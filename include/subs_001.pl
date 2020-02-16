#get a data struture holding navigation data:
sub getNavData
{
  $path       = $_[0];    #nav root
  $default    = $_[1];    #directory default page - ie current 'home' - WITHOUT extension
  
  my $root = getRoot();
  my $currpage;     #the current page in iteration
  my $currUrl;      #placeholder for item URL
  my $currLinktext; #placeholder for item linktext
  my $currStatus;   #placeholder for whether link or just linktext
  my $FILES_TO_INCLUDE = ".xml";   #regexp? or array?
  my $comparator;
  my @result;       #an array of hashmaps
  my $leading = "";
  
  #determine if we are at the root. bugger about with the path if not:
  my $atRoot = true;
  if(length($path) > 0)
  {
    #if we are NOT at root, add a leading slash:
    $atRoot = false;
    $leading = "/";
  }
  #get self:
  my $self = $ENV{"SCRIPT_NAME"};
  
  opendir NAV, $root . $path;
  
  #an array:
  my @contents = readdir NAV;

  foreach $listitem ( @contents )
  {
    #check for double // if path is zero-length:
    $currpage = $leading . $listitem;  #listitem is the current item in the folder. NO slashes
    
    #check whether its a file or a directory, ignore directories:
    if ( -d $listitem ) {}  
    else
    {
      
      #check the current file is of correct type and NOT the default directory page:
      if((substr($currpage,(index($currpage,".")),length($currpage)) eq $FILES_TO_INCLUDE) && !($listitem eq $default . $FILES_TO_INCLUDE))
      {
        #print $listitem." OK: ";
        #get the current page linktext:
        $currLinktext = getXMLData("linktext",getFile($path . "/" . substr($listitem,0,index($listitem,".")) . ".xml"));
        
        #if no linktext defined, use the page url (no extension) instead:
        if(length($currLinktext) eq 0)
        {
          $currLinktext = $currpage;
        }
        
        #as we pulled out the XML data files only, we need to generate .pl files instead for the URLs: 
        $currUrl = substr($listitem,0,index($listitem,".")) . ".pl";
  
        if($atRoot eq false)
        {
          $comparator = $path . substr($currpage,1,index($currpage,".")) . "pl";
        }
        else
        {
          $comparator = "/" . $path . substr($currpage,0,index($currpage,".")) . ".pl";
        }
        #print "LINKTEXT: " . $currLinktext.", ";
        if($self eq $comparator)
        {
          $currStatus = "SELF";
        }
        else
        {
          $currStatus = "LINK";
        }
        #print "STATUS: " . $currStatus . "<br>";
        #push the data onto the result array:
        push(@result,{url=>$currUrl,linktext=>$currLinktext,status=>$currStatus});
      }
    }
  }
  close NAV;
  #print "LENGTH OF RESULT WHEN LEAVING SUB: " . scalar(@result) . "<br>";
  return @result;         #an array of nav items
}
#site specific formatted nav - javascript arrays in this case:
sub getCovenNavs
{
  my $result = "";
  my $secondarynav_JS = "var nav=new Object();\n";
  my @curr_secondarynav_data;
  my $primarynav_JS = "var primarynav = new Array();\nvar homenav = new Array();";
  for($counter=0;$counter<scalar(@SITE_SECTIONS);$counter++)
  {
    $primarynav_JS .= "primarynav[$counter] = {url: \"/" . $SITE_SECTIONS[$counter]{path} . "\", linktext: \"" . $SITE_SECTIONS[$counter]{linktext} . "\", image: \"/images/" . $SITE_SECTIONS[$counter]{path} . "_sml.jpg\"};\n";
    $primarynav_JS .= "homenav[$counter] = {url: \"/" . $SITE_SECTIONS[$counter]{path} . "\", linktext: \"" . $SITE_SECTIONS[$counter]{linktext} . "\", image: \"/images/" . $SITE_SECTIONS[$counter]{path} . ".jpg\"};\n";
    
    @curr_secondarynav_data = getNavData($SITE_SECTIONS[$counter]{path});
    $secondarynav_JS .= "nav." . $SITE_SECTIONS[$counter]{path} . "nav=new Array();\n";
    for($counter2=0;$counter2<scalar(@curr_secondarynav_data);$counter2++)
    {
      $secondarynav_JS .= "nav." . $SITE_SECTIONS[$counter]{path} . "nav[$counter2]=new Object();\n";
      $secondarynav_JS .= "nav." . $SITE_SECTIONS[$counter]{path} . "nav[$counter2].page={url: \"/" . $SITE_SECTIONS[$counter]{path} . "/" . $curr_secondarynav_data[$counter2]{url} . "\", linktext: \"" . $curr_secondarynav_data[$counter2]{linktext} . "\"};\n";
    }
  }
  $result = $primarynav_JS . $secondarynav_JS;
  return $result;
}

######################################
#END NAVIGATION FUNCTIONS#############
######################################

######################################
#URL MANIPULATION FUNCTIONS###########
######################################
#get value of passed request parameter:
sub getRequest
{
  my $param = $_[0];
  if ($ENV{'REQUEST_METHOD'} eq "GET")
  {
    my $request = $ENV{'QUERY_STRING'};
    my $query_length = length($request);
    my @pairs;
    my $name;
    my $value;
    if($query_length > 0)
    {
      #get query values:
      @pairs = split(/&/,$request);
      foreach(@pairs)
      {
        #we need just the filename param, so check for this:
        #unencode url parameters:
        s/\+/ /g;
        s/%([0-9A-F][0-9][A-F])/pack("c",hex($1))/ge;
        
        ($name, $value) = split(/=/);
        if($name eq $param)
        {
          return $value;
        }
      }
    }
  } 
}

sub urlDecode
{
  $input = $_[0];
  $output = $input;
  $output =~ s/\+/ /g;
  $output =~ s/%([\dA-Fa-f]{2})/pack("C", hex($1))/eg;
  return $output;
}
######################################
#END URL MANIPULATION FUNCTIONS#######
######################################

######################################
#AUTHORISATION FUNCTIONS##############
######################################
#check that the current session is authorised:
#I may change this later on...
#sub getAuth
#{
#  #check for cookie:
#  my $cookiestring = $ENV{'HTTP_COOKIE'};    #get all the cookies
#  my @cookies = split(/;/, $cookiestring);   #get an array of cookies
#  my $cookie;
#  my $auth = false;
#  
#  #iterate over cookies:
#  #logger("in getAuth()...");
#  foreach $cookie (@cookies)
#  {
#    #logger($cookie);
#    if ($cookie eq "authorised=yes")
#    {
#      $auth = true;
#    }
#    #else
#    #{
#    #  $auth = false;
#    #}
#  }
#  return $auth;
#}

#get the value of supplied cookie name:
#sub getCookie
#{
#  #logger("in getCookie...");
#  my $cookie_name = $_[0];
#  #logger("looking for value of $cookie_name:");
#  my $cookiestring = $ENV{'HTTP_COOKIE'};    #get all the cookies
#  my @cookies = split(/;/, $cookiestring);   #get an array of cookies
#  my $result = false;
#  foreach $cookie (@cookies)
#  {
#    if (index($cookie,$cookie_name . "=") >= 0)
#    {
#      #logger("found value!");
#      $result = substr($cookie,index($cookie,"=")+1,length($cookie));
#    }
#  }
#  return($result);
#}

#use this to determine whether the edit/delete etc links appear for the given user:
#sub getUserProperty
#{
#  my $user      = getCookie("user");
#  my $property  = $_[0];  #the user property to retrieve
#  my $returnval = "";
#  #print "CURRENT USER:" . $user . "<br>";
#  for(my $counter=0;$counter<scalar(@USERS);$counter++)
#  {
#    
#    if($user eq $USERS[$counter]{'user'})
#    {
#      #print "--> checking " . $USERS[$counter]{'user'} . "<br>";
#      $returnval = $USERS[$counter]{$property};
#    }
#  }
#  return $returnval;
#}

#sub getUserAuth
#{
#  my $returnval = false;
#  my $RIGHT_TO_CHECK = $_[0];   #passed right to check (as a constant - see subs_config).
#  my $res = $RIGHT_TO_CHECK & getUserProperty("rights"); #binary comparison:

#  if($res > 0)
#  {
#    $returnval = true;
#  }
#  return $returnval;
#}

#check for an authorised login attempt:
#sub authenticate
#{
#  my $user      = $_[0];
#  my $password  = $_[1];
#  my $result    = false;
#  
#  for(my $a = 0; $a < scalar(@USERS); $a++)
#  {
#    if(($user eq $USERS[$a]{'user'}) && ($password eq $USERS[$a]{'password'}))
#    {
#      $result = true;
#    }
#  }
#  return $result;
#}

######################################
#END AUTHORISATION FUNCTIONS##########
######################################


######################################
#EDITING - LIST DISPLAY FUNCTIONS#####
######################################
#get list of gif/jpg in /images/ folder
#and generate appropriate links for adding
#images:
sub getImagesForInsert
{
  my $form_element = $_[0];
  my $path = "/images/";
  my $root = getRoot();
  my $extn = "";
  opendir IMAGES, $root . $path;
  
  #an array:
  my @contents = readdir IMAGES;
  my $output = "<table>";
  #loop over list:
  foreach $image ( @contents )
  {
    if ( -d $image ) {}  
    else
    {
      $extn = substr( $image,index($image,".")+1,length($image));
      if(lc($extn) eq "jpg" or lc($extn) eq "gif")
      {
        $output .= "<tr><td>" . $image . "</td>";
        $output .= "<td>&nbsp;<a href=\"#\" onClick=\"insertAtCursor(document.newpage." . $form_element . ", '" . $path.$image . "',false)\" title=\"Add image at current cursor location\"><b>+</b></a>&nbsp;</td>"; 
        $output .= "<td>&nbsp;<a href=\"#\" onClick=\"openImagePreview('" . $path.$image . "','" . $form_element . "')\" title=\"Preview image\">view</a>&nbsp;</td>";
      }
    }
  }
  $output .= "</table>";
  close IMAGES;
  return $output;
}

######################################
#EDITING - LIST DISPLAY FUNCTIONS#####
######################################
#get list of gif/jpg in /images/ folder
#and generate appropriate links for adding
#images:
sub getImagesAsDropdown
{
  my $current_image = $_[0];
  my $path = "/images/";
  my $root = getRoot();
  my $extn = "";
  my $selected = "";
  opendir IMAGES, $root . $path;
  
  #an array:
  my @contents = readdir IMAGES;
  #my $output = "<table>";
  #loop over list:
  foreach $image ( @contents )
  {
    if ( -d $image ) {}  
    else
    {
      $extn = substr( $image,index($image,".")+1,length($image));
      if(lc($extn) eq "jpg" or lc($extn) eq "gif")
      {
        $selected = "";
        if($image eq $current_image)
        {
          $selected = "selected=\"selected\"";
        }
        $output .= "<option value=\"" . $image . "\" " . $selected . ">" . $image . "</option>";
       # $output .= "<td>&nbsp;<a href=\"#\" onClick=\"insertAtCursor(document.newpage." . $form_element . ", '" . $path.$image . "',false)\" title=\"Add image at current cursor location\"><b>+</b></a>&nbsp;</td>"; 
       # $output .= "<td>&nbsp;<a href=\"#\" onClick=\"openImagePreview('" . $path.$image . "','" . $form_element . "')\" title=\"Preview image\">view</a>&nbsp;</td>";
      }
    }
  }
  #$output .= "</table>";
  close IMAGES;
  return $output;
}


#generate a set of links with URL parameters:
sub getEditLinks
{
  my $UPDATE_PAGE     = "editor_editfile.pl";
  my $path            = $_[0];
  my $indent          = $_[1];
  my $navheading      = $_[2];
  #get directory listing:
  my $output;
  my $root = getRoot();
  my $currpage;
  my $FILES_TO_INCLUDE = ".xml";
  
  opendir NAV, $root . $path;
  
  #an array:
  my @contents = readdir NAV;
  
  #loop over list:
  my $nav = "";
  my $currLinkText;
  
  #add navheading:
  $nav .= "<b>" . $_[2] . "</b><br />";
  foreach $listitem ( @contents )
  {
    $currpage = $listitem;
    $output .= $listitem;
    #check whether its a file or a directory, ignore directories:
    if ( -d $listitem ) {}  
    else
    {
      if(substr($currpage,(index($currpage,".")),length($currpage)) eq $FILES_TO_INCLUDE)
      {
        #check for double // if path is zero-length:
        
        if(length($path) > 0)
        {
          $currpage = "/" . $listitem;
        }
        #get the current page linktext:
        $currLinkText = getXMLData("linktext",getFile($path . $currpage));
        if(length($currLinkText) eq 0)
        {
          $currLinkText = $currpage;
        }
        $nav .= $indent . "<a href=\"" . $UPDATE_PAGE . "\?fname=" . $path . $listitem . "\">" . $currLinkText . "</a><br \/>\n";
      }
    }
    $output .= "<br \/>";
  }
  close NAV;
  return $nav;
}
######################################
#END EDITING - LIST DISPLAY FUNCTIONS#
######################################
1;  #must always return 1.
