##############################
#PAGE RENDERING###############
##############################

#begin here:
#get the components of each page and assemble them:
sub getPage
{
  my $path = $_[0];
  my $file = $_[1];
  
  #vars holding default values:
  my $default_page;
  my $default_section = ""; #root
  
  #output:
  my $output = "";
  
  #get layout template file:
  my $layout = getFile("template/layout.tmpl");
  
  #get XML data file:
  my $data = getFile($path . "/" . $file . ".xml");
  
  #now check for a 'defaults.cfg' in the current directory:    
  #if a defaults.cfg exists, use values stored here
  #rather than stored as global defaults - ie initialised
  #when a new page is created:
  my $default_page;
  if(fileExists($path . "defaults.cfg"))
  {
    $default_data       = getFile($path . "defaults.cfg");
    $default_page       = getXMLData("defaultpage",$default_data);
    $default_section    = getXMLData("currentdirectory",$default_data);
  }
  else
  {
    #get defaults from the page:
    $default_page = getXMLData("defaultpage",$data);
  }
  
  my $topnav = getTopNav($default_section,$default_page);
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
  my $lhnav = format_nav_right(nav($path,$default_page));
  
  #get editlink if session cookie is set:
  my $editlink = "";

  #GENERATE AN Editlink if logged in:
  if(getAuth() eq true)
  {
    $editlink = "<table width=\"100%\" cellpadding=\"3\"><tr><td style=\"border:1px #ff0000 solid;\">";
    $editlink .= "<p><a href=\"#\" onClick=\"editPage('/edit/editor_editfile.pl?fname=".$path."/".$file.".xml')\"><b>Edit</b></a> this page. ";
    $editlink .= "<a href=\"#\" onClick=\"editPage('/edit/editor_newfile2.pl')\"><b>Create</b></a> new page. ";
    
    #we don't want to delete the default page, otherwise going to directory will throw a 404 error.
    if(getPureFileName($ENV{"SCRIPT_NAME"}) ne $default_page)
    {
      $editlink .= "<a onclick=\"javascript:return(confirm('Really delete this page?'));\" href=\"/edit/editor_deletefile.pl?page=" . substr($ENV{"SCRIPT_NAME"},0,index($ENV{"SCRIPT_NAME"},".")) . "\"><b>Delete</b></a> this page. ";
    }
    $editlink .= "[<a href=\"/logout.pl?return=" . $ENV{"SCRIPT_NAME"} . "\">Logout</a>]</b></p>";
    $editlink .= "</td></tr></table>";
  }
  
  #replace CMS placeholders in layout template:
  $layout     = replace($layout,"{CMS_PAGETITLE}",    getXMLData("heading",$data));
  $layout     = replace($layout,"{CMS_KEYWORDS}",     getXMLData("keywords",$data));
  $layout     = replace($layout,"{CMS_AUTHOR}",       getXMLData("author",$data));
  $layout     = replace($layout,"{CMS_DESCRIPTION}",  getXMLData("description",$data));
  $layout     = replace($layout,"{CMS_CONTENT}",      replaceNewline(getXMLData("body",$data))); #DYNAMICALLY REPLACE NEWLINE!!!!
  
  #replace the nav:
  #$layout     = replace($layout,"{CMS_TOPNAV}",       nav_top($topnav));
  $layout     = replace($layout,"{CMS_HOMELINK}",     $homelink);
  $layout     = replace($layout,"{CMS_LHNAV}",        $lhnav);
  $layout     = replace($layout,"{CMS_TOPNAV}",       $topnav);
  
  #replace the edit link:
  $layout     = replace($layout,"{CMS_EDITLINK}",     $editlink);
  
  #return processed string:
  $output .= $layout;
  return $output;
}
##############################
#END PAGE RENDERING###########
##############################


####################################
#GENERIC FILE MANIPULATION FUNCTIONS
####################################

#get file contents. Accepts relative path/filename as a parameter.
#calls getRoot() to determine filesystem path:
sub getFile
{
  my $path            = $_[0];    #relative path to file
  my $root            = getRoot();
  my $fullpath        = $root . $path;
  my $filecontents    = "";
  
  open FILE, $fullpath;
  while( <FILE> )  #this syntax gets the input line.
  {
    $filecontents .= $_ ;
  }
  close FILE;
  return $filecontents;
}

#determine the filesystem root:
sub getRoot
{
  my $document_root = $ENV{'DOCUMENT_ROOT'};
  if(length($document_root) == 0) #if WIN
  {
    $document_root = "C:\/DEV\/webtest\/";  #this is local dev path.
  }
  return $document_root;
}

#checks for existance of passed path/file.
#calls getRoot() to determine filesystem path:
sub fileExists
{
  my $path            = $_[0];    #relative path to file
  my $root            = getRoot();
  my $fullpath        = $root . $path;
  if(-e $fullpath)
  {
    return 1;
  }
  else
  {
    return 0;
  }
}

