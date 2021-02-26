<html>
<head>
<script type="text/javascript" scr="registration.php" language="javascript">
function check()
{
var name=document.reg.user.value;
var pass=document.reg.pass.value;
var re=document.reg.re.value;
var full =document.reg.full.value;

if(name == "" || pass == "" || re == "" || full == ""){
document.getElementById('txt').innerHTML="All fields are compulsory !" ;
setTimeout("",60);
}
}

function back()
{
window.location.href="index.php";
window.close();
}
</script>
</head>
<body style="background-image:url(spider.jpg)">


<div style="margin:0 ; top:0 ; left:0">

<input type="button" value="Back" onClick="javascript:back()" style="margin:0 ; position:absolute ; top:300 ; left:0"/>

<form name="reg" style="position:absolute; top:200; left:525" method="post" action="registration.php">
<fieldset style="height:250 ; width:300">
Full Name:&nbsp &nbsp<input type="text" name="full" size="25"/><br/><br/><br/>
<fieldset style="width:250">
<legend>Registration Form:</legend>
<table>
<tr>
<td>User name: &nbsp   &nbsp<input type="text" name="user" size="20"/></td>
</tr>
<tr></tr><tr></tr>
<tr>
<td>Password:&nbsp  &nbsp &nbsp<input type="password" name="pass" size="20"/></td>
</tr>
<tr></tr><tr></tr>
<tr>
<td>  Confirm:&nbsp &nbsp &nbsp &nbsp <input type="password" name="re" size="20"/></td>
</tr>
</table>
</fieldset><br/>
&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp
<input type="submit" value="Register" onClick="check()"/>
</fieldset>
</form>

<div style="position:absolute; top:450; left:515">
<h2 id="txt" style="color:red"></h2>
<h2 id="confirm" style="color:green"></h2>

</div>

</div>
<?php
error_reporting(0);

$name = $_POST['user'];
$pass = $_POST['pass'];
$re = $_POST['re'];
$full = $_POST['full'];
$concat = "database/".$name.".txt";
$check = file_exists("database/".$name.".txt");
$result=1;
if($pass != $re)
{
$result = 0;
}
if(!($check)){
if($name != NULL && $pass != NULL && $re != NULL && $full != NULL && $result != 0) 
{
$f = fopen($concat,"x");
fwrite($f,"$pass");
$h = fopen("support/tmp_d.txt","a");
fwrite($h,"$full\n");
fwrite($h,"$name\n");
fclose($h);
$confirm = 1 ;

$mn = fopen("database/full/".$name.".txt","w");
fwrite($mn,"$full");
fclose($mn);
}
}
else if($check)
{
$var = 2 ;
}
fclose($f);
?>

<script type="text/javascript" language="javascript">

var res = "<?php echo $result  ?> ";
var rest = "<?php echo $var  ?> ";
var confirm = "<?php echo $confirm ?> ";
if(rest == 2)
{
document.getElementById('txt').innerHTML = "User already exists. Try another user name ! " ;
}

if(res == 0)
{
document.getElementById('txt').innerHTML = "Password do not match!" ;
}
if(confirm == 1)
{
document.getElementById('confirm').innerHTML = "You are successfully registered !" ;
}
rest="";
res="";
confirm="";
setTimeout("",60);
</script>
</body>
</html>