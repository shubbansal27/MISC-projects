<html>
<head>
<script type="text/javascript" language="javascript">
function reset()
{
win3=window.open("reset_form.php","win3","height=375, width=520, status=1");
win3.moveTo(285,210);
}

function logout()
{
window.location.href="index.php";
window.close();
}
</script>
</head>
<body style="background-image:url(spider.jpg)">

<script type="text/javascript" language="javascript">
var check_cookie = "<?php echo $_COOKIE['users'] ?>";
if (check_cookie == "welcome")
{
window.location.href= "index.php";
}
</script>

<img name="picture" border="2" style="margin:0 ; position:absolute ; top:15 ; left:25 ; height:250 ; width:200"/>
<div style="margin:0 ; position:absolute; top:320 ; left:25" >
<fieldset>&nbsp &nbsp &nbsp 
<input type="button" value="Logout" onClick="javascript:logout()"/><br/><br/><br/>
<input type="button" value="Reset Password" onClick="javascript:reset()"/>
</fieldset>
</div>

<div style="margin:0 ; position:absolute; top:475 ; left:150;height:75;width:75">
<a href="inbox.php"><img src="msg.gif" style="height:75 ; width:75"/></a>
<h3 style="color:orange">&raquo Inbox</h3>
</div>

<div style="margin:0 ; position:absolute; top:475 ; left:25" >
<a href="friend.php"><img src="frnd.gif" style="height:75 ; width:75"/></a>
<h3 style="color:orange">&raquo Friends</h3>
</div>

<div style="margin:0 ; position:absolute ; top:60 ; left:425" >
<fieldset style="width:350 ; height:475 ;resizable:0">
<legend>About Me:</legend>
<b>Full Name:</b><h1 id="full_name" Style="color:blue ; font-family:Comic Sans MS ; text-align:center">No data Saved.</h1><hr>
Gender:<h2 id="Gender" Style="color:blue ; font-family:Comic Sans MS ; text-align:center">No data Saved.</h2><hr>
Date of Birth:<h3 id="date_birth" Style="color:blue ; font-family:Comic Sans MS ; text-align:center">No data Saved.</h3><hr>
Permanent Add.:<h4 id="per" Style="color:blue ; font-family:Comic Sans MS ; text-align:center">No data Saved.</h4>
</fieldset>
</div>

<div style="margin:0 ; position:absolute; top:15 ; left:975">
<fieldset>
<legend>Profile:settings</legend> 
<form name="pro" action="home.php" method="post">
<table>
<tr>Full Name:
<input type="text" name="full" size="25"/>
</tr><br/><br/><br/>
<tr>Gender:&nbsp &nbsp
Male<input type="radio" name="gender" value="male" checked="true"/> &nbsp &nbsp
Female<input type="radio" name="gender" value="female"/>
</tr><br/>
<br/><br/>
<tr>
Date of birth:
<select name="date">
<option value="1">1</option>
<option value="2">2</option>
<option value="3">3</option>
<option value="4">4</option>
<option value="5">5</option>
<option value="6">6</option>
<option value="7">7</option>
<option value="8">8</option>
<option value="9">9</option>
<option value="10">10</option>
<option value="11">11</option>
<option value="12">12</option>
<option value="13">13</option>
<option value="14">14</option>
<option value="15">15</option>
<option value="16">16</option>
<option value="17">17</option>
<option value="18">18</option>
<option value="19">19</option>
<option value="20">20</option>
<option value="21">21</option>
<option value="22">22</option>
<option value="23">23</option>
<option value="24">24</option>
<option value="25">25</option>
<option value="26">26</option>
<option value="27">27</option>
<option value="28">28</option>
<option value="29">29</option>
<option value="30">30</option>
<option value="31">31</option>
</select>&nbsp


<select name="month">
<option value="jan">Jan</option>
<option value="feb">Feb</option>
<option value="march">March</option>
<option value="april">April</option>
<option value="may">May</option>
<option value="june">June</option>
<option value="july">July</option>
<option value="aug">Aug</option>
<option value="sept">Sept</option>
<option value="oct">Oct</option>
<option value="nov">Nov</option>
<option value="dec">Dec</option>
</select>&nbsp


