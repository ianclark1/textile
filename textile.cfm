<cfsavecontent variable="text">
This ~is~ a _test_ line^2^
that -breaks- go to "foundeo" :http://foundeo.com/

!http://foundeo.com/images/foundeo.gif!

h3. a heading with lists below

* one
thing here
* two 
* three

# one
# two

bq. this is a *block quote* +from+ ??pete??

|a|b|c|
|you|and|me|

foo bar
-http://foundeo.com/
</cfsavecontent>
<cfsetting enablecfoutputonly="true">
<cffunction name="textile" output="false" returntype="string" hint="Converts plain text to html using textile formatting.">
	<cfargument name="text" type="string" required="true">
	<cfset var html = "">
	<cfset var inUL = false>
	<cfset var inOL = false>
	<cfset var inP = false>
	<cfset var inTable = false>
	<cfset var index = 0>
	<cfset var val = "">
	<cfset var lines = ListLen(arguments.text, Chr(10))>
	<cfset var lineArray = ArrayNew(1)>
	<cfset var line = 1>
	
	<!--- remove all \r's so we just have \n ended lines --->
	<cfset arguments.text = Replace(arguments.text, Chr(13), "", "ALL")>
	<cfif NOT Len(Trim(arguments.text))><cfreturn arguments.text></cfif>
	<cfset ArrayResize(lineArray, lines)>
	<cfset lineArray[line] = "">
	<!--- loop through the text and build a line array --->
	<cfloop from="1" to="#Len(text)#" index="c">
		<cfset index = index + 1>
		<cfset c = Mid(text, c, 1)>
		<cfif c IS Chr(10)>
			<cfset line = line + 1>
			<cfset lineArray[line] = "">
		<cfelse>
			<cfset lineArray[line] = lineArray[line] & c>
		</cfif>
	</cfloop>
	<cfset lines = ArrayLen(lineArray)>
	<!--- loop through again! arrg! it would be nice if I could just
		loop through the text as a list with a \n delimiter but I can't
		since blank lines wouldn't show up.
		Additionally it is much easer to parse line by line, rather than 
		char by char. This is my reasoning for the 2N execution time.
		--->
	<cfloop from="1" to="#lines#" index="index">
		<cfset line = Trim(lineArray[index])>
		<cfif Left(line, 1) IS "*">
			<cfset line = " <li>" & Mid(line, 2, Len(line)-1) & "</li>">
			<cfif NOT inUL>
				<cfset line = "<ul>" & Chr(10) & line>
				<cfset inUL = true>
			<cfelse>
				<cfif index+1 GT lines  OR NOT Len(lineArray[index+1])>
					<cfset line = line & Chr(10) & "</ul>">
					<cfset inUL = false>
				</cfif>
			</cfif>
		<cfelseif Left(line, 1) IS "##">
			<cfset line = " <li>" & Mid(line, 2, Len(line)-1) & "</li>">
			<cfif NOT inUL>
				<cfset line = "<ol>" & Chr(10) & line>
				<cfset inUL = true>
			<cfelse>
				<cfif index+1 GT lines  OR NOT Len(Trim(lineArray[index+1]))>
					<cfset line = line & Chr(10) & "</ol>">
					<cfset inUL = false>
				</cfif>
			</cfif>
		<cfelseif inUL OR inOL>
			<!--- for any list items that may have had a line break --->
			<cfif Len(line)>
				<cfset html = Left(html, Len(html)-6) & " ">
				<cfset line = line & "</li>">
			</cfif>
		<cfelseif Left(line, 1) IS "|">
			<cfif NOT inTable>
				<cfset html = html & "<table>" & Chr(10)>
				<cfset inTable = true>
			</cfif>
			<cfset html = html & " <tr>" & Chr(10)>
			<cfloop list="#line#" index="val" delimiters="|">
				<cfset html = html & "  <td>" & val & "</td>" & Chr(10)>
			</cfloop>
			<cfset line = " </tr>">
			<cfif index IS lines OR Left(Trim(lineArray[index+1]), 1) IS NOT "|">
				<cfset line = line & Chr(10) & "</table>">
				<cfset inTable = false>
			</cfif>
		<cfelseif ReFind("h[0-9]\.", Left(line, 3))>
			<cfset val = Mid(line, 2, 1)>
			<cfset line = "<h" & val & ">" & Trim(Mid(line, 4, Len(line)-3)) & "</h" & val & ">">
		<cfelseif Left(line, 3) IS "bq.">
			<cfset line = "<blockquote>" & Mid(line, 4, Len(line)-3) &  "</blockquote>">
		<cfelseif Len(line) AND (index EQ 1 OR NOT Len(Trim(lineArray[index-1])))>
				<cfset line = "<p>" & line>
				<cfset inP = true>
				<cfif index+1 GT lines OR NOT Len(Trim(lineArray[index+1]))>
					<cfset line = line & "</p>">
					<cfset inP = false>
				<cfelse>
					<cfset line = line & "<br />">
				</cfif>
		<cfelseif inP AND (index+1 GT lines OR NOT Len(Trim(lineArray[index+1])))>
			<cfset line = line & "</p>">
			<cfset inP = false>
		<cfelseif Len(line) AND index NEQ lines AND Len(Trim(lineArray[index+1]))>
			<!--- just a line break --->
			<cfset line = line & "<br />">
		</cfif>
		<cfset html = html & line & Chr(10)>
	</cfloop>
	
	<cfset html = ReReplace(html, "_([^<]+)_","<em>\1</em>","all")>
	<cfset html = ReReplace(html, "\*([^<]+)\*","<strong>\1</strong>","all")>
	<cfset html = ReReplace(html, "\?\?([^<]+)\?\?","<cite>\1</cite>","all")>
	<cfset html = ReReplace(html, "-([^<]+)-","<strike>\1</strike>","all")>
	<cfset html = ReReplace(html, "\+([^<]+)\+","<ins>\1</ins>","all")>
	<cfset html = ReReplace(html, "\^([^<]+)\^","<sup>\1</sup>","all")>
	<cfset html = ReReplace(html, "~([^<]+)~","<sub>\1</sub>","all")>
	<cfset html = ReReplace(html, "\!(http[^ ]+)!", "<img src=""\1"" alt="""" />", "all")>
	<cfset html = ReReplace(html, """([^""]+)"" *: *(http[^< ]+)", "<a href=""\2"">\1</a>", "all")>
	<cfset html = ReReplace(html, "([^""])(https?://[^< ]+)", "\1<a href=""\2"">\2</a>", "all")>
	
	<cfreturn html>
</cffunction>
<!---
<cfoutput>#textile(text)#</cfoutput>
--->
