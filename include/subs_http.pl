######################################
#URL/HTTP MANIPULATION FUNCTIONS######
######################################
#test for WML:
sub isWml
{
  my $value = false;
  if(index($ENV{HTTP_ACCEPT},"text/vnd.wap.wml") > 0)
  {
    $value = true;
  }
  #logger("IS A WAP PHONE: $value");
  return $value;
}

#get value of passed request parameter:
sub getRequest
{
  #print($ENV{REQUEST_METHOD});
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

1;  #must always return 1.
