//JChatRoom version 1.0              JCR ver-1.0
//Author: Shubham Bansal
//Date(start) : 24-july-2011 

import java.awt.*;
import java.awt.event.*;
import java.net.*;
import java.io.*;
import java.awt.image.*;

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------
public class chat
{
  public static void main(String args[]) throws IOException                                         //Main method                 
  {
    GUI obj = new GUI();
    obj.gui();
  } //main ends
} //class ends

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------
class GUI extends Frame implements MouseListener,ActionListener,ItemListener,Runnable,FocusListener
{
  int x=0,y=0,len=0;
  static int clientCount=0,seal=0;
  Label About_l1,About_l2,per,online,status,conn;
  static Label serverC,onlineC,capC,statusC,chatOnline,lnicC;
  Panel menu,About,Pserver,Pfind,nickName,nickNameC,tray1,tray2;
  static Panel passwordPanel,validPanel,connect,chatWindow;
  Button menu_b1,menu_b2,menu_b3,menu_b4,back,back2,back3,back4,back5,create,join,proceed,send,back3C,bconn,proceedTo;
  static Button proceedC,proceedGo;
  Button joinTo = new Button("Join"); 
  Button refresh = new Button("Refresh");
  Image im2,im3,im4;
  boolean pb = false,ctc=false,C1=true,C2=false;
  static boolean protec=false,validity=false,z1=false,z2=false,z3=false,z4=false,z5=false,z6=false;
  static TextField tname,number,tpassword,tp,tnicC;
  TextField tnic,tmsg,tconn,sm1,sm2,sm3,sm4;
  Checkbox pass,c1,c2;
  Thread th;
  static Thread openChat;
  static InetAddress local,iconn;
  TextArea tchat;
  static List Lonline = new List(30,false);
  static List serverlist;
  static String tmp2[];
  static String Stname="",Snumber="",tpassword_c,protec_c,tname_c,number_c,clientCount_c;
  SocketHandling f;
  
  public void gui() throws IOException
  {
                       
    setBackground(Color.lightGray);                                                                 //frame-window   
    setLayout(null);
    setCursor(Cursor.HAND_CURSOR);
    setTitle("ChatRoom");
    setSize(500,300);
    setResizable(false);       Image im = (Toolkit.getDefaultToolkit()).getImage("image1.jpg");    setIconImage(im);
    addWindowListener(new WindowAdapter(){
      public void windowClosing(WindowEvent e){try{SocketHandling.th.stop();} catch(Exception g){} dispose();}
    });
    th = new Thread(this);
    setVisible(true);
    
    im2 = Toolkit.getDefaultToolkit().getImage("image2.gif");                                       //image handling
    im3 = Toolkit.getDefaultToolkit().getImage("pb.gif");
    
    
    panelMenu();
    panelAbout();
    validate();
    local = InetAddress.getLocalHost();                                                        //buttons created in frame for Pfind Panel
    joinTo.setBounds(377,253,75,25);  joinTo.setVisible(false); add(joinTo);
    refresh.setBounds(32,253,75,25);  refresh.setVisible(false); add(refresh);
  }//gui ends
  
  
  public void cordii()                                                                              //for help
  {
    setTitle("("+x+", "+y+")");
  }
  
//---------------------------------------------------------- Panels ---------------------------------------------------------------------------------------------------
  
  public void panelAbout()
  {
    About = new Panel();                                                                            //About Panel
    About.setLayout(new GridLayout(5,1,5,4));
    About.setBounds(270,218,200,150);
    About.setVisible(true);
    add(About);
    About_l1 = new Label("Chat-Room, Version-1.0");   About_l1.setForeground(Color.red);
    About_l2 = new Label("Author - Shubham Bansal");  About_l2.setForeground(Color.blue); 
    About.add(About_l1);  About.add(About_l2); 
  }
  
