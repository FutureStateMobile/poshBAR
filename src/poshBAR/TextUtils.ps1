# imports assembly needed for url stuff
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Web

<#
    .SYNOPSIS
        Converts a string from Base64
    
    .PARAMETER str
        A base64 encoded string
    
    .EXAMPLE
        Invoke-FromBase64 $base64EncodedString
#>
function Invoke-FromBase64
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string] $str
    )

    [text.encoding]::utf8.getstring([convert]::FromBase64String($str))
}
Set-Alias fromBase64 Invoke-FromBase64
<#
    .SYNOPSIS
        Converts a string to Base64
    
    .PARAMETER str
        A string to be base64 encoded
    
    .EXAMPLE
        Invoke-ToBase64 $myString
#>
function Invoke-ToBase64
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string] $str
    )

    [convert]::ToBase64String([text.encoding]::utf8.getBytes($str))
}
Set-Alias toBase64 Invoke-ToBase64
<#
    .SYNOPSIS
        URL Decodes a string
    
    .PARAMETER str
        A string to be url decoded
    
    .EXAMPLE
        Invoke-UrlDecode $urlEncodedString
#>
function Invoke-UrlDecode
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string] $str
    )

    [Web.Httputility]::UrlDecode($str)
}
Set-Alias urlDecode Invoke-UrlDecode
<#
    .SYNOPSIS
        URL Encodes a string
    
    .PARAMETER str
        A string to be url encoded
    
    .EXAMPLE
        Invoke-UrlEncode $myString
#>
function Invoke-UrlEncode
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string] $str
    )

    [Web.Httputility]::UrlEncode($str)
}
Set-Alias urlEncode Invoke-UrlEncode
<#
    .SYNOPSIS
        Html Decodes a string
    
    .PARAMETER str
        A string to be html decoded
    
    .EXAMPLE
        Invoke-HtmlDecode $htmlEncodedString
#>
function Invoke-HtmlDecode
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string] $str
    )

    [Web.Httputility]::HtmlDecode($str)
}
Set-Alias htmlDecode Invoke-HtmlDecode
<#
    .SYNOPSIS
        Html Encodes a string
    
    .PARAMETER str
        A string to be html encoded
    
    .EXAMPLE
        Invoke-HtmlEncode $myString
#>
function Invoke-HtmlEncode
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string] $str
    )

    [Web.Httputility]::HtmlEncode($str)
}
Set-Alias htmlEncode Invoke-HtmlEncode