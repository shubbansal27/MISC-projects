<html>
<head>
<meta http-equiv="refresh" content="3600;url=friend.php">
<script type="text/javascript">
function logout()
{
window.location.href="index.php";
window.close();
}
</script>
</head>
<body style="background-image:url(spider.jpg)">
<input type="button" value="Logout" onClick="javascript:logout()" style="margin:0 ; position:absolute ; left:10 ; top : 10"/>

<form style="margin:0 ; position:absolute ; left:285 ; top : 0" action="friend.php" method="post">
<br/>
<div style="margin:0 ; position:absolute ; left:145 ; top:20">
Search By: 
<select name=filter>
<option value="0">Full name</option>
<option value="1">User</option>
</select>
<input type="text" name="name" size="30"/>
<input type="submit" value="Find"/>
</div>
<br/><br/>
<iframe border = "0" src="sub2.php" style="background-color:#CBE4F4 ; height:75 ; width:740"></iframe>
</form>



<div style="margin:0 ;position:absolute; left:1100 ; top:0">
<h3 style="color:green">Notifications:</h3><hr/>
<iframe src="sub3.php" style="height:535; width:250 "></iframe>
</div>


<div style="margin:0 ;position:absolute; left:15 ; top:20">
<h3 style="color:green">Friend list:</h3>
<iframe src="sub1.php" style="height:535 ; width:200 "></iframe>
</div>


<div style="margin:0 ;position:absolute ; top:220 ; left:450">
<fieldset style="width:400; height:250">
<legend>Chat Section</legend>
</fieldset>
</div>


<?php
error_reporting(0);
$filter = $_POST['filter'];
$name = $_POST['name'];
$h = fopen("support/lst.txt","w");
if ($filter == "0")
{
$f = fopen("support/tmp_d.txt","r");

fclose($h);
$dummy1 = strtoupper($name)."\n";

while(!(feof($f))){
$var1 = fgets($f);
$var2 = fgets($f);
$dummy2 = strtoupper($var1);

if ($dummy2 == $dummy1 && $name != NULL){
$g= fopen("support/lst.txt","a");
fwrite($g,"$var2");
fclose($g);
}
}
}

if ($filter == "1")
{
$name = $_POST['name'];
$h = fopen("support/lst.txt","w");
$confirmed = file_exists("database/".$name.".txt");
if($confirmed && $name != NULL){
fwrite($h,"$name\n");
}
}
?>
</body>
</html>