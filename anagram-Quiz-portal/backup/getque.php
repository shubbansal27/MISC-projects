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

	$file=fopen("cur_q.txt","w");
	fwrite($file,$_GET['last_q']);	
	fclose($file);

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
