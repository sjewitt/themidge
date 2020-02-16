######################################
#XML DATA MANIPULATION FUNCTIONS######
######################################
#get the data between passed XML tags:
sub checkForTag
{
  my $tag         = $_[0];    #tag from which to get data
  my $str         = $_[1];    #The XML file contents
  my $regexp_start = "<" . $tag . ".*?>"; #non-greedy match
  if($str =~ $regexp_start)
  {
    return true;
  }
  else
  {
    return false;
  }
}


sub getXMLData
{
  #logger("in getXMLData()...");
  my $tag         = $_[0];    #tag from which to get data
  my $str         = $_[1];    #The XML file contents
  
  my $regexp_start = "<" . $tag . ".*?>"; #non-greedy match
  
  #check that passed tag actually exists:
  if(checkForTag($tag,$str) eq true)
  {
    $str =~ m/($regexp_start)/i;
    # $1 is the scalar value returned from first bracket above. There is only one here...
  
    my $startTag    = $1;
    my $endTag      = "</" . $tag . ">";
    my $output      = substr($str,index($str,$startTag) + length($startTag));
    $output         = substr($output,0,index($output,$endTag));
    return $output;
  }
  else
  {
    return "";
  }
}
#get the specified tag parameter:
sub getXMLTagParameter
{
  my $tag         = $_[0];    #tag from which to get data
  my $str         = $_[1];    #The XML file contents
  my $attr        = $_[2];    #the tag attribute whose value we want
  my $regexp_start = "<" . $tag . ".*?>"; #non-greedy match
  
  $str =~ m/($regexp_start)/i;
  # $1 is the scalar value returned from first bracket above. There is only one here...
  my $tag    = $1;
  my $output      = substr($tag,index($tag,$attr)+length($attr)+2); #strip everything before the attribute value
  $output         = substr($output,0,index($output,"\""));          #now strip everything after the attribute value
  return $output;
}

#write the data between passed XML tags:
sub setXMLData
{
  #logger("in setXMLData()...");
  my $tag         = $_[0];    #tag to which to write data
  my $str         = $_[1];    #The XML file contents
  my $new         = $_[2];    #The new data to write
  
  my $regexp_start = "<" . $tag . ".*?>"; #non-greedy match
  $str =~ m/($regexp_start)/i;
  # $1 is the scalar value returned from first bracket above. There is only one here...

  my $startTag    = $1;
  my $endTag      = "</" . $tag . ">";
  my $output_start= substr($str,0,index($str,$startTag) + length($startTag));   #because of bracket
  my $output_end  = substr($str,index($str,$endTag),length($str));
  #build return string:
  $output = $output_start . $new . $output_end;
  return $output;
}

sub getEditableTags
{
  
}
######################################
#END XML DATA MANIPULATION FUNCTIONS##
######################################
1;  #must always return 1.
