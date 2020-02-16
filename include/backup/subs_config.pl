##############################
#CONFIGURATION################
##############################

#Site base URL for redirects when not logged in:
##############################
# THIS MUST BE CHANGED TO    #
# MATCH THE UPLOADED SITE    #
# BASE URL!!                 #
##############################
$SITE_BASE_URL = "http://laptop3/";

#array of XML tags to render. 
#These must match the XML data file:
#############################################################
#The edit forms have the same core element names. The render#
#function loops over this when performing the placeholder   #
#replacement.                                               #
#############################################################
@TAGS_TO_RENDER =
(
  {placeholder=>'{CMS_PAGETITLE}',  tag=>'pagetitle',   createeditlink=>false, bitmask=>1},   #COMMON TO ALL FILES
  {placeholder=>'{CMS_KEYWORDS}',   tag=>'keywords',    createeditlink=>false, bitmask=>1},   #COMMON TO ALL FILES
  {placeholder=>'{CMS_AUTHOR}',     tag=>'author',      createeditlink=>false, bitmask=>1},   #COMMON TO ALL FILES
  {placeholder=>'{CMS_DESCRIPTION}',tag=>'description', createeditlink=>false, bitmask=>1},   #COMMON TO ALL FILES
  {placeholder=>'{CMS_OWNER}',      tag=>'owner',       createeditlink=>false, bitmask=>1},   #COMMON TO ALL FILES
  
  {placeholder=>'{CMS_CONTENT1}',   tag=>'content1',    createeditlink=>true, bitmask=>32},   #BITMASKS BEGIN AFTER GLOBAL RIGHTS
  {placeholder=>'{CMS_CONTENT2}',   tag=>'content2',    createeditlink=>true, bitmask=>64},   #BITMASKS BEGIN AFTER GLOBAL RIGHTS
  {placeholder=>'{CMS_CONTENT3}',   tag=>'content3',    createeditlink=>true, bitmask=>128},  #BITMASKS BEGIN AFTER GLOBAL RIGHTS
  {placeholder=>'{CMS_CONTENT4}',   tag=>'content4',    createeditlink=>true, bitmask=>256}   #BITMASKS BEGIN AFTER GLOBAL RIGHTS
  #{placeholder=>'{CMS_CONTENT5}',   tag=>'content5',    createeditlink=>true, bitmask=>512}, #BITMASKS BEGIN AFTER GLOBAL RIGHTS
  #{placeholder=>'{CMS_CONTENT6}',   tag=>'content6',    createeditlink=>true, bitmask=>1024},#BITMASKS BEGIN AFTER GLOBAL RIGHTS
  #{placeholder=>'{CMS_CONTENT7}',   tag=>'content7',    createeditlink=>true, bitmask=>2048} #BITMASKS BEGIN AFTER GLOBAL RIGHTS
);

#array of second level directories, for use in nav generation.
#These must map to directories on the webserver filesystem:
#############################################################
#This array is used to generate both the second level nav   #
#and the create form path-selection radio buttons.          #
#############################################################
@SITE_SECTIONS = 
(
  {path=>'', linktext=>'Home'},  #not used for this site...
  {path=>'chicken', linktext=>'Chicken'},  #not used for this site...
  {path=>'cocktails', linktext=>'Cocktails'},  #not used for this site...
  {path=>'desserts', linktext=>'Desserts'},  #not used for this site...
  {path=>'fish', linktext=>'Fish'},  #not used for this site...
  {path=>'meat', linktext=>'Meat'},  #not used for this site...
  {path=>'vegetables', linktext=>'Vegetables'},  #not used for this site...
);

#Global editing rights:
$RIGHTS_ADMIN   = 1;
$RIGHTS_VIEW    = 2;
$RIGHTS_EDIT    = 4;    #use this to determine whether a user can edit at all. NOT YET IMPLEMENTED
$RIGHTS_CREATE  = 8;
$RIGHTS_DELETE  = 16;

#array of user hashes. Each hash contains username, user full name
#and password. The login page uses this array to check that the 
#login attempt is valid:
@USERS =
(
  {user=>'demo',  password=>'demo',     fullname=>'Demo User',      email=>'demo@mije.co.uk',   rights=>452},
  {user=>'clare', password=>'clareix',  fullname=>'Clare Midgley',  email=>'clare@mije.co.uk',  rights=>1},
  {user=>'silas', password=>'h154lon',  fullname=>'Silas Jewitt',   email=>'silas@mije.co.uk',  rights=>1},
  {user=>'test',  password=>'test',     fullname=>'Test User',      email=>'test@mije.co.uk',   rights=>2}
);

1;  #must always return 1.
