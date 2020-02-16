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

1;  #must always return 1.
