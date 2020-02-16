
function urlencode(string)
{
  try
  {
    var arr = string.split("/");
    var returnstring = arr.join("%2F")
    return(returnstring);
  }
  
  catch(e)
  {
    return(e.message);
  }
}

//MAIN HEADINGS:
//matching url should be linktext only. match with subnav to determine which subnav to open
function getNav(owner,url,subnav)
{
  try
  {
    var returnval = "";
    //loop over owner array:
    if(nav[owner])
    {
      for(var a = 0; a < nav[owner].length; a++)
      {
        if(nav[owner][a].page.url == url)
        {
          returnval += "<u>" + nav[owner][a].page.linktext + "</u><br>\n";
        }
          
        else
        {
          returnval += "<a href='" + nav[owner][a].page.url + "'>" + nav[owner][a].page.linktext + "</a><br>\n";
        }
      }
    }

    
    return(returnval);
    }
    catch(e)
    {
      return("error: "+e.message);
    }
}

//HOMEPAGE NAVS:
//<div class="homepagethumbs"><div class="thumbheader">Indi</div><a href="indi/indi.htm"><img src="../images/indi.jpg" width="90" height="90" border="0"></a></div>
function getHomepageNav()
{
  try
  {
    var str       = "";
    var strStart  = "<div class=\"homepagethumbs\"><div class=\"thumbheader\">";
    var strEnd    = " width=\"90\" height=\"90\" border=\"0\"></a></div>\n";
    
    for(var a = 0; a < homenav.length; a++)
    {
      str += strStart + homenav[a].linktext + "</div><a href=\"" + homenav[a].url + "\"><img src=\"" + homenav[a].image + "\"" + strEnd; 
    }
    return(str);
  }
  
  catch(e)
  {
    return("");
  }
}

//LEVEL 2 PAGES BY SECTION:
function getprimarynav(owner,flag)
{
  try
  {
    //capitalise owner:
    var name = owner.substring(0,1).toUpperCase() + owner.substring(1,owner.length);

    var returnval = "<div class='contentnav'>";
    
   
    //returnval += "<br><a href='/" + owner + "/" + owner + ".htm' title='" + name + "&#39;s Home'>" + name + "&#39;s&nbsp;Homepage</a><p >";

    for(var a = 0; a < primarynav.length; a++)
    {
      if(primarynav[a].linktext.toLowerCase() != owner)
      {
        returnval += "<div class='thumbnav'>" + primarynav[a].linktext + "<\/div><a href='" + primarynav[a].url + "'><img src='" + primarynav[a].image + "'><\/a>";
      }
    }
        
    //add the contact link:
    returnval += "<div class='footer2'>&copy;TheCoven&nbsp;2004<br><a href='mailto:webmaster@thecoven.co.uk' class='navlink'>Webmaster@thecoven.co.uk</a><\/div><br>";
    
    //end the containing div:
    returnval += "<\/div>";
    
    return(returnval);
  }
  
  catch(e)
  {
    alert(e);
  }
}
