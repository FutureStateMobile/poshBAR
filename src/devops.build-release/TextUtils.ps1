# imports assembly needed for url stuff
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Web

function Invoke-FromBase64
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string] $str
    )

    [text.encoding]::utf8.getstring([convert]::FromBase64String($str))
}

function Invoke-ToBase64
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string] $str
    )

    [convert]::ToBase64String([text.encoding]::utf8.getBytes($str))
}

function Invoke-UrlDecode
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string] $str
    )

    [Web.Httputility]::UrlDecode($str)
}

function Invoke-UrlEncode
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string] $str
    )

    [Web.Httputility]::UrlEncode($str)
}

function Invoke-HtmlDecode
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string] $str
    )

    [Web.Httputility]::HtmlDecode($str)
}

function Invoke-HtmlEncode
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string] $str
    )

    [Web.Httputility]::HtmlEncode($str)
}
