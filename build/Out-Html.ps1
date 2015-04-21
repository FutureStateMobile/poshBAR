################################################################################
# Out-HTML - converts cmdlets help to HTML format
# Based on Out-wiki by Dimitry Sotnikov (http://dmitrysotnikov.wordpress.com/2008/08/18/out-wiki-convert-powershell-help-to-wiki-format/)
#
# Modify the invocation line at the bottom of the script if you want to document 
# fewer command, subsets or snapins
# Open default.htm to view in frameset or index.htm for index page with links.
################################################################################
# Created By: Vegard Hamar
################################################################################

param($moduleName, $outputDir = "./help")

function FixString {
	param($in = "")
	if ($in -eq $null) {
		$in = ""
	}
	return $in.Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Trim()

}

function Out-HTML {
	param($commands = $null, $outputDir = "./help")

	#create an output directory
	if ( -not (Test-Path $outputDir)) {
		md $outputDir | Out-Null
	}

	# Get help documentation as hashtable.
	$commandsHelp = $commands | get-help -full

	#Generate frame page
	$indexFileName = $outputDir + "/index.htm"
	
	#Generate frameset
@'
<html>
	<head>
		<title>PowerShell Help</title>
	</head>
	<frameset cols="300,*">
		<frame src="./index.htm" />
		<frame src="" name="display"/>
	</frameset>
</html>
'@ | Out-File "$outputDir/default.htm"

	#Generate index
@"
<html>
	<head>
		<title>PowerShell Help</title>
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">
		<style>
		.nav-stacked > li {
		  float: none;
		}
#sidebar > .nav > .nav-menu > a {
  border: 0px;
  border-radius: 0px;
  padding: 5px;
}
.nav-stacked > li + li {
  margin-top: 2px;
  margin-left: 0;
}
.navbar-inner {
  border: 0px;
  border-radius: 0px;
  box-shadow: none;
  padding: 0 10px;
}
		</style>
	</head>
	<body>
      <nav class="navbar">
        <div class="navbar-inner">
          <h3>$moduleName : Index</h3>
        </div>
      </div>
      <div class="container">
        <div class="row">
          <div id="sidebar" class="sidebar-nav span3">
            <ul class="nav nav-tabs nav-stacked">
"@  | out-file $indexFileName


	$commandsHelp | %  {
		"<li class=`"nav-menu`"><a href='" + $_.Name + ".htm' target='display'>$($_.Name)</a></li>"   | out-file $indexFileName -Append
	}

	#Generate all single help files
	$outputText = $null
	foreach ($c in $commandsHelp) {
		$fileName = ( $outputDir + "/" + $c.Name + ".htm" )

@"
<html>
	<head>
		<title>$($c.Name)</title>
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap-theme.min.css">
		<meta charset="utf-8">
	    <meta http-equiv="X-UA-Compatible" content="IE=edge">
	    <meta name="viewport" content="width=device-width, initial-scale=1">
	</head>
	<body>
		<div class=`"container-fluid`">
		<div class=`"page-header`">
			<h1>$($c.Name)</h1>
			<p class=`"lead`">$($c.synopsis)</p>
		</div>
		<div class=`"row`">
			<div class=`"col-md-12`">
				<h2> Syntax </h2>
				<pre>
<code>$(FixString($c.syntax | out-string  -width 2000).Trim())</code></pre>
			</div>

		
			<div class=`"col-md-12`">
				<h2> Detailed Description </h2>
				<div>$(FixString($c.Description  | out-string  -width 2000))</div>
			</div>


			<div class=`"col-md-12`">
				<h2> Related Commands </h2>
				<div>
"@ | out-file $fileName 
		foreach ($relatedLink in $c.relatedLinks.navigationLink) {
			if($relatedLink.linkText -ne $null -and $relatedLink.linkText.StartsWith("about") -eq $false){
				"			<a href='$($relatedLink.linkText).htm'>$($relatedLink.linkText)</a><br/>" | out-file $fileName -Append         
			}
		}
	  
@"
				</div>
			</div>	

			<div class=`"col-md-12`">
				<h2> Parameters </h2>
				<table border='1'>
					<tr>
						<th>Name</th>
						<th>Description</th>
						<th>Required?</th>
						<th>Pipeline Input</th>
						<th>Default Value</th>
					</tr>
"@   | out-file $fileName -Append

				$paramNum = 0
				foreach ($param in $c.parameters.parameter ) {
@"
					<tr valign='top'>
						<td>$($param.Name)&nbsp;</td>
						<td>$(FixString(($param.Description  | out-string  -width 2000).Trim()))&nbsp;</td>
						<td>$(FixString($param.Required))&nbsp;</td>
						<td>$(FixString($param.PipelineInput))&nbsp;</td>
						<td>$(FixString($param.DefaultValue))&nbsp;</td>
					</tr>
"@  | out-file $fileName -Append
				}
				"		</table>
			</div>"  | out-file $fileName -Append
		   
		# Input Type
		if (($c.inputTypes | Out-String ).Trim().Length -gt 0) {
@"

			<div class=`"col-md-12`">
		        <h2> Input Type </h2>
		        <div>$(FixString($c.inputTypes  | out-string  -width 2000).Trim())</div>
		    </div>
"@  | out-file $fileName -Append
		}
   
		# Return Type
		if (($c.returnValues | Out-String ).Trim().Length -gt 0) {
@"
			<div class=`"col-md-12`">
				<h2> Return Values </h2>
				<div>$(FixString($c.returnValues  | out-string  -width 2000).Trim())</div>
			</div>
"@  | out-file $fileName -Append
		}
          
		# Notes
		if (($c.alertSet | Out-String).Trim().Length -gt 0) {
@"
			<div class=`"col-md-12`">
				<h2> Notes </h2>
				<div>$(FixString($c.alertSet  | out-string -Width 2000).Trim())</div>
			</div>
"@  | out-file $fileName -Append
		}
   
		# Examples
		if (($c.examples | Out-String).Trim().Length -gt 0) {
"	        <div class=`"col-md-12`">
			    <h2> Examples </h2>"  | out-file $fileName -Append      
			foreach ($example in $c.examples.example) {
@"
			<h3> $(FixString($example.title.Trim(('-',' '))))</h3>
				<pre>$(FixString($example.code | out-string ).Trim())</pre>
				<div>$(FixString($example.remarks | out-string -Width 2000).Trim())</div>
"@  | out-file $fileName -Append
			}
		}
@"
				</div>
			</div>
		</div>
	</body>
</html>
"@ | out-file $fileName -Append
	}
@"
	</body>
</html>
"@ | out-file $indexFileName -Append
}

Out-HTML (Get-Command -module "$moduleName") "$outputDir"