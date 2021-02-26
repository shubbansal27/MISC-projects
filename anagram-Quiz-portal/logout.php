<?php
error_reporting(0);

include("connect.php");
include("cook.php");

session_start();
$_SESSION['status']="";
session_destroy();

/*$q1 = "delete from onlineuser where user ='" . $_COOKIE[username] . "'";
if(!$q1) 
{
die('Could not connect: ' . mysql_error());
}
mysql_query($q1,$connect);
*/

setcookie($cook, "byebye");
setcookie("username","byebye");
echo '<script type="text/javascript">			window.location.href="index.php";		</script>';

?>
