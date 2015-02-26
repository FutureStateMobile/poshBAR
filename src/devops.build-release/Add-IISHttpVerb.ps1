$appcmd = "$env:windir\system32\inetsrv\appcmd.exe"
<#
    .DESCRIPTION
        Will add or remove a VERB from your website

    .EXAMPLE
        Add-IISHttpVerb PUT "apps.example.ca"
    .PARAMETER verb
        The name of the verb.
        valid verbs are: [GET, HEAD, POST, PUT, DELETE, TRACE, OPTIONS, CONNECT, PATCH]

    .PARAMETER siteName
        The name of the website that contains this application.

    .PARAMETER action
        Add or Remove

    .SYNOPSIS
        Will add or remove a VERB from your website
#>
function Add-IISHttpVerb {
    param(
        [parameter( Mandatory=$true, position=0 )] [string] [ValidateSet('GET', 'HEAD', 'POST', 'PUT', 'DELETE', 'TRACE', 'OPTIONS', 'CONNECT', 'PATCH')] $verb,
        [parameter( Mandatory=$true, position=1 )] [string] $siteName,
        [parameter( Mandatory=$false, position=2 )] [string] [ValidateSet('Add', 'Remove')] $action = "add"
    )

    $ErrorActionPreference = "Stop"
    Write-Host ($msgs.msg_add_verb -f $verb, $siteName) -NoNewLine
    $allowed = if($action -eq "add"){'true'} else {'false'}

    & $appcmd set config $siteName -section:system.webServer/security/requestFiltering /+"verbs.[verb='$verb',allowed='$allowed']"
    Write-Host "`tDone" -f Green
}