  public void panelMenu()
  {
    menu = new Panel();                                                                             //menu-Panel
    menu.setLayout(new GridLayout(4,1,5,15));
    menu.setBounds(9,98,150,165);
    menu.setVisible(true);
    add(menu);
    menu_b1 = new Button("Create Server");   menu_b1.addActionListener(this); menu_b1.addMouseListener(this); menu_b1.setBackground(Color.white);
    menu_b2 = new Button("Find Server");     menu_b2.addActionListener(this); menu_b2.addMouseListener(this); menu_b2.setBackground(Color.white);
    menu_b4 = new Button("Connect");         menu_b4.addActionListener(this); menu_b4.addMouseListener(this); menu_b4.setBackground(Color.white);
    menu_b3 = new Button("Abort");           menu_b3.addActionListener(this); menu_b3.addMouseListener(this); menu_b3.setBackground(Color.white);
    menu.add(menu_b1);   menu.add(menu_b4);   menu.add(menu_b2); menu.add(menu_b3);
  }
  
  public void panelCreateServer()
  {
    Pserver = new Panel();                                                                          //create server Panel
    Pserver.setLayout(null);
    Pserver.setBounds(0,0,500,250);
    Pserver.setVisible(true);
    add(Pserver);
    back = new Button("Back"); 
    back.setBounds(408,38,85,25); back.addMouseListener(this);
    back.addActionListener(this);
    back.setVisible(true);
    Pserver.add(back);
    Label localhost = new Label();
    localhost.setBackground(Color.black); localhost.setForeground(Color.white);  
    //local = InetAddress.getLocalHost();
    localhost.setText(local.toString());
    localhost.setBounds(28,31,300,35);
    Pserver.add(localhost);
    Label name = new Label("Server-name: "); name.setBounds(32,90,100,30);
    tname = new TextField(); tname.setBounds(150,90,150,30); 
    pass = new Checkbox("Password Protection"); pass.setBounds(320,90,170,20); pass.addItemListener(this);
    Label password = new Label("Password: "); password.setBounds(32,130,100,30);
    tpassword = new TextField();   tpassword.setBounds(150,130,150,30);  tpassword.setEnabled(false); tpassword.setBackground(Color.lightGray);
    number = new TextField("5");  number.setBounds(32,180,30,30); number.addFocusListener(this);
    Label mem = new Label("Members allowed");  mem.setBounds(70,180,100,30);
    create = new Button("Create");  create.setBounds(32,220,100,30); create.addActionListener(this); create.addMouseListener(this);
    per = new Label(""); per.setBounds(446,257,100,30); 
    join = new Button("ENTER"); join.setBackground(Color.black); join.setForeground(Color.white); join.setBounds(407,178,85,85); join.addActionListener(this);  join.addMouseListener(this); join.setVisible(false);
    Pserver.add(name); Pserver.add(tname); Pserver.add(pass); Pserver.add(password); Pserver.add(tpassword); Pserver.add(number);  Pserver.add(create); Pserver.add(mem); add(per);Pserver.add(join);
    
  }
  
  public void panelFindServer()
  {
    Pfind = new Panel();                                                                            //find server Panel
    Pfind.setLayout(null);
    Pfind.setBackground(Color.cyan);
    Pfind.setBounds(0,0,500,242);
    Pfind.setVisible(true);
    add(Pfind);
    joinTo.setVisible(true);
    joinTo.addActionListener(this);  joinTo.addMouseListener(this);
    joinTo.setBackground(Color.white);
    joinTo.setEnabled(false);
    refresh.setVisible(true);
    refresh.setBackground(Color.white);
    refresh.addActionListener(this); refresh.addMouseListener(this);
    refresh.setEnabled(true);
    
    back2 = new Button("Back");
    back2.setBounds(408,38,85,25); back2.addMouseListener(this);
    back2.addActionListener(this);
    back2.setVisible(true);
    Pfind.add(back2);
    
    Label avail = new Label("Available server list:"); avail.setBounds(17,38,155,30); avail.setFont(new Font("TIMESNEWROMAN",Font.BOLD,14)); avail.setForeground(Color.red); avail.setBackground(Color.yellow);
    Pfind.add(avail);
    serverlist = new List(25,false); serverlist.setBounds(19,86,460,150); serverlist.addItemListener(this); Pfind.add(serverlist);
    
  }
  
