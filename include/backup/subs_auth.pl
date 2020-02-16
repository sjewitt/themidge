######################################
#AUTHORISATION FUNCTIONS##############
######################################
#check that the current session is authorised:
#I may change this later on...
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
    #logger($cookie);
    if ($cookie eq "authorised=yes")
    {
      $auth = true;
    }
  }
  return $auth;
}

#get the value of supplied cookie name:
sub getCookie
{
  my $cookie_name = $_[0];
  my $cookiestring = $ENV{'HTTP_COOKIE'};    #get all the cookies
  my @cookies = split(/;/, $cookiestring);   #get an array of cookies
  my $result = false;
  foreach $cookie (@cookies)
  {
    if (index($cookie,$cookie_name . "=") >= 0)
    {
      $result = substr($cookie,index($cookie,"=")+1,length($cookie));
    }
  }
  return($result);
}

#use this to determine whether the edit/delete etc links appear for the given user:
sub getUserProperty
{
  my $user      = getCookie("user");
  my $property  = $_[0];  #the user property to retrieve
  my $returnval = "";
  
  for(my $counter=0;$counter<scalar(@USERS);$counter++)
  {  
    if($user eq $USERS[$counter]{'user'})
    {
      $returnval = $USERS[$counter]{$property};
    }
  }
  return $returnval;
}

sub getUserAuth
{
  my $returnval = false;
  my $RIGHT_TO_CHECK = $_[0];   #passed right to check (as a constant - see subs_config).
  my $res = $RIGHT_TO_CHECK & getUserProperty("rights"); #binary comparison:

  if($res > 0)
  {
    $returnval = true;
  }
  return $returnval;
}

#check for an authorised login attempt:
sub authenticate
{
  my $user      = $_[0];
  my $password  = $_[1];
  my $result    = false;
  
  for(my $a = 0; $a < scalar(@USERS); $a++)
  {
    if(($user eq $USERS[$a]{'user'}) && ($password eq $USERS[$a]{'password'}))
    {
      $result = true;
    }
  }
  return $result;
}

######################################
#END AUTHORISATION FUNCTIONS##########
######################################

1;  #must always return 1.
