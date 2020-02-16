#!/usr/bin/perl
print "Content-type: text/html\r\n\r\n";
$document_root = $ENV{'DOCUMENT_ROOT'};
$incfile1 = $document_root . "include/subs.pl";
$incfile2 = $document_root . "include/subs_file.pl";
$incfile3 = $document_root . "include/subs_xml.pl";
$incfile4 = $document_root . "include/subs_string.pl";
$incfile5 = $document_root . "include/subs_render.pl";
$incfile6 = $document_root . "include/subs_config.pl";

require $incfile1;
require $incfile2;
require $incfile3;
require $incfile4;
require $incfile5;
require $incfile6;

$searchoutput   = "";
@currfolder;
$currfile       = "";
$currtagcontent = "";
$currsummary    = "";

$qt = getRequest("qt");
#force lower case:
$qt  =~ tr /A-Z/a-z/;  #'tr'anslate.


$PATH_PREFIX = "/";
$HIT_ON_CURRENT_PAGE = false;
if(length($qt) > 0)
{
  #print scalar(@SITE_SECTIONS) . "<br>";
  for(my $a=0;$a<scalar(@SITE_SECTIONS);$a++)
  {
    $PATH_PREFIX = "/";
    if(length($SITE_SECTIONS[$a]{path}) eq 0)
    {
      $PATH_PREFIX = "";
    }
  
    @currfolder = getFolderContent($SITE_SECTIONS[$a]{path},"xml");
    for(my $b=0;$b<scalar(@currfolder);$b++)
    {
      $HIT_ON_CURRENT_PAGE = false;
      #to generate my search index file, I need to get only the content 
      $currfile = getFile($SITE_SECTIONS[$a]{path} . "/" . $currfolder[$b]);
      #iterate over the config array of content tags:
      for(my $c = 0; $c < scalar(@TAGS_TO_RENDER); $c++)
      {
        #test for presence of tag:
        if(checkForTag($TAGS_TO_RENDER[$c]{tag},$currfile) eq true)
        {
          $currtagcontent = getXMLData($TAGS_TO_RENDER[$c]{tag},$currfile);
          $currtagcontent =~ s/<(.*?)>//gi;	    # remove anything that starts with "<" and ends with ">"
          #force to lower case. funky regexp stuff again...
          $currtagcontent =~ tr /A-Z/a-z/;  #'tr'anslate.
          
          
          #check for presence of tag (put in subs_xml eventually as regexp test):
          #i need to check this if there are more tags defined in subs_config
          #than are used in majority of files - if there is for example a different layout
          #used for some pages. 
          #test for search term:
          if(index($currtagcontent,$qt) > -1)
          {
            print "<!-- HIT IN TAG  $TAGS_TO_RENDER[$c]{tag}-->\n";
            print "<!-- ".$currtagcontent."-->\n";
            $currsummary = substr($currtagcontent,index($currtagcontent,$qt),index($currtagcontent,$qt)+100);
            #$currsummary = $currtagcontent;
            print "<!-- $currsummary -->\n";
            $HIT_ON_CURRENT_PAGE = true; 
          }
        }
      }
      if($HIT_ON_CURRENT_PAGE eq true)
      {
        $searchoutput .= "<a href=\"/" . $SITE_SECTIONS[$a]{path} . $PATH_PREFIX . getPureFileName($currfolder[$b]) . ".pl\">" . getXMLData("linktext",$currfile) . "</a><br>\n";
        $searchoutput .= "&nbsp;...".$currsummary."...<br>";
      }
    } 
  } 
  if(length($searchoutput) eq 0)
  {
    $searchoutput = "No results found.";
  }
}

else
{
  $searchoutput = "No searchterm.";
}
print getPage("", "search",$searchoutput);