<select name="year">
<option value="2011">2011</option>
<option value="2010">2010</option>
<option value="2009">2009</option>
<option value="2008">2008</option>
<option value="2007">2007</option>
<option value="2006">2006</option>
<option value="2005">2005</option>
<option value="2004">2004</option>
<option value="2003">2003</option>
<option value="2002">2002</option>
<option value="2001">2001</option>
<option value="2000">2000</option>
<option value="1999">1999</option>
<option value="1998">1998</option>
<option value="1997">1997</option>
<option value="1996">1996</option>
<option value="1995">1995</option>
<option value="1994">1994</option>
<option value="1993">1993</option>
<option value="1992">1992</option>
<option value="1991">1991</option>
<option value="1990">1990</option>
<option value="1989">1989</option>
<option value="1988">1988</option>
<option value="1987">1987</option>
<option value="1986">1986</option>
<option value="1985">1985</option>
<option value="1984">1984</option>
<option value="1983">1983</option>
<option value="1982">1982</option>
<option value="1981">1981</option>
<option value="1980">1980</option>
</select>
</tr><br/><br/><br/>
<tr>
Parmanent address:<br>
<textarea name="address" rows="4" cols="25" value="" style="font-size:20 ; font-style:bold">
</textarea>
</tr><br/><br/>
<input type="checkbox" name="cb" value="1"/>Yes,I want to save my profile.<br/><br/>
<input type="submit" value="Save"/><br/>
<hr/>
<br/><br/>
</form>


<form name ="file" action="home.php" method="post"
enctype="multipart/form-data">
<label for="file">Profile Pic:</label>
<input type="file" name="pic" id="file" /> 
<br /><br/>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp  &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp  &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp
 &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp  &nbsp &nbsp 
<input type="submit" name="submit" value="Upload" />
</form>
</fieldset>
</div>

<?php
error_reporting(0);
$t = $_COOKIE['users'];
$cb = $_POST['cb'];
$full = $_POST['full'];
$gender = $_POST['gender']; 
$date = $_POST['date'];
$month = $_POST['month'];
$year = $_POST['year'];
$d = $date."-".$month."-".$year; 
$address = $_POST['address']; 
$concat = "database/".$t.".txt";
$concatf = "database/full/".$t.".txt"; 
$concatd = "database/date"."/".$t.".txt"; 
$concatg = "database/gender/".$t.".txt"; 
$concatp = "database/parmanent/".$t.".txt";
if ($cb==1)
{
if ($full!=NULL)
{
$f = fopen($concatf,"w");
fwrite($f,"$full");
fclose($f);

$cook1=$t."\n" ;
$finis = 0;
$f= fopen("support/tmp_d.txt","r+");
$i=1;
while(!(feof($f))){
$q = fgets($f);
$q1 = $i % 2 ;
if($q1 == 0 && $q == $cook1 )
{
$finis = 1;
break;
}
$i=$i+1;
}
}

$g = fopen($concatg,"w");
fwrite($g,"$gender");
fclose($g);

if ($address!=NULL)
{
$p = fopen($concatp,"w");
fwrite($p,"$address");
fclose($p);
}

$dmy = fopen($concatd,"w");
fwrite($dmy,"$d");
fclose($dmy);
}


if((file_exists($concatf)))
{
$f=fopen($concatf,"r");
$fff = fgets($f);
fclose($f);
}

if((file_exists($concatg)))
{
$g=fopen($concatg,"r");
$ggg = fgets($g);
fclose($g);
}

if((file_exists($concatd)))
{
$d=fopen($concatd,"r");
$ddd = fgets($d);
fclose($d);
}

if((file_exists($concatp)))
{
$p=fopen($concatp,"r");
$ppp = fgets($p);
fclose($p);
}   
?>

<?php
error_reporting(0);
if ($_FILES["pic"]["type"]=="image/jpeg")
{
move_uploaded_file($_FILES["pic"]["tmp_name"],"database/pics/".$t.".jpg");
$piks = 1;
}
?>

<?php
if($finis == 1){
$f = fopen("support/garb_".$t.".txt","a");
$g = fopen("support/tmp_d.txt","r");
$j=0;
while(!(feof($g))){
$q = fgets($g);
if($j != $i-2){
fwrite($f,"$q");
}
else{
fwrite($f,"$full\n");
}
$j = $j+1;
}
fclose($f);
fclose($g);
rename("support/garb_".$t.".txt","support/tmp_d.txt");
}
?>

<script type="text/javascript" language="javascript" >
var x = "<?php echo $t ?>";
var y = "<?php echo $piks ?> ";
document.picture.src = "database/pics/"+x+".jpg"  ;
</script>

<script type="text/javascript" language="javascript">
var user_name = "<?php echo $t ?>";
var full_name = "<?php echo $fff ?>";
var gen = "<?php echo $ggg ?>";
var dat = "<?php echo $ddd ?>";
var perma = "<?php echo $ppp ?>";
document.getElementById('full_name').innerHTML = full_name;
document.getElementById('Gender').innerHTML = gen;
document.getElementById('date_birth').innerHTML = dat;
document.getElementById('per').innerHTML = perma;
</script>


</body>
</html>