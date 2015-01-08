$appcmd = "$env:windir\system32\inetsrv\appcmd.exe"

<#
    .DESCRIPTION
        Will create a Website with the specified settings if one doesn't exist.

    .EXAMPLE
        New-Website "apps.tcpl.ca" "C:\inetpub\apps.tcpl.ca" "apps.tcpl.ca"

    .PARAMETER siteName
        The name of the Website that we are creating.

    .PARAMETER sitePath
        The physical path where this Website is located on disk.

    .PARAMETER hostHeader
        The "C" name that IIS forward on to this Website.

    .PARAMETER protocol
        The protocol for the site e.g. http or https

    .PARAMETER portNumber
        The port the site is bound to e.g. port 80

    .SYNOPSIS
        Will setup a web application under the specified Website and AppPool.
#>
function New-Site{
    param(
        [parameter(Mandatory=$true,position=0)] [string] $siteName,
        [parameter(Mandatory=$true,position=1)] [string] $sitePath,
        [parameter(Mandatory=$true,position=2)] [string] $hostHeader,
        [parameter(Mandatory=$true,position=3)] [string] $protocol,
        [parameter(Mandatory=$true,position=4)] [string] $portNumber,
        [parameter(Mandatory=$true,position=5)] [string] $appPoolName,
        [parameter(Mandatory=$false,position=6)] [switch] $updateIfFound
    )

    Write-Output "Creating Site: $siteName"
    $exists = Confirm-SiteExists $siteName
    
    if (!$exists) {
        & $appcmd add site /name:$siteName /physicalPath:$sitePath /bindings:$protocol/*:${portNumber}:$hostHeader
        & $appcmd set app $siteName/ /applicationPool:$appPoolName
    }else{
        Write-Output "Site already exists..."
        if ($updateIfFound.isPresent) {
            Update-Site $siteName $sitePath $hostHeader $protocol $portNumber $appPoolName
        } else {
            Write-Output "Not updating Site, you must specify the '-updateIfFound' if you wish to update the Site settings."
        }
    }
}

function Update-Site{
    param(
            [parameter(Mandatory=$true,position=0)] [string] $siteName,
            [parameter(Mandatory=$true,position=1)] [string] $sitePath,
            [parameter(Mandatory=$true,position=2)] [string] $hostHeader,
            [parameter(Mandatory=$true,position=3)] [string] $protocol,
            [parameter(Mandatory=$true,position=4)] [string] $portNumber,
            [parameter(Mandatory=$true,position=5)] [string] $appPoolName
    )

    Write-Output "Updating Site: $siteName"
    $exists = Confirm-SiteExists $siteName

    if ($exists){
        & $appcmd set Site $siteName/ /bindings:$protocol/*:${portNumber}:$hostHeader
        & $appcmd set App $siteName/ /applicationPool:$appPoolName
        & $appcmd set App $siteName/ "/[path='/'].physicalPath:$sitePath"
    }else{
        Write-Output "Error: Could not find a Site with the name: $siteName"
    }
}

function Confirm-SiteExists( $siteName ){
    $getSite = Get-Site($siteName)
    return ($getSite -ne $null)
}

function Remove-Site( $siteName ){
    $getSite = "$appcmd delete App $siteName/"
    return Invoke-Expression $getSite
}

function Start-Site( $siteName ){
    $getSite = "$appcmd start App $siteName/"
    return Invoke-Expression $getSite
}

function Stop-Site( $siteName ){
    $getSite = "$appcmd stop App $siteName/"
    return Invoke-Expression $getSite
}

function Get-Site( $siteName ){
    $getSite = "$appcmd list App $siteName/"
    return Invoke-Expression $getSite
}

function Get-Sites{
    $getSite = "$appcmd list Apps"
    Invoke-Expression $getSite
}
