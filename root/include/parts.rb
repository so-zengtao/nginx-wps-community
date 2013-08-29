# coding: UTF-8

def html_header title
<<EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="description" content="WPSOffice Community"/>
<meta name="keywords" content="wps4linux, wps4ubuntu, wps for linux, wps for ubuntu, kingsoft office4linux, kingsoft office4ubuntu, kingsoft office for linux, kingsoft office for ubuntu, wps office4linux, wps office4ubuntu, wps office for linux, wps office for ubuntu, office4linux, office4ubuntu, office for linux, office for ubuntu, kso4linux, kso4ubuntu, kso for linux, kso for ubuntu, wps community, kingsoft office community, wps office community, office community, kso community"/>
<title>#{title.size == 0 ? "" : "#{title} - "}Kingsoft WPS Office Community</title>
<link rel="stylesheet" type="text/css" href="/css/main.css" media="all" />
<script type="text/javascript">
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-41953861-1', 'wps-community.org');
  ga('send', 'pageview');
</script>
</head>
<body>
<div id="header">
  <div id="logo">
    <a href="/"><img src="/images/logo.png" alt="Kingsoft WPS Community" /></a>
  </div>
  <div>
    <div class="h_navi">
      <span><a href="/">Home</a></span>
      <span><a href="/download.html">Downloads</a></span>
      <span><a href="/forum">Forum</a></span>
      <span><a href="/faq.html">FAQ</a></span>
      <span><a href="/helpus.md">Help us</a></span>
      <span><a href="/dev.html">Dev</a></span>
    </div>
  </div>
</div>
EOF
end

def html_tail
<<EOF
<br/>
<div id="foot"> 
  <span><a href="http://www.ksosoft.com" target="_blank">Official Site</a> | <a href="http://www.wps.cn" target="_blank">Chinese Site</a>
    | <a href="http://community.wps.cn" target="_blank">Chinese Community</a> | <a href="/aboutus.html">About us</a>
    | <a href="mailto:wps_linux@kingsoft.com">Contact us</a></span>
  <span>Copyright &copy; 1989-2013 Kingsoft Office Corporation, All Rights Reserved</span>
</div>
</body>
</html>
EOF
end