#file utility: Get file name without extension or path:
sub getPureFileName
{
  my $src = $_[0];
  my @path_no_extension = split(/\./,$src);
  my @path_sections = split(/\//,@path_no_extension[0]);
  
  #funky length syntax - a scalar cannot hold an array, so it determines length instead:
  $length = @path_sections;
  
  #now we want the last element of the array:
  return @path_sections[$length - 1];
}

########################################
#END GENERIC FILE MANIPULATION FUNCTIONS
########################################

######################################
#XML DATA MANIPULATION FUNCTIONS######
######################################
#get the data between passed XML tags:
sub getXMLData
{
  my $tag         = $_[0];    #tag from which to get data
  my $str         = $_[1];    #The XML file contents
  my $startTag    = "<" . $tag . ">";
  my $endTag      = "</" . $tag . ">";
  my $output      = substr($str,index($str,$startTag) + length($startTag));
  $output         = substr($output,0,index($output,$endTag));
  return $output;
}

#write the data between passed XML tags:
sub setXMLData
{
  my $tag         = $_[0];    #tag to which to write data
  my $str         = $_[1];    #The XML file contents
  my $new         = $_[2];    #The new data to write
  my $startTag    = "<" . $tag . ">";
  my $endTag      = "</" . $tag . ">";
  my $output_start= substr($str,0,index($str,$startTag) + length($startTag));   #because of bracket
  my $output_end  = substr($str,index($str,$endTag),length($str));
  #build return string:
  $output = $output_start . $new . $output_end;
  return $output;
}
######################################
#END XML DATA MANIPULATION FUNCTIONS##
######################################

######################################
#NAVIGATION FUNCTIONS#################
######################################

#accepts a datatable structure of:
# LINKTEXT,URL,LINK_OR_LINKTEXT
sub format_nav_right
{
  my $navitems  = $_[0];
  my $output    = "";
  my @rows      = split(/\r\n/,$navitems); #get the row of nav parameters:
  
  foreach $row(@rows) #get the individual parameters and format them:
  {
    #get the items in the row:
    ($linktext,$url,$islink) = split(/\t/,$row);
    $output .= "<table cellspacing=\"0\" cellpadding=\"0\" border=\"0\">";
    if($islink eq "LINK")
    {
      $output .= "<tr><td class=\"off\"><a href=\"" . $url . "\">" . $linktext . "</a></td></tr>";
    }
    else
    {
      $output .= "<tr><td class=\"on\">" . $linktext . "</td></tr>";
    }
  }
  $output .= "</table>";
  return $output;
}

#get the .xml files as these will have been generated by
#the edit creation as well as the corresponding .pl files:
#returns a generic datatable structure of form:
# LINKTEXT,URL,LINK_OR_LINKTEXT
sub nav
{
  $path       = $_[0];    #nav root
  $default    = $_[1];    #directory default page - ie current 'home' - WITHOUT extension
  
  my $root = getRoot();
  my $currpage;
  my $FILES_TO_INCLUDE = ".xml";   #regexp? or array?
  opendir NAV, $root . $path;

  my $navItem = "";
  my $leading = "";
  my $atRoot = true;
  if(length($path) > 0)
  {
    #if we are NOT at root, add a leading slash:
    $atRoot = false;
    $leading = "/";
  }
  #get self:
  my $self = $ENV{"SCRIPT_NAME"};
  
  #an array:
  my @contents = readdir NAV;
  my $currLinkText;
  my $comparator;

  foreach $listitem ( @contents )
  {
    #check for double // if path is zero-length:
    $currpage = $leading . $listitem;  #listitem is the current item in the folder. NO slashes
    #check whether its a file or a directory, ignore directories:
    if ( -d $listitem ) {}  
    else
    {
      #check the current file is of correct type and NOT the default directory page:
      if
      (
        (substr($currpage,(index($currpage,".")),length($currpage)) eq $FILES_TO_INCLUDE)
        && 
        !($listitem eq $default . $FILES_TO_INCLUDE)
        )
      {
        #get the current page linktext:
        $currLinkText = getXMLData("linktext",getFile($path . "/" . substr($listitem,0,index($listitem,".")) . ".xml"));
        
        if(length($currLinkText) eq 0)
        {
          $currLinkText = $currpage;
        }
  
        #add linktext to item:
        $navItem .= $currLinkText . "\t";
        $navItem .= substr($listitem,0,index($listitem,".")) . ".pl\t";
  
        if($atRoot eq false)
        {
          $comparator = $path . substr($currpage,1,index($currpage,".")) . "pl";
        }
        else
        {
          $comparator = "/" . $path . substr($currpage,0,index($currpage,".")) . ".pl";
        }

        if($self eq $comparator)
        {
          $navItem .= "SELF\r\n";
        }
        else
        {
          $navItem .= "LINK\r\n";
        }
      }
    }
  }
  close NAV;
  return $navItem;         #a hashmap of nav items
  }

#foldernav for second level (also formats - change later):
sub getTopNav
{
  my $currsection = $_[0];
  my $currdefault = $_[1];
  my $section;
  my $output = "&nbsp;";
  my $root = getRoot();
  my $self = $ENV{"SCRIPT_NAME"};
  my @sections;
  push(@sections,"meat");
  push(@sections,"fish");
  push(@sections,"vegetables");
  push(@sections,"chicken");
  push(@sections,"cocktails");
  push(@sections,"desserts");
  
  foreach $section (@sections)
  {
    if($section eq $currsection)
    {
      if(getPureFileName($self) eq $currdefault)
      {
        $output .= "<b>" . $section . "</b>&nbsp;";
      }
      else
      {
        $output .= "<a href=\"/" . $section . "\"><b>" . $section . "</b></a>&nbsp;";
      }
    }
  
    else
    {
      $output .= "<a href=\"/" . $section . "\">" . $section . "</a>&nbsp;";
    }
  }
  return $output;
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

sub getAuth
{
  #check for cookie:
  my $cookiestring = $ENV{'HTTP_COOKIE'};    #get all the cookies
  my @cookies = split(/;/, $cookiestring);   #get an array of cookies
  my $cookie;
  my $auth = false;
  
  #iterate over cookies:
  foreach $cookie (@cookies)
  {
    if ($cookie eq "authorised=yes")
    {
      $auth = true;
    }
    else
    {
      $auth = false;
    }
  }
  return $auth;
}

######################################
#END AUTHORISATION FUNCTIONS##########
######################################


######################################
#STRING MANIPULATION FUNCTIONS########
######################################

#replace globally one substring with another.
#care with '[nn]' as this will define a regexp char class:
sub replace
{
  my $src_string  = $_[0];
  my $src_word    = $_[1];    #actually a regexp string.
  my $target_word = $_[2];
  my $result_string;
  $result_string = $src_string;
  $result_string =~ s/$src_word/$target_word/g;
  return $result_string;
}

#replace newlines with <br> tags:
sub replaceNewline
{
  my $src = $_[0];
  my $result_string = $src;
  $result_string =~ s/[\n\r]/<br \/>/g;
  return $result_string;
}

######################################
#END STRING MANIPULATION FUNCTIONS####
######################################



######################################
#EDITING - LIST DISPLAY FUNCTIONS#####
######################################
#get list of gif/jpg in /images/ folder
#and generate appropriate links for adding
#images:
sub getImagesForInsert
{
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
        $output .= "<td>&nbsp;<a href=\"#\" onClick=\"insertAtCursor(document.newpage.content, '" . $path.$image . "',false)\" title=\"Add image at current cursor location\"><b>+</b></a>&nbsp;</td>"; 
        $output .= "<td>&nbsp;<a href=\"#\" onClick=\"openImagePreview('" . $path.$image . "')\" title=\"Preview image\">view</a>&nbsp;</td>";
      }
    }
  }
  $output .= "</table>";
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

