<cfif IsDefined("form.text")><cfsetting enablecfoutputonly="true">
	<cfinclude template="textile.cfm">
	<cfoutput>#textile(form.text)#</cfoutput>
<cfelse>
<html>
<head>
	<title>Textile AJAX Tester</title>
	<style type="text/css">
		body,td { font-family: verdana, arial; }
		table { width: 50%; }
		#textile textarea { position: absolute; width: 300px; height: 300px; }
		#result { margin-left: 310px; }
		pre { margin-left: 310px; overflow:auto; }
		
	</style>
	<script type="text/javascript" language="javascript">
	   var http_request = false;
	   function makePOSTRequest(url, parameters) {
	      http_request = false;
	      if (window.XMLHttpRequest) { // Mozilla, Safari,...
	         http_request = new XMLHttpRequest();
	         if (http_request.overrideMimeType) {
	            http_request.overrideMimeType('text/xml');
	         }
	      } else if (window.ActiveXObject) { // IE
	         try {
	            http_request = new ActiveXObject("Msxml2.XMLHTTP");
	         } catch (e) {
	            try {
	               http_request = new ActiveXObject("Microsoft.XMLHTTP");
	            } catch (e) {}
	         }
	      }
	      if (!http_request) {
	         alert('Cannot create XMLHTTP instance');
	         return false;
	      }
	      
	      http_request.onreadystatechange = alertContents;
	      http_request.open('POST', url, true);
	      http_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
	      http_request.setRequestHeader("Content-length", parameters.length);
	      http_request.setRequestHeader("Connection", "close");
	      http_request.send(parameters);
	   }
	
	   function alertContents() {
	      if (http_request.readyState == 4) {
	         if (http_request.status == 200) {
	            result = http_request.responseText;
	            document.getElementById("result").innerHTML = http_request.responseText;
	            document.getElementById("resultHtml").innerText = http_request.responseText;            
	         } else {
	            alert('There was a problem with the request.');
	         }
	      }
	   }
	   
	   function updateTextile(frm) {
	  		makePOSTRequest("test_textile.cfm", "text=" + encodeURI( frm.text.value ));
	   }
	</script>
	</head>
<body onload="updateTextile(document.getElementById('textile'));">

<form action="" id="textile">
<textarea name="text" id="text" onkeyup="updateTextile(this.form);">h1. Welcome to Textile
	
Textile is a _way_ to *style* plain text.

!http://foundeo.com/images/foundeo.gif!

Built by "Pete Freitag" : http://www.petefreitag.com sponsored by "Foundeo Inc." : http://foundeo.com/

</textarea>

</form>
<div id="result"></div>
<pre id="resultHtml"></pre>

<hr />
<div align="center" style="color:silver;">
<small>&copy; 2006 <a href="http://foundeo.com/">Foundeo Inc.</a></small>
</div>
</body>
</html>
</cfif>