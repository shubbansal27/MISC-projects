<?php
	
	include("allow.php");
	if($allow == 0 || $_COOKIE[username] == "byebye")
	{	
	echo '<script type="text/javascript">			window.location.href="index.php";		</script>';
	}

	$con = mysql_connect("localhost","root","sql@admin");
	
	if(!$con)
	{
		die('could not connect: ' . mysql_error());
	}

	mysql_select_db("anagram",$con);


	$sql = "select * FROM login WHERE Username='$_COOKIE[username]' ";

	$result = mysql_query($sql,$con);  

	$obj = mysql_fetch_object($result) ;

	
	$sql2="SELECT * FROM onlineuser";
			
	if(!mysql_query($sql2,$con))	
	{
		$sql1="create table onlineuser (id int NOT NULL AUTO_INCREMENT,user varchar(30),primary key(id))";

		if(!mysql_query($sql1,$con))
		{
				  	die('Error: ' . mysql_error());
		}



		$sql2="insert into onlineuser(user) values('$obj->Username')";
		mysql_query($sql2,$con);

	}	
	else
	{
		$sql4="SELECT * FROM onlineuser WHERE user= '$obj->Username'";
	
		$out = mysql_query($sql4,$con);
	
		$obj1 = mysql_fetch_object($out);
	
	
		if(!$obj1)
		{
			$sql5="insert into onlineuser(user) values('$obj->Username')";
			mysql_query($sql5,$con);	
		}
	}
					
							

?>

