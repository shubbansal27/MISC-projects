-- phpMyAdmin SQL Dump
-- version 2.11.10.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Feb 18, 2014 at 12:42 AM
-- Server version: 5.0.77
-- PHP Version: 5.3.3

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `anagram`
--

-- --------------------------------------------------------

--
-- Table structure for table `login`
--

CREATE TABLE IF NOT EXISTS `login` (
  `Name` text NOT NULL,
  `Username` text NOT NULL,
  `Password` text NOT NULL,
  `Gender` text NOT NULL,
  `EMailID` text NOT NULL,
  `Institute` text NOT NULL,
  `Number` text NOT NULL,
  `Time` text NOT NULL,
  `NOL` text NOT NULL,
  `VL` text NOT NULL,
  `score` int(11) NOT NULL default '0',
  `count` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `login`
--

INSERT INTO `login` (`Name`, `Username`, `Password`, `Gender`, `EMailID`, `Institute`, `Number`, `Time`, `NOL`, `VL`, `score`, `count`) VALUES
('Satyam Mishra', 'whythen', 'hahaha', 'Male', 'satyam.mishra333@gmail.com', 'LNMIIT', '9828346637', '0:0:0', '1', '1', 10, 0),
('Ashwin Bhoomi', 'niwhsa', 'ashwin', 'Male', 'sh_acd@yahoo.co.in', 'LNMIIT', '9460477958', '0:0:0', '0', '0', 0, 0),
('Ankit Sharma', 'iankit', 'qazplm', 'Male', 'ankit2912s@gmail.com', 'LNMIIT', '9928532284', '0:0:0', '0', '0', 0, 0),
('Vikas Aggarwal', 'vikas17a', 'vikas231269', 'Male', 'vikas17a@gmail.com', 'LNMIIT', '9950266430', '0:0:0', '0', '0', 0, 0),
('Anjali Agrawal', 'arg', 'twilight', 'Female', 'anjalif1111@gmail.com', 'THE LNMIIT', '9928750785', '0:0:0', '1', '1', 0, 0),
('Rahul Anand  Sharma', 'klaus', 'erudite', 'Male', 'rahulanand@ieee.org', 'The LNMIIT', '9460367680', '0:0:0', '0', '1', 0, 0),
('lokendra ahuja', 'lokendra', 'lokendra', 'Male', 'lokendra.ahuja@gmail.com', 'LNMIIT', '7597631200', '0:0:0', '0', '1', 0, 0),
('suryateja voruganti', 'surya1608', 'suryalab', 'Male', 'surya1608@iitj.ac.in', 'IIT Rajasthan,Jodhpur', '9828798353', '0:0:0', '1', '1', 0, 0),
('Dipesh palod', 'dipeshpalod', 'shubh', 'Male', 'dipeshpalod@gmail.com', 'LNMIIT', '8764144829', '0:0:0', '0', '1', 30, 0),
('Shweta Srivastava', 'shweta2210', 'shweta', 'Female', 'shweta.s2210', 'LNMIIT', '9636049859', '0:0:0', '0', '1', 0, 0),
('Rishabh Baid', 'erudite', '147852', 'Male', 'rishabhbaid1@gmail.com', 'The LNMIIT', '9782311101', '0:0:0', '1', '1', 70, 0),
('Nikunj Gupta', 'stan', 'justforfun26', 'Male', 'nikunjboss@gmail.com', 'LNMIIT', '9413801201', '0:0:0', '0', '1', 0, 0),
('Piyush Jain', 'piyushkiller', 'kreimeronline', 'Male', 'piyushorton2000@gmail.com', 'LNMIIT', '8764060559', '0:0:0', '0', '1', 0, 0),
('Swagata Hazra Chowdhury', 'Swagata', '7665970385', 'Female', 'karolene.21@gmail.com', 'MITS', '7665970385', '0:0:0', '0', '1', 0, 0),
('Arihant Sethia', 'firebolt', 'harrypotter', 'Male', 'arihant29101991@gmail.com', 'LNMIIT', '8764131690', '0:0:0', '0', '1', 0, 0),
('Pranjal successena', 'y11uc166', '546077', 'Male', 'pranjal.success166@gmail.com', 'lnmiit', '9530384720', '0:0:0', '0', '1', 0, 0),
('vinay suthar', 'vinay', 'vinay', 'Male', 'vinay13893@gmail.com', 'LNMIIT', '9530476878', '0:0:0', '0', '1', 0, 0),
('manohar kuse', 'swaroopcool21', 'commonunix', 'Male', 'swaroopcool21@gmail.com', 'LNMIIT', '9799809089', '0:0:0', '0', '1', 0, 0),
('Vikas Mangal', 'vikasmangal', '12qwaszx', 'Male', 'victor.mangal@gmail.com', 'The LNMIIT', '9462798086', '0:0:0', '0', '1', 0, 0),
('Yatendra Mohan Goyal goyal', 'yat', 'mohan', 'Male', 'yatendra16041990@gmail.com', 'lnmiit', '9468585007', '0:0:0', '0', '0', 0, 0),
('Ashish Soni', 'ShadowW', 'australopithecus', 'Male', 'ashishsoni2010@gmail.com', 'LNMIIT', '9413826601', '0:0:0', '0', '0', 0, 0),
('ankur agnihotri', 'agni', 'chawal', 'Male', 'ankuragnihotri93@gmail.com', 'lnmiit', '9530384712', '0:0:0', '0', '1', 0, 0),
('Bunny Praneeth', 'Bunny', 'sonapraneeth', 'Male', 'praneetha@iitj.ac.in', 'IIT Rajasthan', '7597369279', '0:0:0', '0', '1', 0, 0),
('Samarth Sikand', 'sammyman', 'garvit', 'Male', 'sikandsamarth@yahoo.com', 'LNMIIT', '9001893351', '0:0:0', '0', '0', 0, 0),
('Ankur Gupta', 'Ankur', 'Ankur', 'Male', 'sonu.ankurgupta@gmail.com', 'the lnmiit,jaipur', '9530476878', '0:0:0', '0', '0', 0, 0),
('akhil gupta', 'akki', 'akkiakki', 'Male', 'akhilgupta0072@gmail.com', 'lnmiit', '7665817495', '0:0:0', '1', '1', 0, 0),
('Garvit Sharma', 'admin', 'adminroot112', 'Male', 'garvits45@gmail.com', 'LNMIIT', '9530135696', '0:0:0', '1', '1', 0, 0),
('shubham gupta', 'shubham', '12345', 'Male', 'shubhamguptaenterintoit@gmail.com', 'LNMIIT', '9413719939', '0:0:0', '0', '1', 5, 0),
('garvit bansal', 'garvit', 'corpulance', 'Male', 'garvitbansal244@gmail.com', 'lnmiit', '9610728532', '0:0:0', '0', '0', 0, 0),
('K RAJ KOUSHIK  REDDY', 'rajkoushik', '2577965', 'Male', 'rajkoushik@gmail.com', 'lnmiit', '9783218418', '0:0:0', '1', '1', 35, 0),
('Vaibhav Dwivedi', 'vaibhavrocks09', 'suddenhappen', 'Male', 'vaibhavrocks09@gmail.com', 'The LNMIIT', '9530456491', '0:0:0', '0', '0', 0, 0),
('Yogendra Goyal', 'yogendra', '9461337001', 'Male', 'yrgoyal@iitj.ac.in', 'iit', '9461337001', '0:0:0', '0', '0', 0, 0),
('shubham bansal', 'shubham27', 'bansal', 'Male', 'shubbansal27@gmail.com', 'LNMIIT', '9468594203', '0:0:0', '1', '1', 10, 0),
('Abhinav Malik', 'Checkmate', 'abhinav', 'Male', 'abhinav12410@gmail.com', 'LNMIIT', '9610992861', '0:0:0', '0', '0', 0, 0),
('test test', 'test', 'test', 'Male', 'test', 'test', 'test', '0:0:0', '0', '1', 40, 0),
('Rahul Anand Sharma', 'lucifer', 'erudite', 'Male', 'rahulanand@ieee.org', 'The LNMIIT', '9460367680', '0:0:0', '1', '1', 205, 0),
('pranjal successena', 'pranjal', '546077', 'Male', 'pranjal.success166@gmail.com', 'lnmiit', '9530384720', '0:0:0', '0', '0', 0, 0),
('UTKARSH PYNE', 'infern0', 'infern0', 'Male', 'utkarsh.pyne@mail.lnmiit.ac.in', 'LNMIIT', '9772582493', '0:0:0', '1', '1', 0, 0),
('K RAJ KOUSHIK REDDY', 'rajkoushikreddy', 'koushik', 'Male', 'rajkoushik@gmail.com', 'lnmiit', '9783218418', '0:0:0', '0', '0', 0, 0),
('garvitb bansal', 'garvitb', 'garvitb', 'Male', 'garvitbansal244@gmail.com', 'LNMIIT', '9610728532', '0:0:0', '0', '1', 5, 0),
('pranjal successena', 'Pran', 'anagram', 'Male', 'pranjal.success166@gmail.com', 'lnmiit', '9530384720', '0:0:0', '0', '0', 0, 0),
('Yatendra Mohan Goyal goyal', 'yatendra', 'mohan', 'Male', 'yatendra16041990@gmail.com', 'lnmiit', '9468585007', '0:0:0', '0', '1', 5, 0),
('dalbir singh', 'y10uc101', 'dalbirjanjua', 'Male', 'dalbirking@gmail.com', 'lnmiit', '8107771483', '0:0:0', '0', '0', 0, 0),
('dalbir singh', 'dalbir', 'dalbirjanjua', 'Male', 'dalbirking@gmail.com', 'lnmiit', '8107771483', '0:0:0', '1', '1', 270, 0),
('Dedipya Jain', 'vipul', 'premjkl', 'Male', 'erdedipyajain@gmail.com', 'Lnmiit', '9460201475', '0:0:0', '0', '1', 0, 0),
('Pranjal Srivastava', '232', '123456', 'Male', 'psrivastava733@gmail.com', 'LNMIIT', '7597334942', '0:0:0', '0', '1', 0, 0),
('niwas kumar', 'niwas', '99314877', 'Male', 'niwask3@gmail.com', 'The LNM Institute of Information Technology', '7597893983', '0:0:0', '0', '1', 0, 0),
('Shubhanshu Gautam', 'Hades', 'kalashnikov', 'Male', 'hades_ansh@hotmail.com', 'LNMIIT', '7597167591', '0:0:0', '0', '1', 0, 0),
('chakshu goyal', 'tiger', '99314877', 'Male', 'goyal.chakshu@gmail.com', 'lnmiit', '9549297594', '0:0:0', '0', '0', 0, 0),
('himanshu ratnam', 'ratnam', 'ratnam', 'Male', 'ratnamhimanshu70@yahoo.in', 'LNMIIT', '7597167540', '0:0:0', '0', '1', 0, 0),
('vinit agarwal', 'vinitgrwl', 'abcd', 'Male', 'vinitgrwl6@gmail.com', 'lnmiit', '9468595841', '0:0:0', '0', '1', 0, 0),
('aviral juneja', 'avilegend', '21031992', 'Male', 'ibskoolavi@gmail.com', 'LNMIIT', '8107789474', '0:0:0', '0', '0', 0, 0),
('yatendra mohan goyal', 'moriarity', 'mohan', 'Male', 'yatendra16041990@gmail.com', 'lnmiit', '9468585007', '0:0:0', '0', '0', 0, 0),
('atul jalan', 'hellrock', '801762aj', 'Male', 'aj.lnmiit@gmail.com', 'THE LNM IIT', '8003180400', '0:0:0', '0', '1', 0, 0),
('shivanshu goyal', 'shivam', 'shivamshivam', 'Male', 'shiv.enggr@gmail.com', 'ism,dhanbad,jharkhand', '08051010684', '0:0:0', '0', '1', 0, 0),
('Tushar Mathur', 'Tushar', 'TushAr', 'Male', 'tusharmathur23@gmail.com', 'Geetanjali Institute of Technical Studies', '9783210356', '0:0:0', '0', '0', 0, 0),
('abhinav  johri', 'johri', 'arvindadiga', 'Male', 'abhinavinsomniac@gmail.com', 'lnmiit', '9530384706', '0:0:0', '0', '1', 0, 0),
('Abhinav Choudhary', 'abhinav02', 'oxygen08', 'Male', 'tinkabhi13@gmail.com', 'LNMIIT', '7597144588', '0:0:0', '1', '1', 0, 0),
('Adesh Gupta', 'unknown', 'adeshgupta', 'Male', 'adeshg.12@gmail.com', 'lnmiit', '9468864929', '0:0:0', '0', '1', 0, 0),
('Aditi Jangid', 'y11uc017', '742337', 'Female', 'aditijangid5@gmail.com', 'lnmiit', '7597891015', '0:0:0', '0', '0', 0, 0),
('Pratyaksh Golash', 'Prat', 'Prat22', 'Male', 'pratyakshgolash@gmail.com', 'LNMIIT', '7597313052', '0:0:0', '0', '0', 0, 0),
('test test', 'test11', 'test11', 'Male', 'lklkl', 'ffyfy', '1234567890', '0:0:0', '0', '1', 0, 0),
('Rikin Raheja', 'rikinraheja', 'trytrytry', 'Male', 'rikinraheja@gmail.com', 'LNMIIT', '7665520462', '0:0:0', '0', '1', 0, 0),
('avanish gupta', 'avanishleo', 'ramram123', 'Male', 'gupavanish@gmail.com', 'The LNMIIT', '9680685188', '0:0:0', '0', '0', 0, 0),
('anshul gaur', 'anshul', 'anshul', 'Male', 'anshullgaur@gmail.com', 'lnmiit', '9414452579', '0:0:0', '0', '0', 0, 0),
('avanish gupta', 'avagup', 'ramram123', 'Male', 'gupavanish@gmail.com', 'The LNMIIT', '9680685188', '0:0:0', '1', '1', 60, 0),
('Pratyaksh golash', 'Pratyaksh', 'Prat22', 'Male', 'pratyakshgolash@gmail.com', 'LNMIIT', '7597313052', '0:0:0', '0', '1', 0, 0),
('AGAM  JAIN', 'particle', 'adi2007', 'Male', 'agamrjain@gmail.com', 'LNMIIT,JAIPUR', '9530384738', '0:0:0', '0', '1', 0, 0),
('aviral juneja', 'aviral', '21031992', 'Male', 'ibskoolavi@gmail.com', 'LNMIIT', '8107789474', '0:0:0', '1', '1', 65, 0),
('Yatendra Mohan goyal', 'gambler', 'mohan', 'Male', 'yatendra16041990@gmail.com', 'lnmiit', '9468585007', '0:0:0', '0', '1', 15, 0),
('garvitba bansal', 'garvitba', 'corpulance', 'Male', 'garvitbansal244@gmail.com', 'LNMIIT', '9411202582', '0:0:0', '0', '0', 0, 0),
('dalbir singh', 'jj', 'janjua', 'Male', 'dalbirking@gmail.com', 'lnmiit', '8107771483', '0:0:0', '1', '1', 0, 0),
('Anirudh Agarwal', 'a1anirudh', 'anagram', 'Male', 'a1anirudh@gmail.com', 'LNMIIT', '9460478956', '0:0:0', '0', '1', 0, 0),
('pranjal successena', 'Megatron', '546077', 'Male', 'pranjal.success166@gmail.com', 'lnmit', '9530384720', '0:0:0', '0', '0', 0, 0),
('garvit1 bansal', 'garvit1', 'garvit', 'Male', 'garvitbansal244@gmail.com', 'lnmiit', '9610728532', '0:0:0', '0', '1', 5, 0),
('Aman Dubey', 'amandubey91', 'amshdubey', 'Male', 'amandubey91@gmail.com', 'LNMIIT', '9530386123', '0:0:0', '0', '1', 10, 0),
('mochan solanki', 'mochan', 'gurudev6', 'Male', 'panther6665@gmail.com', 'lnmittal', '9530384775', '0:0:0', '0', '1', 0, 0),
('Shefali Roy', 'y10uc302', 'imkool16', 'Female', 'shefali.roy8@gmail.com', 'LNMIIT', '9461704323', '0:0:0', '0', '1', 0, 0),
('Aakriti Srivastava', 'aks', 'anagramaks', 'Female', 'aakriti.sri90@gmail.com', 'lnmiit', '8107376599', '0:0:0', '0', '1', 0, 0),
('Gaurav Narula', 'gauravnr1507', 'sunitachhabra', 'Male', 'gauravnr1507@gmail.com', 'The LNMIIT', '9461555756', '0:0:0', '0', '1', 0, 0),
('varun bhardwaj', 'varunb92', 'varun', 'Male', 'varunb.92@gmail.com', 'lnmiit', '8875868767', '0:0:0', '0', '1', 0, 0),
('akash jindal', 'akash407', '9933190301', 'Male', 'akash407@gmail.com', 'THE LNMIIT', '7597167588', '0:0:0', '0', '1', 0, 0),
('Abhishek Gupta', 'abhi92', '28081992', 'Male', 'shanky.impossible@gmail.com', 'LNMIIT', '9530298249', '0:0:0', '1', '1', 5, 0),
('Akash Nagpal', 'akanagpal', '9460370422', 'Male', 'akanagpal@gmail.com', 'LNM IIT,Jaipur', '9460370422', '0:0:0', '0', '1', 0, 0),
('Shubham Jain', 'sony111', '1111', 'Male', 'shubham.killme@gmail.com', 'LNMIIT', '9950998725', '0:0:0', '1', '1', 190, 0),
('PRADEEP REDDY', 'lnmiit', 'lnmiit', 'Male', 'kpkr2709@gmail.com', 'lnmiit', '7597167510', '0:0:0', '0', '0', 0, 0),
('Archit Garg', 'architsmat38', 'debalo76', 'Male', 'sam.garg38@gmail.com', 'LNMIIT', '9772656858', '0:0:0', '0', '0', 0, 0),
('SHUBHIKA SETH', 'mastermind', 'vinayak', 'Female', 'shubhikaseth22@gmail.com', 'lnmiit', '9772676376', '0:0:0', '1', '1', 5, 0),
('Anubhuti Garg', 'Xtreme', 'crazy', 'Female', 'anubhuti.grg@gmail.com', 'lnmiit', '7568271342', '0:0:0', '0', '0', 0, 0),
('Romila Gillella', 'romila', 'romila', 'Female', 'gillella.romila@gmail.com', 'LNMIIT', '9610612305', '0:0:0', '0', '0', 0, 0),
('TARUN KATYAL', 'TARUN', '080992', 'Male', 'tarunkt007@gmail.com', 'USICT,GGSIPU,DELHI', '8860010772', '0:0:0', '0', '0', 0, 0),
('Ashay Tejwani', 'PJKing', 'Dayamax', 'Male', 'ashaytejwani@gmail.com', 'IIT Bombay', '9324111390', '0:0:0', '0', '1', 0, 0),
('ANURAG KANODIA', 'anuragkanodia', '2372011lnmiit', 'Male', 'anuragkanodia@ymail.com', 'lnmiit', '9982798450', '0:0:0', '1', '1', 0, 0),
('anuja tayal', 'awesome', 'boom', 'Male', 'anujatayal@gmail.com', 'lnmiit', '9772902272', '0:0:0', '1', '1', 0, 0),
('tanvi sarin', 'tanvi', 'urnotsorry', 'Female', 'tanvi.sarin15@gmail.com', 'MITS', '8094491657', '0:0:0', '0', '0', 0, 0),
('Snehil Jain', 'snehiljain', 'nil250689', 'Male', 'snehiljain256@gmail.com', 'JECRC,Jaipur', '9928832019', '0:0:0', '1', '1', 0, NULL),
('fake fake', 'fake1', 'fake1', 'Male', 'sdsds', 'sdsds', 'sdsds', '0:0:0', '0', '1', 0, NULL),
('rishabh diwan', 'rishabhism', '9425429004', 'Male', 'rishabh.ism@gmail.com', 'Indian School of Mines, Dhanbad', '09525172086', '0:0:0', '0', '0', 0, NULL),
('Ashish Agarwal', 'ashish', 'ashish', 'Male', 'ashishagarwal.lnmiit@gmail.com', 'LNMIIT', '9414040967', '0:0:0', '0', '1', 0, NULL),
('mohit jain', 'mohit', 'sanjeel', 'Male', 'mohit.jain@lnmiit.ac.in', 'lnmiit', '9461401589', '0:0:0', '0', '1', 0, NULL),
('yatindra hada', 'yati1992', 'yati1992', 'Male', 'yatindrahada1992@gmail.com', 'LMNIIT', '7714171414', '0:0:0', '0', '1', 0, NULL),
('Rachit  Mathur', 'gon', 'hearthacker', 'Male', 'mathur.rachit20@gmail.com', 'lnmiit', '9461593822', '0:0:0', '1', '1', 10, NULL),
('aa Gupta', 'adi', 'don', 'Male', 'adeshg.12@gmail.com', 'lnmiit', '9468864929', '0:0:0', '0', '1', 0, NULL),
('alpha beta', 'alpha', 'alpha', 'Male', 'rupalsharma19293@gmail.com', 'lnmiit', '1234567891', '0:0:0', '0', '1', 0, NULL),
('dhruv dogra', 'kaynenorth1', 'iitjee2010', 'Male', 'dhruvdogra3@yahoo.in', 'mnit', '9950479339', '0:0:0', '0', '1', 0, NULL),
('Piyush Tiwari', 'FyRe', 'pural', 'Male', 'ktpiyush91@gmail.com', 'LNMIIT', '9414706314', '0:0:0', '1', '1', 10, NULL),
('Deepak Garg', 'dgarg', 'imagine11', 'Male', 'deepakgarg1991@gmail.com', 'LNMIIT', '9694817212', '0:0:0', '0', '1', 0, NULL),
('Anivesh Baratam', 'anivesh93', 'captainbroody', 'Male', 'anivesh93@gmail.com', 'LNMIIT', '+91-9610970304', '0:0:0', '0', '0', 0, NULL),
('Karan  jhanwer', 'karanjhanwer', '1234567890', 'Male', 'karannjhanwerr@gmail.com', 'The LNMIIT', '9351368415', '0:0:0', '0', '0', 0, NULL),
('Rishabh  goel', 'mnm', 'departed', 'Male', 'illidan.magina@gmail.com', 'the lnmiit', '9530384782', '0:0:0', '1', '1', 0, NULL),
('Madhav Chugh', 'Maddy', 'killerboy', 'Male', 'chugh.madhav@gmail.com', 'LNMIIT', '9772982066', '0:0:0', '0', '0', 0, NULL),
('Surbhi Harsh', 'surbhiharsh', 'imawinner', 'Female', 'winner.surbhi@gmail.com', 'mahrishi arvind institute of engineering and technology', '9782153700', '0:0:0', '1', '1', 0, NULL),
('Devyani rohira', 'devyanirohira', 'joejonas', 'Female', 'devyanirohira@gmail.com', 'Poornima college of engineering', '9928480217', '0:0:0', '1', '1', 0, NULL),
('nikhil Goyal', 'nikhil22', 'sunilgoyal', 'Male', 'nikhilgoyal22@gmail.com', 'iit rajasthan', '9461478309', '0:0:0', '1', '1', 0, NULL),
('divyansh tomar', 'trojan', '095334', 'Male', 'divyansh64@gmail.com', 'lnmiit', '8764325402', '0:0:0', '1', '1', 0, NULL),
('Kshitij Gupta', 'kgupta', 'heyyouitsme', 'Male', 'kgupta647@gmail.com', 'JECRC,Jaipur', '8233351246', '0:0:0', '1', '1', 0, NULL),
('Manish Tiwari', 'manish', 'gap247', 'Male', 'mailmemanishtiwari@gmail.com', 'LNMIIT', '9784833813', '0:0:0', '1', '1', 0, NULL),
('ankit kasat', 'kasat', 'kasat555', 'Male', 'ankitiscool1990@gmail.com', 'LNMIIT', '9414966795', '0:0:0', '1', '1', 0, NULL),
('pallavi modani', 'pallavimodani', 'pal07ruchi', 'Female', 'pallavi7891@gmail.com', 'S.K.I.T.', '9460710983', '0:0:0', '1', '1', 0, NULL),
('geetika sinha', 'geetikaAnu', 'geetika', 'Female', 'geetika666@gmail.com', 'MITS', '9413670219', '0:0:0', '1', '1', 0, NULL),
('varun golani', 'varunpiet', 'piet130', 'Male', 'varun.albus@gmail.com', 'poornima institute of engineering and technology', '9928141445', '0:0:0', '1', '1', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `variable`
--

CREATE TABLE IF NOT EXISTS `variable` (
  `id` int(11) NOT NULL default '1',
  `temp` int(11) NOT NULL default '0',
  `temp1` int(11) NOT NULL default '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `variable`
--

INSERT INTO `variable` (`id`, `temp`, `temp1`) VALUES
(1, 53, 0);
