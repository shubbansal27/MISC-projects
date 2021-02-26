<?php
error_reporting(0);

include("connect.php");
include("cook.php");
include("allow.php");

session_start();
$name= $_POST["username"];
$pass= $_POST["pass"];
	
if( $name!=NULL && $pass!=NULL && $name!=" " && $pass!=" " && $allow == 1)			
{

$sql = 'SELECT * FROM `login` WHERE `Username`="'.$name.'"';
$data = mysql_query($sql);
$info = mysql_fetch_array( $data );

	if( $pass == $info['Password'] && $NOL<5 )	{
	
			setcookie($cook, "Be_Honest_with_Yourself");
			setcookie("username",$name);

			$_SESSION['usr']=$name;
			$_SESSION['start']=$info['Time'];
			
			$NOL++;
			$sql= 'UPDATE `login` SET `NOL`="'.$NOL.'" WHERE `Username`="'.$name.'"';
			mysql_query($sql);
			
			$sql= 'UPDATE `login` SET `VL`="1" WHERE `Username`="'.$name.'"';
			mysql_query($sql);
			
			echo '<script type="text/javascript">			window.location.href="home.php";		</script>';
			
	}

	else if( $NOL >=5 )		{
	
	$_SESSION['status']="<br/>Login Limit Exceeded!!!";
	echo '<script type="text/javascript">			window.location.href="index.php";		</script>';
	
	}
	
	else	{
	
		$_SESSION['status']="<br/>Wrong Username/Password!!!";
		echo '<script type="text/javascript">			window.location.href="index.php";		</script>';
	}


}//End Of Main If	


else	{

	$_SESSION['status']="<br/>All Fields Are Compulsory!!!";
	echo '<script type="text/javascript">			window.location.href="index.php";		</script>';
}

?>
