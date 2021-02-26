<?php
/*
	This is the PHP backend file for the AJAX Driven Chat application.
	
	You may use this code in your own projects as long as this copyright is left
	in place.  All code is provided AS-IS.
	This code is distributed in the hope that it will be useful,
 	but WITHOUT ANY WARRANTY; without even the implied warranty of
 	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	
	For the rest of the code visit http://www.DynamicAJAX.com
	
	Copyright 2005 Ryan Smith / 345 Technical / 345 Group.
*/

//Send some headers to keep the user's browser from caching the response.
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT" ); 
header("Last-Modified: " . gmdate( "D, d M Y H:i:s" ) . "GMT" ); 
header("Cache-Control: no-cache, must-revalidate" ); 
header("Pragma: no-cache" );
header("Content-Type: text/xml; charset=utf-8");

require('database.php');

//Check to see if a message was sent.

	$q_5 = "update variable set temp1=0 where id=1";
	db_query($q_5);
	
		
	$sql_var = "SELECT temp FROM variable WHERE id=1";
		
	$sql_res = db_query($sql_var);
	
	$sql_res1 = db_fetch_array($sql_res);

	if($_GET['last_q'] == 1 && $sql_res1['temp'] == 0)
	{
		$sql_res2 = "UPDATE variable SET temp=" . $_GET['last_q'];
		db_query($sql_res2);
	}
	else
	{
		if($_GET['last_q'] <= $sql_res1['temp'])
		{
			$_GET['last_q'] = $sql_res1['temp'] + 1;
		}
		
		$sql_res3 = "UPDATE variable SET temp=" . $_GET['last_q'];
		db_query($sql_res3);
	}
			
	$i=0;
		
	$q = " select * from question ";
	$q1 = db_query($q) ;
	while($q2 = db_fetch_array($q1))
	$i++;	
	
	if($_GET['last_q'] <= $i)
	{	
	$sql1 = "SELECT * FROM question WHERE id=" . $_GET['last_q'] ;
	
	$query1 = db_query($sql1);

	$query2 = db_fetch_array($query1); 


		$sql = "INSERT INTO message(chat_id, user_id, user_name, message, post_time) VALUES (" . 
			addslashes($_GET['chat']) . ", 1, 'admin','" . addslashes($query2['quest']) . "', NOW())";
			db_query($sql);
	}

?>