######################################
#EDITING - PAGE EDIT FUNCTIONS########
######################################

#accepts a filename, a relative path, string file contents and an extension.
sub createFile
{
  my $root            = getRoot();
  my $filename        = $_[0];
  my $relativepath    = $_[1];
  my $filecontents    = $_[2];
  my $fileextension   = $_[3];
  my $result          = "";
  my $fullpath        = "";
  
  $result = $root . $relativepath . "/" . $filename;
  $fullpath = $root . $relativepath . "/" . $filename;
  if(!(-e $fullpath))
  {
    open NEWFILE, ">" . $fullpath;
    
    #set execute permissions as it's a .pl file...:
    chmod 0755, $fullpath;
    
    print NEWFILE $filecontents;
    close NEWFILE;
  }
  else
  {
    $result .= "File exists already. Cannot continue."
  }
  return $result;
}


#not quite same as above.
sub updateFile
{
  my $root            = getRoot();
  my $file            = $_[0];
  my $filecontents    = $_[1];
  my $result          = "";
  
  $result = $root . $file;
  $fullpath = $root . $file;
  
  if(-e $fullpath)
  {
    $result .= " Updating file " . $file . "<br>";
    open UPDATEFILE, ">" . $fullpath;
    
    #set execute permissions as it's a .pl file...:
    chmod 0755, $fullpath;
    
    print UPDATEFILE $filecontents;
    close UPDATEFILE;
  }
  return $result;
}

######################################
#END EDITING - EDIT PAGE FUNCTIONS####
######################################
1;  #must always return 1.
