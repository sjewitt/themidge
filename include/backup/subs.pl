######################################
#CUSTOM FUNCTIONS#####################
######################################
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

sub getWAPNav
{
  my $section = $_[0];
  my $result = "";
  my @pages = getNavData($section,"index");
  for($counter=0;$counter<scalar(@pages);$counter++)
  {
    $result .= "[<a href=\"" . $pages[$counter]{url} . "\">" . $pages[$counter]{linktext} . "</a>]";
  }
  return $result;
}

sub getWAPFolderNav
{
  my $currsection = getPath($ENV{"SCRIPT_NAME"});
  my $self        = $ENV{"SCRIPT_NAME"};
  my $currdefault = getXMLData("defaultpage",getFile($currsection . "/defaults.cfg"));
  my $result = "Sections:<br />";
  for(my $a=1;$a<scalar(@SITE_SECTIONS);$a++)
  {
    if($currsection eq $SITE_SECTIONS[$a]{path})
    {
      if(getPureFileName($self) eq $currdefault || $self eq "/index.pl")
      {
        $result .= "[<b>" . $SITE_SECTIONS[$a]{linktext} . "</b>]";
      }
      
      else
      {
        $result .= "[<a href=\"/" . $SITE_SECTIONS[$a]{path} . "\" title=\"" . $SITE_SECTIONS[$a]{linktext} . "\"><b>" . $SITE_SECTIONS[$a]{linktext} . "</b></a>]";
      }
    }
    
    else
    {        
      $result .= "[<a href=\"/" . $SITE_SECTIONS[$a]{path} . "\" title=\"" . $SITE_SECTIONS[$a]{linktext} . "\">" . $SITE_SECTIONS[$a]{linktext} . "</a>]";
    }
  }
  return $result;
}

######################################
#END CUSTOM FUNCTIONS#################
######################################


1;  #must always return 1.
