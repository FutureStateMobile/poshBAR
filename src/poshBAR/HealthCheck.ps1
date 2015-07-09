function Invoke-WebHealthCheck {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true, Position=0, ParameterSetName='requestObject')] [hashtable[]] $request,
        [parameter(Mandatory=$true, Position=0, ParameterSetName='call')] [string] $uri,
        [parameter(Mandatory=$false, Position=1, ParameterSetName='call')] [string[]] $verbs = 'GET',
        [parameter(Mandatory=$false, Position=2, ParameterSetName='call')] [string] $postData = '{}',
        [parameter(Mandatory=$false, Position=3, ParameterSetName='call')] [string] $contentType = 'application/json',
        [parameter(Mandatory=$false, Position=4, ParameterSetName='call')] [int] $timeout = 30000,
        [parameter(Mandatory=$false, Position=5, ParameterSetName='call')] [hashtable] $customHeaders,
        [parameter(Mandatory=$false, Position=6, ParameterSetName='call')] [System.Net.NetworkCredential] $credentials
    )   
    
    if($PsCmdlet.ParameterSetName -eq 'requestObject'){
        $verbsParam = if($request.verbs) {$request.verbs} else { 'GET' }
        $postDataParam = if($request.postData) {$request.postData} else {'{}'}
        $contentTypeParam = if($request.contentType) {$request.contentType} else { 'application/json' }
        $timeoutParam = if($request.timeout) {$request.timeout} else { 30000 }
        $customHeadersParam = if($request.customHeaders) {$request.customHeaders}
        $credentialsParam = if($request.credentials) {$request.credentials}
        
        # recursive call with parameters broken out.
        Invoke-WebHealthCheck -uri $request.uri `
                              -verbs $verbsParam `
                              -postData $postDataParam `
                              -contentType $contentTypeParam `
                              -timeout $timeoutParam `
                              -customHeaders $customHeadersParam `
                              -credentials $credentials 
    return
    }
    
    $totalRequests = $verbs.Count
	$failedCount = 0
    $statusCodes = @()
    
    foreach($verb in $verbs) {
         try {
             $customHeadersParam = if($customHeaders) {$customHeaders}
             $credentialsParam = if($credentials) {$credentials}
             $response = CustomWebRequest -uri $uri `
                                          -headers $customHeadersParam `
                                          -Method $verb `
                                          -contentType $contentType `
                                          -timeout $timeout `
                                          -credentials $credentialsParam `
                                          -postData $postData
                                              
		     $code =  [int][system.net.httpstatuscode]::$($response.StatusCode)
             $statusCode = "$($code) $($response.StatusCode)."
		     
             Write-Host $statusCode -f Green;
             $statusCodes += $statusCode
         } catch {
             Write-Host $_ -f Red
             $statusCodes += $_
             $failedCount++
         } finally {
             if($response) {
                 $response.Close()
                 $response.Dispose()
             }
         }
    }
    
    if($failedCount -gt 0) {
        Write-Host  ($msgs.error_healthchecks_failed -f $failedCount, $totalRequests) -f Red 
    } else {
        Write-Host ($msgs.msg_healthchecks_passed -f $totalRequests, $uri) -f Green   
    }
    
    Write-Output @{
        uri = $uri
        verbs = $verbs
        customHeaders = $customHeaders
        contentType = $contentType
        postData = $postData
        failedRequests = $failedCount
        totalRequests = $totalRequests
        statusCodes = $statusCodes
        status = if($failedCount -eq 0) {'passed'} else {'failed'}
    }
}

<#
    Private Functions
#>

function CustomWebRequest ($uri, $headers, $method, $contentType, $timeout, [System.Net.NetworkCredential] $credentials, $postData) {
	$request = [System.Net.WebRequest]::Create("$uri")
	$request.Method = $method
	$request.AllowAutoRedirect = $false
	$request.ContentType = $contentType
    
    if($headers){
        $headers.Keys | % {
            $request.Headers.add($_, $headers.Item($_))
        }
    }
    
	$request.Timeout = $timeout
	
    if(!$credentials){
        $request.UseDefaultCredentials = $true    
    } else {
        $request.UseDefaultCredentials = $false
        $request.Credentials = $credentials
    }
    
	if($method -ne "GET"){	#for all methods EXCEPT for 'GET' add content
		$buffer = [System.Text.Encoding]::UTF8.GetBytes($postdata)
		$request.ContentLength = $buffer.Length;
		$requestStream = $request.GetRequestStream()
		$requestStream.Write($buffer, 0, $buffer.Length)
		$requestStream.Flush()
		$requestStream.Close()
	}
	
    try {
	   return $request.GetResponse()
    } catch [System.Net.WebException] {
       throw $($_.ToString() -replace 'The remote server returned an error:', '' `
                             -replace '\(', '' `
                             -replace '\)', '').Trim()
    }
}