  public void panelConnect()                                                                        //connect panel
  {
    connect = new Panel();
    connect.setLayout(null);
    connect.setBounds(0,0,500,300);
    connect.addMouseListener(this);
    connect.setVisible(true);
    add(connect);
    back5 = new Button("Back");
    back5.setBounds(408,38,85,25); back5.addMouseListener(this);
    back5.addActionListener(this);
    back5.setVisible(true);
    connect.add(back5);
    
    CheckboxGroup cbg = new CheckboxGroup();
    c1 = new Checkbox("Using PC name",true,cbg);  c1.setBounds(75,73,120,25);  c1.addItemListener(this);
    c2 = new Checkbox("Using IP address",false,cbg); c2.setBounds(230,73,125,25);  c2.addItemListener(this);
    connect.add(c1);  connect.add(c2);
    conn = new Label("Enter Server-PC name: "); conn.setBounds(59,125,190,30);
    tray1 = new Panel(); tray1.setLayout(new BorderLayout()); tray1.setBounds(225,125,220,30);tray1.setVisible(true); connect.add(tray1);
    tconn = new TextField(); tray1.add(tconn); tray1.validate();
    tray2 = new Panel(); tray2.setLayout(new GridLayout(1,4)); tray2.setBounds(225,125,220,30);tray2.setVisible(false); connect.add(tray2);
    sm1 = new TextField();  sm2 = new TextField(); sm3 = new TextField(); sm4 = new TextField();
    tray2.add(sm1);  tray2.add(sm2);  tray2.add(sm3);  tray2.add(sm4); tray2.validate();
    connect.add(conn); 
    bconn = new Button("Connect"); bconn.setBounds(188,192,100,30); bconn.addActionListener(this);  bconn.addMouseListener(this);
    connect.add(bconn);
    passwordPanel = new Panel();
    passwordPanel.setLayout(new GridLayout(1,3,20,5));
    passwordPanel.setBackground(Color.white);
    passwordPanel.setBounds(54,249,400,22);
    passwordPanel.setVisible(false);
    connect.add(passwordPanel);
    
    Label x = new Label("Enter Password: "); x.setBackground(Color.yellow); 
    tp = new TextField();
    proceedTo = new Button("Proceed"); proceedTo.addActionListener(this); proceedTo.addMouseListener(this); proceedTo.setBackground(Color.black);  proceedTo.setForeground(Color.white); 
    proceedGo = new Button("Proceed"); proceedGo.addActionListener(this); proceedGo.addMouseListener(this); proceedGo.setBackground(Color.black);  proceedGo.setForeground(Color.white);
    proceedGo.setBounds(337,240,100,20); proceedGo.setVisible(false); connect.add(proceedGo);
    passwordPanel.add(x); passwordPanel.add(tp); passwordPanel.add(proceedTo); passwordPanel.validate();
    
    validPanel = new Panel();
    validPanel.setLayout(new GridLayout(1,3,20,5));
    validPanel.setBackground(Color.white);
    validPanel.setBounds(54,249,400,22);
    validPanel.setVisible(false);
    connect.add(validPanel);
    Label xx = new Label("                                                   Invalid Password"); xx.setBackground(Color.yellow);
    validPanel.add(xx);validPanel.validate();
  }
  
  public void panelNickName()                                                                       //nickName window for server 
  {
    nickName = new Panel();
    nickName.setLayout(null); 
    nickName.setBounds(0,0,500,300);
    nickName.addMouseListener(this);
    nickName.setVisible(true);
    add(nickName);
    back3 = new Button("Back");
    back3.setBounds(408,38,85,25); back3.addMouseListener(this);
    back3.addActionListener(this);
    back3.setVisible(true);
    nickName.add(back3);
    online = new Label("Online: server"); online.setBounds(31,55,150,35); nickName.add(online);
    status = new Label("Status: Allowed"); status.setBounds(185,55,150,35); nickName.add(status);
    Label Lnic = new Label("Enter Your nic name ");Lnic.setFont(new Font("TIMESNEWROMAN",Font.BOLD,20));Lnic.setForeground(Color.blue); Lnic.setBounds(30,137,200,30); nickName.add(Lnic); 
    tnic = new TextField(); tnic.setBounds(250,137,150,30); nickName.add(tnic);
    proceed = new Button("Proceed"); proceed.setBounds(193,214,85,50); proceed.addActionListener(this); proceed.addMouseListener(this); nickName.add(proceed);
  }
  
