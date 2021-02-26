<?php
	
        error_reporting(0);	
	include("connect.php");
	include("cook.php");
	session_start();
	
	if( $_COOKIE[$cook] == "Be_Honest_with_Yourself" )		
		echo '<script type="text/javascript">			window.location.href="home.php";		</script>';
		
		
		
	$fname=$_POST["name"];
	$title=$_POST["title"];
	$usr=$_POST["usr"];
	$pass1=$_POST["pass1"];
	$pass2=$_POST["pass2"];
	$em=$_POST["email"];
	$inst = $_POST["institute"];
	$num=$_POST["numb"];
	$gender=$_POST["gender"];
	$time= "0:0:0";

	$name= $fname." ".$title; 

	if($name!=NULL && $title!=NULL && $usr!=NULL && $pass1!=NULL && $num!=NULL && $em!=NULL && $pass1==$pass2)		{

		$sql = 'SELECT * FROM `login` WHERE `Username`="'.$usr.'"';
		$data = mysql_query($sql);
		$info = mysql_fetch_array( $data );
	
		if( $info['Password']!="" )
			$_SESSION['status']="<br>USERNAME already taken.";
			
		else if( !ctype_alnum($usr) || !ctype_alnum($pass1) )	
			$_SESSION['status']="<br>USERNAME/PASSWORD not valid.<br/>NO SPECIAL CHARACTERS ALLOWED";
			
		else	{
		
		$sql = 'INSERT INTO login (Name,Username,Password,Gender,EMailID,Institute,Number,Time,NOL,VL) VALUES ("'.$name.'","'.$usr.'","'.$pass1.'","'.$gender.'","'.$em.'","'.$inst.'","'.$num.'","'.$time.'","0","0"); ';
		mysql_query($sql);
		
		$sql = 'INSERT INTO users (Username,Questions,Total) VALUES ("'.$usr.'","0","0"); ';
		mysql_query($sql);

		$_SESSION['status']='<br>Registration Successful!!!<br/><a href="redrct.php"><b>Go Home!</b></a>';
		
		}//End Of Else

	}// End Of If
	
	else if( ($name==NULL || $title==NULL || $usr==NULL || $pass1==NULL || $pass2==NULL || $num==NULL || $em==NULL) && $gender!=NULL && $inst!=NULL)
		$_SESSION['status']="<br>ALL FIELDS ARE COMPULSORY!!!";
		
	else if ( $gender!=NULL )
		$_SESSION['status']="<br>PASSWORDS DIDN'T MATCH!!!";

	
	
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<!-- -----All the Display Settings are According to Firefox Web Browser----- -->
<head oncontextmenu="return false">

	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />

	<link rel="stylesheet" type="text/css" href="CSS/reset.css" />
	<title>Quick Registration</title>
	<link rel="stylesheet" type="text/css" href="CSS/qckreg.css" />
	
</head>

<body oncontextmenu="return false">

	<div class="lnk">	<a href="redrct.php"><b>Home</b></a>	</div>
		
	<div class="frm">
	
	<div>

	<form method="post" action="qckreg.php">
	<table border="0">
	
	<tr>
	<td>First Name: </td> 	<td><input name="name" type="text" id="wdth1"></td>
	</tr>

	<tr>
	<td>Last Name: </td>		<td><input name="title" type="text" id="wdth1"></td>
	</tr>

	<tr>
	<td>Username: </td>		<td><input name="usr" type="text" id="wdth1"></td>
	</tr>

	<tr>
	<td>Password: </td>		<td><input name="pass1" type="password" id="wdth1"></td>
	</tr>

	<tr>
	<td>Confirm Password:</td>		<td><input name="pass2" type="password" id="wdth1"></td>
	</tr>
	
	<tr>
	<td>Email ID:</td>		<td><input name="email" type="text" id="wdth1"></td>
	</tr>
	
	<tr>
	<td>Institution:</td>		<td><input name="institute" type="text" id="wdth1"></td>
	</tr>
	
	<tr>
	<td>Mobile No.:</td>		<td><input name="numb" type="number" id="wdth1"></td>
	</tr>
	
	<tr>
	<td> Gender: </td>	
	<td>
	Male
	<input name="gender" type="radio"  value="Male" checked="true">
	Female
	<input name="gender" type="radio"  value="Female">
	</td>
	</tr>
	
	<tr>	<td></td>	<td><input type="submit" value="Submit" id="pad"></td>	</tr>

	</table>
	</form>

	</div>
	
		<div class="rslt">
		
			<h1><?php echo $_SESSION['status']; ?></h1>
		
		</div>
	
	</div>
	
</body>
</html>