<html>
	<head>
		<title><?php echo "$obj->Username" ?></title>
		<link rel="stylesheet" type="text/css" href="CSS/reset.css"/>
		<link rel="stylesheet" type="text/css" href="CSS/home.css"/>
		<style type="text/css" media="screen">
			.chat_time {
				font-style: italic;
				font-size: 9px;
				}
		</style>
		<script language="JavaScript" type="text/javascript">
			var sendReq = getXmlHttpRequestObject();
			var receiveReq = getXmlHttpRequestObject();
			var receiveuser = getXmlHttpRequestObject();
			var userlogout = getXmlHttpRequestObject();
			var lastMessage = 0;
			var lastuser = 0;
			ques = 1;
			var send_que=1;
			var mTimer;

			function logout(){

			/*if (userlogout.readyState == 4 || userlogout.readyState == 0)
			{
						var sn="<?php echo "$obj->Username" ?>";
						userlogout.open("GET", "userlog.php?chat=" + 1 + "&name=" + sn,true);
						userlogout.send(null);
			}*/
				window.location.href="logout.php";
			}
		

			//Function for initializating the page.
			function startChat() {
				
				//alert(sn);
				//Set the focus to the Message Box.
				document.getElementById('txt_message').focus();
				//Start Recieving Messages.
				comb();
			}		

			function comb()
			{	
				updateScore();
				getuser();
				getChatText();
			}

			//Gets the browser specific XmlHttpRequest Object
			function getXmlHttpRequestObject() {
				if (window.XMLHttpRequest) {
					return new XMLHttpRequest();
				} else if(window.ActiveXObject) {
					return new ActiveXObject("Microsoft.XMLHTTP");
				} else {
					document.getElementById('p_status').innerHTML = 'Status: Cound not create XmlHttpRequest Object.  Consider upgrading your browser.';
				}
			}
			
			//Gets the current messages from the server
			function getuser() {
				if (receiveuser.readyState == 4 || receiveuser.readyState == 0){
					var sn="<?php echo "$obj->Username" ?>";
					//alert(sn);
					receiveuser.open("GET", "getuser.php?chat=" + 1 + "&last=" + lastuser + "&name" + sn, true);
					receiveuser.onreadystatechange = handleuser; 
					receiveuser.send(null);
				}			
			}
			
			function getChatText() {
				if (receiveReq.readyState == 4 || receiveReq.readyState == 0){
					var sn="<?php echo "$obj->Username" ?>";
					//alert(sn);
					receiveReq.open("GET", "getChat.php?chat=" + 1 + "&last=" + lastMessage + "&name=" + sn, true);
					receiveReq.onreadystatechange = handleReceiveChat; 
					receiveReq.send(null);
				}			
			}
			//Add a message to the chat server.
			function sendChatText() 
			{
				
					if("<?php echo "$obj->Username"?>" == "admin")
					{
						
						if (sendReq.readyState == 4 || sendReq.readyState == 0)
						{
						sendReq.open("GET", "getque.php?chat=" + 1 + "&last=" + lastMessage + "&last_q=" + ques,true);
						//sendReq.onreadystatechange = handleque; 
						//clearInterval(mTimer);
						sendReq.send(null);
						ques=ques+1;
						}
						
					}							
					else
					{
						send_que=1;
						if(document.getElementById('txt_message').value == '') 
						{
						alert("You have not entered a message");
						return;
						}


						if (sendReq.readyState == 4 || sendReq.readyState == 0) 
						{
						sendReq.open("POST", 'getChat.php?chat=1&last=' + lastMessage + '&last_q=' + ques, true);
						sendReq.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
						sendReq.onreadystatechange = handleSendChat; 
						var param = 'message=' + document.getElementById('txt_message').value;
						param += '&name=<?php echo $obj->Username ?>';
						param += '&chat=1';
						sendReq.send(param);
						document.getElementById('txt_message').value = '';
						}

					}
					//updateScore();
			}
			
			/*function handleque()
			{
				if (receiveReq.readyState == 4) {
					var chat_div = document.getElementById('div_chat');
					var xmldoc = receiveReq.responseXML;
					var message_nodes = xmldoc.getElementsByTagName("message"); 
					var n_messages = message_nodes.length
					for (i = 0; i < n_messages; i++) {
						var user_node = message_nodes[i].getElementsByTagName("user");
						var text_node = message_nodes[i].getElementsByTagName("text");
						var time_node = message_nodes[i].getElementsByTagName("time");
						chat_div.innerHTML += user_node[0].firstChild.nodeValue + '&nbsp;';
						chat_div.innerHTML += '<font class="chat_time">' + time_node[0].firstChild.nodeValue + '</font><br />';
						chat_div.innerHTML += text_node[0].firstChild.nodeValue + '<br />';
						chat_div.scrollTop = chat_div.scrollHeight;
						lastMessage = (message_nodes[i].getAttribute('id'));
					}
					ques=ques+1;
					mTimer = setTimeout('comb();',2000); //Refresh our chat in 2 seconds
				}
			}*/
				
			//When our message has been sent, update our page.
			function handleSendChat() {
				//Clear out the existing timer so we don't have 
				//multiple timer instances running.
				clearInterval(mTimer);
				getChatText();
			}
			//Function for handling the return of chat text
			function handleReceiveChat() {
				if (receiveReq.readyState == 4) {
					var chat_div = document.getElementById('div_chat');
					var xmldoc = receiveReq.responseXML;
					var message_nodes = xmldoc.getElementsByTagName("message"); 
					var n_messages = message_nodes.length
					for (i = 0; i < n_messages; i++) {
						var user_node = message_nodes[i].getElementsByTagName("user");
						var text_node = message_nodes[i].getElementsByTagName("text");
						var time_node = message_nodes[i].getElementsByTagName("time");
						//chat_div.innerHTML += user_node[0].firstChild.nodeValue + '&nbsp;';
						chat_div.innerHTML += '<font class="chat_time">' + time_node[0].firstChild.nodeValue + '</font><br />';
						chat_div.innerHTML += text_node[0].firstChild.nodeValue + '<br /><br/>';
						chat_div.scrollTop = chat_div.scrollHeight;
						lastMessage = (message_nodes[i].getAttribute('id'));
					}
					mTimer = setTimeout('comb();',2000); //Refresh our chat in 2 seconds
				}
			}

			function handleuser()
			 {
				if (receiveuser.readyState == 4)
				 {
					var online_user = document.getElementById('online_user');
					var xmldoc = receiveuser.responseXML;
					var message_nodes = xmldoc.getElementsByTagName("onlineuser"); 
					var n_messages = message_nodes.length
					for (i = 0; i < n_messages; i++) {
						var user_node = message_nodes[i].getElementsByTagName("user");
						//var text_node = message_nodes[i].getElementsByTagName("text");
						//var time_node = message_nodes[i].getElementsByTagName("time");
						online_user.innerHTML += user_node[0].firstChild.nodeValue + '<br/><br/>';
						//chat_div.innerHTML += '<font class="chat_time">' + time_node[0].firstChild.nodeValue + '</font><br />';
						//chat_div.innerHTML += text_node[0].firstChild.nodeValue + '<br />';
						online_user.scrollTop = online_user.scrollHeight;
						lastuser = (message_nodes[i].getAttribute('id'));
					}
					mTimer = setTimeout('comb();',2000); //Refresh our chat in 2 seconds
				}
			}
			
			//This functions handles when the user presses enter.  Instead of submitting the form, we
			//send a new message to the server and return false.
			function blockSubmit() {
				sendChatText();
				return false;
			}
			//This cleans out the database so we can start a new chat session.
			function resetChat() {
				if (sendReq.readyState == 4 || sendReq.readyState == 0) {
					sendReq.open("POST", 'getChat.php?chat=1&last=' + lastMessage, true);
					sendReq.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
					sendReq.onreadystatechange = handleResetChat; 
					var param = 'action=reset';
					sendReq.send(param);
					document.getElementById('txt_message').value = '';
				}							
			}
			//This function handles the response after the page has been refreshed.
			function handleResetChat() {
				document.getElementById('div_chat').innerHTML = '';
				getChatText();
			}	
			
			function updateScore()  {
				var scored = "<?php $result = mysql_query($sql,$con); $obj = mysql_fetch_object($result) ;echo $obj->score;?>";
				document.getElementById('score').innerHTML = 'score  :'+' '+scored;
				
			}
		</script>
	</head>
	<body onload="startChat()">
		<br />
		ANAGRAM : LNMIIT
		<br /><br />

	
	
<div id="online_user"></div>	

<div id="info">
<h3>User:    <?php  echo "$_COOKIE[username]"?></h3>
<br/>
<h3 id="score">score   :  <?php echo $obj->score;?><h3>
<br/>
<input type="button" value="Logout" onclick="javascript:logout()"/>
</div>
		

		
<div id="container">
	<div id="div_chat"></div>

</div>

<div id="frmm">
	<form id="frmmain" name="frmmain" onsubmit="return blockSubmit();">
		<input type="text" id="txt_message" name="txt_message" />
		<input type="button" name="btn_send_chat" id="btn_send_chat" value="Send" onclick="javascript:sendChatText();" />
	</form>
</div>

		
</body>
</html>		
			

<?php
		
	
mysql_close($con);

?>