  public void panelNickNameC()                                                                      //nickName window for client  
  {
    nickNameC = new Panel();
    nickNameC.setLayout(null);
    nickNameC.setBounds(0,0,500,300);
    nickNameC.addMouseListener(this);
    nickNameC.setVisible(true);
    add(nickNameC);
    back3C = new Button("Back");
    back3C.setBounds(408,38,85,25); back3C.addMouseListener(this);
    back3C.addActionListener(this);
    back3C.setVisible(true);
    nickNameC.add(back3C);
    serverC = new Label("SERVER NAME: "+tname_c); serverC.setBounds(31,45,200,25); nickNameC.add(serverC); serverC.setBackground(Color.cyan);
    onlineC = new Label("Currently Online: "+clientCount_c); onlineC.setBounds(31,217,150,35); nickNameC.add(onlineC);
    capC = new Label("Capacity: "+number_c+" members"); capC.setBounds(31,80,150,35); nickNameC.add(capC);
    String tmp;
    lnicC = new Label();lnicC.setForeground(Color.red); lnicC.setBounds(250,130,200,30); nickNameC.add(lnicC); 
    
    Label LnicC = new Label("Enter Your nic name ");LnicC.setFont(new Font("TIMESNEWROMAN",Font.BOLD,20));LnicC.setForeground(Color.blue); LnicC.setBounds(30,157,200,30); nickNameC.add(LnicC); 
    tnicC = new TextField(); tnicC.setBounds(250,157,150,30); nickNameC.add(tnicC);
     proceedC = new Button("Proceed"); proceedC.setBounds(252,220,115,50); proceedC.addActionListener(this);  proceedC.addMouseListener(this); nickNameC.add(proceedC);
    
    if((Integer.parseInt(number_c) - Integer.parseInt(clientCount_c)) ==0) {tmp = "Status: NOT ALLOWED";   tnicC.setEnabled(false);  proceedC.setEnabled(false); }
    else{ tmp = "Status: ALLOWED";}
    statusC = new Label(tmp); statusC.setBounds(31,241,150,35); nickNameC.add(statusC);
    Choice cbar = new Choice();   
    cbar.setBounds(222,80,150,35); nickNameC.add(cbar); 
    for(int i =0;i<tmp2.length;i++){ cbar.add(tmp2[i]);}
    }
  
  
  public void panelChat()
  {
    setSize(620,450);
    chatWindow = new Panel();
    chatWindow.setLayout(null);
    chatWindow.setVisible(false);
    chatWindow.setBounds(0,0,750,550);
    add(chatWindow);
    back4 = new Button("Leave");
    back4.setBounds(9,35,85,25); back4.addMouseListener(this);
    back4.addActionListener(this);
    back4.setVisible(true);
    chatWindow.add(back4);
    chatOnline = new Label("Online: "+clientCount); chatOnline.setBounds(474,40,200,35); chatWindow.add(chatOnline); 
    
    Panel yours = new Panel();                                                                      //your message window
    yours.setLayout(null);
    yours.setBackground(Color.green);
    yours.setBounds(0,400,470,50);
    chatWindow.add(yours);
    Label lmsg = new Label("Message:"); lmsg.setBounds(18,10,70,30);
    tmsg = new TextField(); tmsg.setBounds(95,10,260,30);
    send = new Button("Send"); send.setBounds(370,10,75,30); send.addMouseListener(this); send.addActionListener(this);
    yours.add(lmsg); yours.add(tmsg); yours.add(send);
    
    Panel chatW = new Panel();                                                                      //chat WINDOW
    chatW.setLayout(null);
    chatW.setBackground(Color.orange);
    chatW.setBounds(0,79,470,317);
    chatWindow.add(chatW);
    tchat = new TextArea("",100,50,0); tchat.setEnabled(false); tchat.setBounds(6,6,458,308); chatW.add(tchat);
    
    
    Panel onW = new Panel();                                                                        //online status window
    onW.setLayout(null);
    onW.setBackground(Color.blue);
    onW.setBounds(473,79,200,500);
    chatWindow.add(onW);
    Lonline.setBounds(6,6,132,300);
    onW.add(Lonline);
  }
  

//Methods------------------------------------------Methods-------------------------------------------Methods----------------------------------Methods-------------------  

  
//-------------------------------------------------Paint()--------------------------------------------------------------------------------------------------------------
  
  public void paint(Graphics g)
  {
    g.drawImage(im2,300,66,120,120,this);
    
    
    if(pb == true)
    {
        g.drawImage(im3,32,260,len,25,this);
    }
    
     
  }
  
//-------------------------------------------------Multi-Threading------------------------------------------------------------------------------------------------------
  
