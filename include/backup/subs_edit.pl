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
      }
    }
  }

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
