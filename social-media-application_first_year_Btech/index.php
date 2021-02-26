<?php
setcookie("users","welcome");
?>

<html>
<head>
<title>Shubham Bansal@Lnmiit </title>
<link rel="stylesheet" href="css/style.css"/>
<script type="text/javascript" scr="index.php" language="javascript">

function startTime()
{
var today=new Date();
var h=today.getHours();
var m=today.getMinutes();
var s=today.getSeconds();
// add a zero in front of numbers<10
m=checkTime(m);
s=checkTime(s);
document.getElementById('txt').innerHTML=h+":"+m+":"+s;
t=setTimeout('startTime()',500);
}

function checkTime(i)
{
if (i<10)
  {
  i="0" + i;
  }
return i;
}

function enter()
{
window.location.href="resume.html" ;
window.close();
}
</script>
</head>
<body onload="javascript:startTime()">

<img src="skull.gif" style="margin:0 ; position:absolute ; top:100 ; left:900"/>
<h1 style="margin:0 ;position:absolute;top:100 ;left:100 ; color:blue" id="txt"></h1>

<form style=" margin:0 ; position:absolute; top:20px ; left:700px; z-index:100" action="index.php" method="post">
<table border="2">
<td>
User:&nbsp<input type="text" name="user"/></td>
<td> Password:&nbsp &nbsp<input type="password" name="pass"/></td> 
</table>
<input type="submit" value="Login" style="position:absolute; top:10px ; left:450px"/>
</form>


<img style="margin:0 ; position:absolute; top:10px; left:70px ; height:50px; width:125px; z-index:100" src="logo.gif"/>

<img style="margin:0 ; position:absolute; top:85px; left:520px; width:300px ; height:500px" src="design0.jpg" />
<img style="margin:0 ; position:absolute; TOP:110px; LEFT:570px; WIDTH:200px; HEIGHT:200px" SRC="image0.gif"/>
<img style="margin:0 ; position:absolute; top:0px; left:0px ; height:75px; width:1365px ; z-index:10" src="line.jpg"/>
<div style="margin:0 ; position:absolute; top:300px; left:550px ">
<h1>Shubham Bansal</h1>
<h2 class="bansal">lnmiit</h2>
<p class="bansal" style="font-size:24px font-style:bold">Btech-Ist year</p>
<hr>

<input type="button"  value="About Me" onClick="javascript:enter()" style="margin:0 ; position:absolute ; top:200 ; left:80"/>

</div>
<a href="registration.php" style="margin:0 ; position:absolute; top:125px; left:965px; z-index:10">New user registration</a>
<a href="reset.php" style="margin:0 ; position:absolute; top:170px; left:965px; z-index:10">Reset Password</a>

<?php
error_reporting(0);
$a= $_POST['user'];
$b= $_POST['pass'];
$c = "database/".$a.".txt" ;
$f= fopen($c,"r");
$r = fgets($f);
fclose($f);


if ($r == $b && $b != NULL) 
{
$login = 1 ;
$g= fopen("tmp.txt","w");
fwrite($g,"$a");
fclose($g);

$l = fopen("tmp.txt","r");
$rr = fgets($l);
fclose($l);
if( $_COOKIE['users'] == "welcome")
{
setcookie("users",$rr);
}
}

if ($r != $b)
$login = 0; 
?>

<script type="text/javascript">
var usr =  "<?php echo $a ?>";
var log = "<?php echo $login ?>";

if(usr != "" && log == 1)
{
window.location.href= "home.php?usr="+usr; 
}
</script>

</body>
</html>