  public void run()
  {
    
    for(int i=0;i<=400;i+=10)
      {  
        len = i; 
        try
        {
          Thread.sleep(500); repaint(); int percen = len/4 ; per.setText(""+percen+"%");
          if(percen == 100)
          { 
            join.setVisible(true);  
            
          }
        
        }
        catch(Exception e){}
    }
  }
    

  
//-------------------------------------------------Event Handling-------------------------------------------------------------------------------------------------------
  
  //implementing MouseListener methods
  
  public void mouseReleased(MouseEvent e){}
  public void mouseClicked(MouseEvent e){}
  public void mouseEntered(MouseEvent e)
  {
    if(e.getSource() == menu_b1){menu_b1.setBackground(Color.black); menu_b1.setForeground(Color.white);}
    if(e.getSource() == menu_b2){menu_b2.setBackground(Color.black); menu_b2.setForeground(Color.white);}
    if(e.getSource() == menu_b3){menu_b3.setBackground(Color.black); menu_b3.setForeground(Color.white);}  
    if(e.getSource() == menu_b4){menu_b4.setBackground(Color.black); menu_b4.setForeground(Color.white);}
    if(e.getSource() == back){back.setBackground(Color.black); back.setForeground(Color.white);}
    if(e.getSource() == back2){back2.setBackground(Color.black); back2.setForeground(Color.white);}
    if(e.getSource() == back3){back3.setBackground(Color.black); back3.setForeground(Color.white);}
    if(e.getSource() == back4){back4.setBackground(Color.black); back4.setForeground(Color.white);}
    if(e.getSource() == back5){back5.setBackground(Color.black); back5.setForeground(Color.white);}
    if(e.getSource() == back3C){back3C.setBackground(Color.black); back3C.setForeground(Color.white);}
    if(e.getSource() == create){create.setBackground(Color.black); create.setForeground(Color.white);}
    if(e.getSource() == join){join.setBackground(Color.black); join.setForeground(Color.white);}
    if(e.getSource() == joinTo){joinTo.setBackground(Color.black); joinTo.setForeground(Color.white);}
    if(e.getSource() == proceed){proceed.setBackground(Color.black); proceed.setForeground(Color.white);}
    if(e.getSource() == proceedTo){proceedTo.setBackground(Color.black); proceedTo.setForeground(Color.white);}
    if(e.getSource() == proceedC){proceedC.setBackground(Color.black); proceedC.setForeground(Color.white);}
    if(e.getSource() == proceedGo){proceedGo.setBackground(Color.black); proceedGo.setForeground(Color.white);}
    if(e.getSource() == send){send.setBackground(Color.black); send.setForeground(Color.white);}
    if(e.getSource() == bconn){bconn.setBackground(Color.black); bconn.setForeground(Color.white);}
    if(e.getSource() == refresh){refresh.setBackground(Color.black); refresh.setForeground(Color.white);}
  }
  public void mouseExited(MouseEvent e)
  {
    if(e.getSource() == menu_b1){menu_b1.setBackground(Color.white); menu_b1.setForeground(Color.black);}
    if(e.getSource() == menu_b2){menu_b2.setBackground(Color.white); menu_b2.setForeground(Color.black);}
    if(e.getSource() == menu_b3){menu_b3.setBackground(Color.white); menu_b3.setForeground(Color.black);}  
    if(e.getSource() == menu_b4){menu_b4.setBackground(Color.white); menu_b4.setForeground(Color.black);}
    if(e.getSource() == back){back.setBackground(Color.white); back.setForeground(Color.black);}
    if(e.getSource() == back2){back2.setBackground(Color.white); back2.setForeground(Color.black);}
    if(e.getSource() == back3){back3.setBackground(Color.white); back3.setForeground(Color.black);}
    if(e.getSource() == back4){back4.setBackground(Color.white); back4.setForeground(Color.black);}
    if(e.getSource() == back5){back5.setBackground(Color.white); back5.setForeground(Color.black);}
    if(e.getSource() == back3C){back3C.setBackground(Color.white); back3C.setForeground(Color.black);}
    if(e.getSource() == create){create.setBackground(Color.white); create.setForeground(Color.black);}
    if(e.getSource() == join){join.setBackground(Color.white); join.setForeground(Color.black);}
    if(e.getSource() == joinTo){joinTo.setBackground(Color.white); joinTo.setForeground(Color.black);}
    if(e.getSource() == proceed){proceed.setBackground(Color.white); proceed.setForeground(Color.black);}
    if(e.getSource() == proceedTo){proceedTo.setBackground(Color.white); proceedTo.setForeground(Color.black);}
    if(e.getSource() == proceedC){proceedC.setBackground(Color.white); proceedC.setForeground(Color.black);}
    if(e.getSource() == proceedGo){proceedGo.setBackground(Color.white); proceedGo.setForeground(Color.black);}
    if(e.getSource() == send){send.setBackground(Color.white); send.setForeground(Color.black);}
    if(e.getSource() == bconn){bconn.setBackground(Color.white); bconn.setForeground(Color.black);}
    if(e.getSource() == refresh){refresh.setBackground(Color.white); refresh.setForeground(Color.black);}
  }
  public void mousePressed(MouseEvent e)
  {
   
    //x = e.getX();
    //y = e.getY();
    //cordii();
    
    
   
    
 }
  
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  //implementing ActionListener method
  
