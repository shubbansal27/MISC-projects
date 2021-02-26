<html>
<head>
<script type="text/javascript" language="javascript">
function back()
{
window.location.href="index.php";
window.close();
}
</script>
</head>
<body style="background-image:url(spider.jpg)">


<input type="button" value="Back" onClick="javascript:back()" style="margin:0 ; position:absolute ; top:300 ; left:0"/>
<form name="reg" style="margin:0;position:absolute; top:200; left:525" method="post" action="reset.php">
<fieldset>
<legend>Reset Form:</legend>
<table>
<tr>
<td>User name: &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp&nbsp &nbsp<input type="text" name="user" size="20"/></td>
</tr>
<tr></tr><tr></tr>
<tr>
<td>Current Password:&nbsp  &nbsp &nbsp<input type="password" name="pass" size="20"/></td>
</tr>
<tr></tr><tr></tr>
<tr>
<td>New Password:&nbsp &nbsp &nbsp &nbsp &nbsp<input type="password" name="new" size="20"/></td>
</tr>
</table>
</fieldset><br/>
&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp 
<input type="submit" value="Confirm"/>
</form>
<div style="margin:0;position:absolute; top:400; left:515">
<h2 id="txt" style="color:red"></h2>
<h2 id="confirm" style="color:green"></h2>
</div>

<?php
error_reporting(0);
$name=$_POST['user'];
$new = $_POST['new'];
$passw = $_POST['pass'];
$field=1;
$usr = 1;
$concat = "database/".$name.".txt";
$check = file_exists("database/".$name.".txt");
if($check)
{
$f = fopen($concat,"r");
$read = fgets($f);
fclose($f);
}

if(!($check))
$usr = 0;

if($name == NULL || $passw == NULL || $new == NULL)
$field=0;
?>

<?php
error_reporting(0);
$confirm = 0;

if(!($name == NULL || $passw == NULL || $new == NULL))
{
if($passw == $read)
{
$g = fopen($concat,"w");
fwrite($g,"$new");
fclose($g);
$confirm = 1;
}
}
if(!($name == NULL || $passw == NULL || $new == NULL))
{
if($passw != $read)
{
$confirm = 2;
}
}
?>
<script type="text/javascript" language="javascript">
var usrj = "<?php echo $usr ?>";
var fieldj = "<?php echo $field ?>" ;
var confirmj = "<?php echo $confirm  ?>";
if(fieldj == 0)
document.getElementById('txt').innerHTML = "All fields are compulsory !";

if(fieldj != 0 && usrj == 0)
document.getElementById('txt').innerHTML = "User doesn't exists!";

if(confirmj == 2 && usrj != 0)
document.getElementById('txt').innerHTML = "Wrong Current password !";

if(confirmj == 1 && usrj != 0)
document.getElementById('confirm').innerHTML = "your password has successfully changed !";

</script>
</body>
</html>