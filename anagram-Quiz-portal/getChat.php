<?php

//Send some headers to keep the user's browser from caching the response.

header("Expires: Mon, 26 Jul 1997 05:00:00 GMT" ); 
header("Last-Modified: " . gmdate( "D, d M Y H:i:s" ) . "GMT" ); 
header("Cache-Control: no-cache, must-revalidate" ); 
header("Pragma: no-cache" );
header("Content-Type: text/xml; charset=utf-8");

require('database.php');

//Check to see if a message was sent.

	$sql_fetch = "select * from variable where id=1" ;

	$sql_fetch1 = db_query($sql_fetch);

	$sql_fetch2 = db_fetch_array($sql_fetch1);	

	if(isset($_POST['message']) && $_POST['message'] != '')
	{
		$q1 = "SELECT ans FROM question WHERE id='" . $sql_fetch2['temp'] . "'";
			
		$q2 = db_query($q1) ;

		$q3 = db_fetch_array($q2);

		$sql = "INSERT INTO message(chat_id, user_id, user_name, message, post_time) VALUES (" . 
			addslashes($_GET['chat']) . ", 1, '" . addslashes($_POST['name']) . 
			"', '" . addslashes($_POST['message']) . "', NOW())";

		db_query($sql);

		if($q3['ans'] == $_POST['message'] && $sql_fetch2['temp1'] == 0)	
		{

			$q4 = "UPDATE login SET score=score+5 where Username='" . addslashes($_POST['name']) . "'";
			db_query($q4);
			
			$q5 = "update variable set temp1=1 where id=1";
			db_query($q5);

		}		

	}


//Check to see if a reset request was sent.
if(isset($_POST['action']) && $_POST['action'] == 'reset') {
	$sql = "DELETE FROM message WHERE chat_id = " . db_input($_GET['chat']);
	db_query($sql);
}


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
}
else
{
	$last = (isset($_GET['last']) && $_GET['last'] != '') ? $_GET['last'] : 0;

	if( addslashes($_GET['name']) != 'admin')
	{	
	$sql = "SELECT message_id, user_name, message, date_format(post_time, '%h:%i') as post_time" . 
		" FROM message WHERE (user_name = '" . addslashes($_GET['name']) . "' OR user_name = 'admin') AND message_id > " . $last;
	}
	else
	{
	$sql = "SELECT message_id, user_name, message, date_format(post_time, '%h:%i') as post_time" . 
		" FROM message WHERE message_id > " . $last;
	}			
		
	$message_query = db_query($sql);
	//Loop through each message and create an XML message node for each.
	while($message_array = db_fetch_array($message_query))
	{
		$xml .= '<message id="' . $message_array['message_id'] . '">';
		$xml .= '<user>' . htmlspecialchars($message_array['user_name']) . '</user>';
		$xml .= '<text>' . htmlspecialchars($message_array['message']) . '</text>';
		$xml .= '<time>' . $message_array['post_time'] . '</time>';
		$xml .= '</message>';
	}
}

$xml .= '</root>';
echo $xml;
?>