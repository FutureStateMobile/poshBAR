$appcmd = "$env:windir\system32\inetsrv\appcmd.exe"
<#
    .DESCRIPTION
       Will set the specified Authentication value for the specified applicaiton or website

    .EXAMPLE
        Set-IISCustomHeader "cls-w-85544.transcanada.com" "access-control-allow-origin" "*"

    .PARAMETER siteName
        The name of the site to add custom header to.

    .PARAMETER customHeaderName
        The name of the custom header to add.

    .PARAMETER customHeaderValue
        The value of the custom header to add.

    .SYNOPSIS
        Will set a custom header to specified value on the site indicated.
#>

function Set-IISCustomHeader
{
    param(
        [parameter(Mandatory=$true,position=0)] [string] $siteName,
        [parameter(Mandatory=$true,position=1)] [string] $customHeaderName,
        [parameter(Mandatory=$true,position=2)] [string] $customHeaderValue
    )

    $ErrorActionPreference = "Stop"

    Write-Output "Setting custom header $customHeaderName on site $siteName to value $customHeaderValue" -NoNewLine
    
    & $appcmd set config $siteName -section:system.webServer/httpProtocol /+"customHeaders.[name='$customHeaderName',value='$customHeaderValue']"  | Out-Null

    Write-Output "`tDone" -f Green
}