  public void actionPerformed(ActionEvent e)
  {
    if(e.getSource() == menu_b1)
    {
      menu.setVisible(false);
      About.setVisible(false);
      z2 = false;
      panelCreateServer();
    }
    
    if(e.getSource() == menu_b2)
    {
      menu.setVisible(false);
      About.setVisible(false);
      panelFindServer();
    }
    
    if(e.getSource() == back)
    {
      menu.setVisible(true);
      About.setVisible(true);
      Pserver.setVisible(false);
      per.setVisible(false);
      len = 0; per.setText(""); th.stop(); join.setVisible(false);
    }
    
    if(e.getSource() == back2)
    {
      menu.setVisible(true);
      About.setVisible(true);
      Pfind.setVisible(false);
      joinTo.setVisible(false);
      refresh.setVisible(false);
    }
    
    if(e.getSource() == back5)
    {
      menu.setVisible(true);
      About.setVisible(true);
      connect.setVisible(false);
      
    }
    
    if(e.getSource() == back3)     //for server
    {
      nickName.setVisible(false);
      Pserver.setVisible(true);
      pb=false; len=0;  repaint();
      per.setVisible(false);    
    }
    
    if(e.getSource() == back3C)     //for client
    {
      nickNameC.setVisible(false);
      validPanel.setVisible(false);
      passwordPanel.setVisible(false);
      proceedGo.setVisible(false);
      connect.setVisible(true);
    }
    
    if(e.getSource() == back4)
    {
      seal = 0;
      Lonline.removeAll();
      chatWindow.setVisible(false);
      menu.setVisible(true);
      clientCount=0;
      pb=false; repaint();
      setSize(500,300);
      About.setVisible(true);
      protec = false;
      z1 = false;  z2=false;
      try{SocketHandling.gateServer.close(); SocketHandling.th.stop(); } catch(Exception g){}
    }
    
    if(e.getSource() == create)
    {
      len = 0; per.setText("");
      per.setVisible(true);
      try
      {
      char c = tname.getText().charAt(0); 
      if(Character.isLetter(c))
      {
        pb = true;
        th = new Thread(this); 
        repaint();
        th.start();
      }
      else
      {
        tname.setText("");  tname.requestFocus();
      }
      }
      catch(Exception f){}
      
    }
    
    
    if(e.getSource() == join )
    {
      Pserver.setVisible(false);
      per.setVisible(false);
      panelNickName();
    }
    
    
    if(e.getSource() == menu_b3)
    {
      Toolkit.getDefaultToolkit().beep();
      dispose();
    }
    
    if(e.getSource() == menu_b4)
    {
      menu.setVisible(false);
      About.setVisible(false);
      panelConnect();  z2 = false; z3=false;
    }
    
    
    if(e.getSource() == proceed)                                                                             //for server ------creating gateServer    
    {
      try
      {
      char c = tnic.getText().charAt(0); 
      if(Character.isLetter(c))
      {
        nickName.setVisible(false);
        seal = 1;
        clientCount+=1;
        Lonline.add(tnic.getText()+"(S)"); Lonline.add(" ");
        panelChat(); chatWindow.setVisible(true);
        SocketHandling f = new SocketHandling(); f.start(); 
      }
      else
      {
        tnic.setText("");  tnic.requestFocus();
      }
      }
      catch(Exception f){}
  
      
    }
    
    
    if(e.getSource() == proceedC)      //for client     
    {
      try
      {
      char c = tnicC.getText().charAt(0); 
      if(Character.isLetter(c))
      {
        int chk=0;
        for(int i =0;i<tmp2.length;i++){ if(tnicC.getText().equals(tmp2[i])){chk = 1; break;}  }
        if(chk ==0)
        {
          z2 = true; z1 = false; z3=false;
          lnicC.setText("");
          connectingServer obj = new connectingServer(iconn);   
        }
        else{lnicC.setText("this name is already taken"); }
      }
      else
      {
        tnicC.setText("");  tnicC.requestFocus();
      }
      }
      catch(Exception f){}
      nickNameC.setVisible(false);
      panelChat();
      chatWindow.setVisible(true);
      z3=true; z2=false; z1=false;
      connectingServer obj = new connectingServer(iconn); 
  }
    
    
    if(e.getSource() == proceedGo)
    {
       z2 = false; connect.setVisible(false);  panelNickNameC();
    }
    
    
   
    if(e.getSource() == bconn)
    {
      z1 = true; z2=false; z3=false;
      connectingServer.open = false;
      passwordPanel.setVisible(false);
      validPanel.setVisible(false); 
      try
      {
        if(C1 == true)
        {
          String tcon = tconn.getText();   
          iconn = InetAddress.getByName(tcon); 
          connectingServer obj = new connectingServer(iconn);
        }
        if(C2 == true)
        {
          byte b[] = new byte[4];  
          b[0] = (byte)Integer.parseInt(sm1.getText());
          b[1] = (byte)Integer.parseInt(sm2.getText());
          b[2] = (byte)Integer.parseInt(sm3.getText());
          b[3] = (byte)Integer.parseInt(sm4.getText());
          iconn = InetAddress.getByAddress(b); 
          connectingServer obj = new connectingServer(iconn);
        }
     
      }
      catch(Exception g){}
      
    }
    
    
    if(e.getSource() == proceedTo)
    {
      if(tp.getText().equals(tpassword_c)){connect.setVisible(false);  z2 = false;  panelNickNameC();}
      else{passwordPanel.setVisible(false); z2 = false; validPanel.setVisible(true);}
    }
  
  }
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  //implementing ItemListener methods
  
