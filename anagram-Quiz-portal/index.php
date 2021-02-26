<?php
	error_reporting(0);
	
	include("cook.php");
	include("allow.php");
	session_start();
	
	if( $_COOKIE[$cook] == "Be_Honest_with_Yourself" )		
		echo '<script type="text/javascript">			window.location.href="home.php";		</script>';
	
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<!-- -----All the Display Settings are According to Firefox Web Browser----- -->
<head oncontextmenu="return false">

	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	
	<link rel="stylesheet" type="text/css" href="CSS/reset.css" />
	
	<title>Login</title>
		
	<link rel="stylesheet" type="text/css" href="CSS/index.css" />
	
</head>

<body oncontextmenu="return false">

<div class = "notify"><marquee><i>Registrations now open.......</i></marquee></div>

<div class= "info"><h1><center></center></h1></div>

<div  class="frm">

	<div>

		

		<div>
		
		<form method="post" action="login.php">	
		<table border="0">
		
		<tr>
		<td>Username:</td> 		<td><input type="text" name="username" id="wdth1"></td>
		</tr>
		
		<tr>
		<td>Password:</td>		<td><input type="password" name="pass" id="wdth1"></td>
		</tr>
		
		<tr>
		<td></td><td><input type="submit" value="Submit!" id="wdth2"></td>
		</tr>
		
		</table>
		</form>
		
		</div>

		<div class="rslt">
		
		<h1><?php echo $_SESSION['status']; ?></h1>
		
		</div>
	
	</div>
	
	<div class="reg_img"><a href="rdrct.php" id="wdth2"><img src="Images/Button.png"></a></div>
	
	<div class="rules">

		<a href="rules.html"><b><font color="black">EVENT RULES</font></b></a>
	</div>
	
</div>

</body>
</html>
