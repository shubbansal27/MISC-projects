<?php
$host ="localhost";
$user = "root";
$password = "sql@admin";
$db="anagram";
$connect = mysql_connect($host, $user, $password);
if (!$connect) {
    die('Could not connect: ' . mysql_error());
}
mysql_select_db($db,$connect);
?>
