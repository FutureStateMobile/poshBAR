<#
    .SYNOPSIS 
    Check to see if a website is up and running
    
    .DESCRIPTION
     Check to see if a website is up and running
     
     .EXAMPLE
     Invoke-WebHealthCheck 'http://httpstat.us/200' 'GET'
         
     .EXAMPLE
     Invoke-WebHealthCheck @{uri = 'http://httpstat.us/200'; verbs = 'GET'}
     
     .PARAMETER request
     An object containing all of the fields required to make a Web Health Check. This is used when storing all of the data in an XML document. A hashtable also works.
     
     .PARAMETER uri
     The endpoint we are making the request to.
     
     .PARAMETER verbs
     An array of http verbs [GET, PUT, POST, DELETE, HEAD, OPTIONS, TRACE ].
     
     .PARAMETER postData
     The data you would like to send with the request (will not work with GET).
     
     .PARAMETER contentType
     The Content Type to be sent with the request.
     
     .PARAMETER timeout
     How long to wait before timing out the request.
     
     .PARAMETER customHeaders
     Any additional headers that should be sent with the request.
     
     .PARAMETER credentials
     A [System.Net.NetworkCredential] object containing the credentials to be sent with the request.
#>
function Invoke-WebHealthCheck {
    [CmdletBinding(DefaultParameterSetName='call')]
    param(
        [parameter(Mandatory=$true, Position=0, ParameterSetName='requestObject')] [object] $request,
        [parameter(Mandatory=$true, Position=0, ParameterSetName='call')] [string] $uri,
        [parameter(Mandatory=$false, Position=1, ParameterSetName='call')] [alias('methods')] [string[]] $verbs = 'GET',
        [parameter(Mandatory=$false, Position=2, ParameterSetName='call')] [string] $postData = '{}',
        [parameter(Mandatory=$false, Position=3, ParameterSetName='call')] [string] $contentType = 'application/json',
        [parameter(Mandatory=$false, Position=4, ParameterSetName='call')] [int] $timeout = 30000,
        [parameter(Mandatory=$false, Position=5, ParameterSetName='call')] [object] $customHeaders,
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
    
    $results = @()
    $totalRequests = $verbs.Count
	$failedCount = 0
    
    foreach($verb in $verbs) {
         $customHeadersParam = if($customHeaders) {$customHeaders}
         $credentialsParam = if($credentials) {$credentials}
         $status = CustomWebRequest -uri $uri `
                                      -headers $customHeadersParam `
                                      -Method $verb `
                                      -contentType $contentType `
                                      -timeout $timeout `
                                      -credentials $credentialsParam `
                                      -postData $postData
                                          
        $results +=  @{uri = $uri; status = ('{0} {1}' -f $status.Code, $status.Message); verb = $verb; success = $status.Success}
        if(!$status.Success){
            $failedCount++
        }
    }
  
    Write-Output $results.ForEach({[PSCustomObject]$_}) 
}

<#
    Private Functions
#>

function CustomWebRequest ($uri, $headers, $method, $contentType, $timeout, [System.Net.NetworkCredential] $credentials, $postData) {
    $status = @{}
    try {
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
    	
    	   $response = $request.GetResponse()
           $code =  [int][system.net.httpstatuscode]::$($response.StatusCode)
           $status = @{
               Code = $code
               Message = $response.StatusCode
               Success = $true
           }
        } catch [System.Net.WebException] {
           $message = $($_.ToString() -replace 'The remote server returned an error:', '' `
                                      -replace '\(', '' `
                                      -replace '\)', '' `
                                      -replace '\.', ''
                       ).Trim()

           $statusString = $message.Split(" ", 2)
           $status = @{
               Code = $statusString[0]
               Message = $statusString[1]
               Success = $false
           }

        } finally {
            if($response){
                $response.Close()
                $response.Dispose()
            }
        }
    return $status
}