  public void itemStateChanged(ItemEvent e)
  {
    if(e.getSource() == pass)
    { 
      if(pass.getState() ==true)
      {
        tpassword.setEnabled(true); tpassword.setBackground(Color.white); protec = true;
      }
      else if(pass.getState() == false)
      {
        tpassword.setEnabled(false);  tpassword.setText(""); tpassword.setBackground(Color.lightGray); protec = false;
      }
      
      
    }
    
    if(e.getSource() == serverlist)
    {
      int n = serverlist.getSelectedIndex();
      if(n % 2 ==0)
        joinTo.setEnabled(true);
      else
        joinTo.setEnabled(false);
    }
    
    
    if(e.getSource() == c1)
    {
      C1= true;  C2=false;  conn.setText("Enter Server-PC name: "); tray1.setVisible(true); tray2.setVisible(false); GUI.passwordPanel.setVisible(false);
    }
    
    if(e.getSource() == c2)
    {
      C2= true;  C1=false;  conn.setText("Enter Server-IP:      "); tray1.setVisible(false); tray2.setVisible(true); GUI.passwordPanel.setVisible(false);
    }

    
  }
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  //implementing FocusListener methods
  
  public void focusLost(FocusEvent e)
  {
    if(e.getSource() == number)
    {
      int z = Integer.parseInt(number.getText());
      if(!(z >0))
      {
        number.setText("1");
      }
    }
  }
  
  public void focusGained(FocusEvent e){}
  
  
}//class GUI ends

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------
//Socket-Programming---------------Socket Programming----------------------------------------Socket Programming-------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------



class SocketHandling implements Runnable                                             // For Server
{
  static ServerSocket gateServer;
  Socket gateClient;
  static Thread th;
  DataOutputStream out;
  DataInputStream in;
  
  public void start() throws IOException
  { 
    gateServer = new ServerSocket(3785);
    gateClient = null;
    th = new Thread(this);
    th.start();
  }
  
