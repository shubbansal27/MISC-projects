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
//if(isset($_POST['message']) && $_POST['message'] != '') {
//	$sql = "INSERT INTO onlineuser(user, user_id, user_name, message, post_time) VALUES (" . 
//			addslashes($_GET['chat']) . ", 1, '" . addslashes($_POST['name']) . 
//			"', '" . addslashes($_POST['message']) . "', NOW())";
//	db_query($sql);
//}
//Check to see if a reset request was sent.
//if(isset($_POST['action']) && $_POST['action'] == 'reset') {
//	$sql = "DELETE FROM message WHERE chat_id = " . db_input($_GET['chat']);
//	db_query($sql);
//}


//Create the XML response.
$xml = '<?xml version="1.0" ?><root>';
//Check to ensure the user is in a chat room.
if(!isset($_GET['chat'])) {
	$xml .='Your are not currently in a chat session.  <a href="">Enter a chat session here</a>';
	$xml .= '<message id="0">';
	$xml .= '<user>Admin</user>';
	$xml .= '<text>Your are not currently in a chat session.  &lt;a href=""&gt;Enter a chat session here&lt;/a&gt;</text>';
	$xml .= '<time>' . date('h:i') . '</time>';
	$xml .= '</message>';
} else {
	$last = (isset($_GET['last']) && $_GET['last'] != '') ? $_GET['last'] : 0;

	$sql = "SELECT id, user FROM onlineuser WHERE id > " . $last;
		
	$message_query = db_query($sql);
	//Loop through each message and create an XML message node for each.
	while($message_array = db_fetch_array($message_query)) {
		$xml .= '<onlineuser id="' . $message_array['id'] . '">';
		$xml .= '<user>' . htmlspecialchars($message_array['user']) . '</user>';
		$xml .= '</onlineuser>';
	}
}
$xml .= '</root>';
echo $xml;
?>
