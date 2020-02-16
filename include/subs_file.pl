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

sub getPath
{
  my $page =$ENV{'SCRIPT_NAME'};
  my $returnval = "/";
  my @pathparts = split(/\//,$page);
  if(scalar(@pathparts) eq 3) #its a subfolder
  {
    $returnval = @pathparts[1];
  }
  return $returnval;
}

#determine the filesystem root:
sub getRoot
{
  my $document_root = $ENV{'DOCUMENT_ROOT'};
  #if(length($document_root) == 0) #if WIN
  #{
  #  $document_root = "C:\/DEV\/webtest\/";  #this is local dev path.
  #}
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

#file utility: Get file name with extension and no path:
sub getPureFileNameWithExtension
{
  my $src = $_[0];
  my @path_sections = split(/\//,$src);
  
  #funky length syntax - a scalar cannot hold an array, so it determines length instead:
  $length = @path_sections;
  
  #now we want the last element of the array:
  return @path_sections[$length - 1];
}

#not quite same as above.
sub updateFile
{
  #print "updating file...<br>";
  
  my $root            = getRoot();
  my $file            = $_[0];
  my $filecontents    = $_[1];
  my $result          = "";
  #print "NEW XML:<xmp>$filecontents</xmp>";
  #$result = $root . $file;
  $result = "";
  $fullpath = $root . $file;
  #print $fullpath;
  if(-e $fullpath)
  {
    #print "path '$fullpath' exists OK<br>";
    $result .= " Updating file " . $fullpath . "<br>";
    open UPDATEFILE, ">" . $fullpath || die("Cannot Open File");
    
    #set execute permissions as it's a .pl file...:
    chmod 0755, $fullpath;
    
    print UPDATEFILE $filecontents;
    close UPDATEFILE;
  }
  return $result;
}

sub logger
{
  my $logstring = $_[0];
  my $root      = getRoot();
  my $file      = "logfile.log";
  
  open (LOGFILE, ">>" .$root . $file || die "Cannot open logfile...");
  print LOGFILE localtime() . "\tFILE:\t$ENV{SCRIPT_NAME}\tMESSAGE: " . $logstring . "\n";
  close LOGFILE;
  
}

########################################
#END GENERIC FILE MANIPULATION FUNCTIONS
########################################

######################################
#EDITING - PAGE CREATE FUNCTIONS######
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
    $result = "File $fullpath successfully created.";
  }
  else
  {
    $result .= "File exists already. Cannot continue."
  }
  return $result;
}

#get folder content
sub getFolderContent
{
  $path         = $_[0];    #nav root
  $extension    = $_[1];    #directory default page - ie current 'home' - WITHOUT extension
  
  my $root = getRoot();
  my $currpage;     #the current page in iteration
  my $currUrl;      #placeholder for item URL
  my $currLinktext; #placeholder for item linktext
  my $currStatus;   #placeholder for whether link or just linktext
  #my $FILES_TO_INCLUDE = ".xml";   #regexp? or array?
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
  
  opendir NAV, $root . $path;
  
  #an array:
  my @contents = readdir NAV;

  #print @contents;
  foreach $listitem(@contents)
  {
    #check for double // if path is zero-length:
    $currpage = $leading . $listitem;  #listitem is the current item in the folder. NO slashes
    
    #check whether its a file or a directory, ignore directories:
    if ( -d $listitem ){}  
    else
    {
      #check the current file is of correct type and NOT the default directory page:
      if((substr($currpage,(index($currpage,".")+1),length($currpage)) eq $extension))
      {
        push(@result,$listitem);
      }
    }
  }
  close NAV;
  return @result;         #an array of nav items
}
1;  #must always return 1.