  public void run() 
  {
    try
    {
      while(true)
      {
        gateClient = gateServer.accept();
        in = new DataInputStream(gateClient.getInputStream());
        String r = in.readLine(); String r_name = in.readLine(); 
        in.close();
        int len = GUI.Lonline.getItemCount();
        String tmp = "";
        for(int i=0;i<len;i++){ tmp = tmp+GUI.Lonline.getItem(i); }
        
        if(r.equals("ask"))
        {
          gateClient = gateServer.accept();
          out = new DataOutputStream(gateClient.getOutputStream()); 
          out.writeBytes(""+GUI.protec+"\n"+GUI.tpassword.getText()+"\n"+GUI.tname.getText()+"\n"+GUI.number.getText()+"\n"+GUI.clientCount+"\n"+tmp);
          out.close();
        }
        
        if(r.equals("name"))
        { 
          GUI.Lonline.add(r_name); GUI.Lonline.add(" "); GUI.clientCount+=1;
          GUI.chatOnline.setText("Online: "+GUI.clientCount);
          
        }
        
        if(r.equals("update"))
        {
          len = GUI.Lonline.getItemCount();
          tmp = "";
          for(int i=0;i<len;i++){ tmp = tmp+GUI.Lonline.getItem(i); }
          gateClient = gateServer.accept();
          out = new DataOutputStream(gateClient.getOutputStream()); 
          out.writeBytes(GUI.clientCount+"\n"+tmp);
          out.close();
        }
        
       
      }
    }
    catch(Exception e){}
    
  }

}

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------

class connectingServer implements Runnable                                      //for client
{
 static Thread thf;   
 InetAddress iconn;
 Socket ss;
 static boolean open;
 
 connectingServer(InetAddress iconn)
 {
   thf = new Thread(this);
   this.iconn = iconn;
   open = false;
   thf.start();
 }
 
   synchronized public void run()
 {
   try
       {  
        ss = new Socket(iconn,3785);  
        if(ss.isConnected()) 
        {  
          if(GUI.z1 == true)                                                            //this for check protection
          {
            DataOutputStream out = new DataOutputStream(ss.getOutputStream());
            out.writeBytes("ask");  
            out.close();
            
            ss = new Socket(iconn,3785);
            DataInputStream in = new DataInputStream(ss.getInputStream()); 
            String r = in.readLine(); GUI.protec_c = r; 
            r = in.readLine();        GUI.tpassword_c = r;  
            r = in.readLine();        GUI.tname_c = r;  
            r = in.readLine();        GUI.number_c = r;          
            r = in.readLine();        GUI.clientCount_c = r;    int count = Integer.parseInt(r);
            r = in.readLine();        GUI.tmp2 = new String[count]; GUI.tmp2 = r.split(" ");
            in.close();
            
            if(GUI.protec_c.equals("true")) { GUI.passwordPanel.setVisible(true);}
            if(GUI.protec_c.equals("false")){GUI.passwordPanel.setVisible(false); GUI.validPanel.setVisible(false); GUI.proceedGo.setVisible(true); }
          }//z1 ends
          
          else if(GUI.z2 == true)                                                           
          { 
            DataOutputStream out = new DataOutputStream(ss.getOutputStream());
            out.writeBytes("name\n"+GUI.tnicC.getText());  
            out.close();
            
          }//z2 ends
          
          else if(GUI.z3 == true)                                                           
          { 
            DataOutputStream out = new DataOutputStream(ss.getOutputStream());
            out.writeBytes("update");  
            out.close();
            ss = new Socket(iconn,3785);
            DataInputStream in = new DataInputStream(ss.getInputStream()); 
            String r = in.readLine();  GUI.clientCount_c = r;    int count = Integer.parseInt(r);
            GUI.clientCount = count;
            r = in.readLine();        GUI.tmp2 = new String[count]; GUI.tmp2 = r.split(" ");
            in.close();
            GUI.chatOnline.setText("Online: "+GUI.clientCount);
            GUI.Lonline.removeAll();
            for(int i=0;i<GUI.tmp2.length;i++){GUI.Lonline.add(GUI.tmp2[i]);GUI.Lonline.add(" ");}
          }//z3 ends
          
        }
            ss.close(); thf.stop();  
   }
       
   
   catch(Exception f){}
   }
  
}

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------