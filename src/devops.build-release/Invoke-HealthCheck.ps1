function Invoke-HealthCheck{

	param(
		[parameter(Mandatory=$true, Position=0)][string] $uri,
		[parameter(Mandatory=$true, Position=1)][System.Xml.XmlNode] $serviceNode,
		[parameter(Mandatory=$false, Position=2)][int] $timeout = 30000
	)

	$requestMethods = "GET","POST","PUT","DELETE"	# Request methods and endpoint
	$uriEndpoint = "HealthCheck/verb"				# Healthcheck service endpoint
	
	$gctsHeader = "Gcts-Identity"
	$domain = "TCPL"											# Domain
	$username = Get-Username $serviceNode.appPool.username		# Username	
	$password = $serviceNode.appPool.password					# Password
	
	Write-Host "username = $username"
	Write-Host "password = $password"
	
	foreach($method in $requestMethods){
		Write-Host "Health check for" $method " - " -nonewline
		
		try {

			$request = [System.Net.WebRequest]::Create("$($uri)/$($uriEndpoint)")
			$request.Method = $method              
			$request.AllowAutoRedirect = $false
			$request.ContentType = "application/json"
			$request.Headers.add($gctsHeader, $username)
			$request.Timeout = $timeout
			
			$request.UseDefaultCredentials = $false
			$request.Credentials = new-object System.Net.NetworkCredential($username, $password, $domain)
			
			if($method -ne "GET"){	#for all methods EXCEPT for 'GET' add content
				$postdata = "{}";
				$buffer = [System.Text.Encoding]::UTF8.GetBytes($postdata)
				$request.ContentLength = $buffer.Length;
				$requestStream = $request.GetRequestStream()
				$requestStream.Write($buffer, 0, $buffer.Length)
				$requestStream.Flush()
				$requestStream.Close()
			}
					
			$response = $request.GetResponse()

			$code = [int][system.net.httpstatuscode]::$($response.StatusCode)
			Write-Host "$($code) $($response.StatusCode)" -f Green;
			
			# The code below reads the response object back
			#$streamReader = New-Object System.IO.StreamReader($response.GetResponseStream())
			#$result = $streamReader.ReadToEnd()
			#Write-Host $result
			
		} catch [System.Net.WebException] {

			$msg = $_ -replace "The remote server returned an error: ", ""  # Strip unneeded text from the error message
			Write-Host "$($msg)" -f Red;
			$script:failed = $true  # Save the fact that the script failed for later

		} finally {
			# Close the response stream
			if ($response) {
				$response.Close()
				Remove-Variable response
			}
		}
	}
	
	# FAIL the build
	if($script:failed) {
		Write-Host "Build Failed" -f Red;
		exit 1
	}
}


Function Get-Username{
	param([parameter(Mandatory=$true, Position=0)][string] $username)
	if($username.Contains('\')){
		try{
			return $username.Split('\')[1]
		}
		catch [System.Net.Exception]{
			return $username; 
		}
	}
	return $username;
}