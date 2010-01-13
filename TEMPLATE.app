<?php
// ---------------------------------------------------------------
// $Id: TEMPLATE.app,v 1.1 2010-01-13 10:47:16 eric Exp $
// $Source: /home/cvsroot/anakeen/addons/template/TEMPLATE.app,v $


$app_desc = array (
		   "name"	 =>"TEMPLATE",		//Name
		   "short_name"	=>N_("Template name"),    	//Short name
		   "description"=>N_("Template description"),  //long description
		   "access_free"=>"N",			//Access free ? (Y,N)
		   "icon"	=>"template.png",	//Icon
		   "displayable"=>"Y",			//Should be displayed on an app list (Y,N)
		   "with_frame"	=>"Y",			//Use multiframe ? (Y,N)
		   "childof"	=>""		        // instance of other application
		   );

/* Example for construct application acl 
$app_acl = array (
  array(
   "name"               =>"TEMPLATE_ACLONE",
   "description"        =>N_("Access to ticket sales"))
);
*/

/* Example for describe action
$action_desc = array (
  array( 
   "name"		=>"TEMPLATE_TICKETSALES",
   "short_name"		=>N_("sum of sales"),
   "acl"		=>"TEMPLATE_ACLONE"),
  array( 
   "name"		=>"TEMPLATE_TEXTTICKETSALES",
   "short_name"		=>N_("text sum of sales"),
   "script"             =>"zoo_ticketsales.php",
   "function"           =>"zoo_ticketsales",
   "acl"		=>"TEMPLATE_ACLONE")
)
*/
		
?>
