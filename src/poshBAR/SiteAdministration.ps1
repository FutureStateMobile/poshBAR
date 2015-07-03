$appcmd = "$env:windir\system32\inetsrv\appcmd.exe"

<#
    .DESCRIPTION
        Will create a Website with the specified settings if one doesn't exist.

    .EXAMPLE
        New-Site "myWebsite.com" "c:\inetpub\wwwroot" @(@{"protocol" = "http"; "port" = 80; "hostName"="mysite.com"}) "myAppPool" -updateIfFound

    .PARAMETER siteName
        The name of the Website that we are creating.

    .PARAMETER sitePath
        The physical path where this Website is located on disk.

    .PARAMETER bindings
        An Object Array of bindings. Must include "protocol", "port", and "hostName"

    .PARAMETER appPoolName
        The name of the app pool to use

    .PARAMETER updateIfFound
        Should we update an existing website if it already exists?
        
    .SYNOPSIS
        Will setup a website under the specified site name and AppPool.
#>
function New-Site{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string] $siteName,
        [parameter(Mandatory=$true,position=1)] [string] $sitePath,
        [parameter(Mandatory=$true,position=3)] [object[]] $bindings,
        [parameter(Mandatory=$true,position=5)] [string] $appPoolName,
        [parameter(Mandatory=$false,position=6)] [switch] $updateIfFound
    )

    Write-Host "Creating Site: $siteName" -NoNewLine
    $exists = Confirm-SiteExists $siteName
    
    if (!$exists) {
        if($poshBAR.DisableCreateIISWebsite) {
            throw $msgs.error_website_creation_disabled
        }
        
        $bindingString = @()
        $bindings | % { $bindingString += "$($_.protocol)/*:$($_.port):$($_.hostName)" }
        Exec { Invoke-Expression  "$appcmd add site /name:$siteName /physicalPath:$sitePath /bindings:$($bindingString -join ",")"} -retry 10 | Out-Null
        Exec { Invoke-Expression  "$appcmd set app $siteName/ /applicationPool:$appPoolName"} -retry 10 | Out-Null
        Write-Host "`tDone" -f Green
    }else{
        Write-Host "`tExists" -f Cyan
        if ($updateIfFound.isPresent) {
            Update-Site $siteName $sitePath $bindings $appPoolName
        } else {
            # Message
            Write-Host ($msgs.msg_not_updating -f "Site")
        }
    }
}


<#
    .DESCRIPTION
        Will update a Website with the specified settings if one doesn't exist.

    .EXAMPLE
        Update-Site "myWebsite.com" "c:\inetpub\wwwroot" @(@{"protocol" = "http"; "port" = 80; "hostName"="mysite.com"}) "myAppPool"

    .PARAMETER siteName
        The name of the Website that we are updating.

    .PARAMETER sitePath
        The physical path where this Website is located on disk.

    .PARAMETER bindings
        An Object Array of bindings. Must include "protocol", "port", and "hostName"

    .PARAMETER appPoolName
        The name of the app pool to use
        
    .SYNOPSIS
        Will update a website under the specified site name and AppPool.
#>
function Update-Site{
    param(
            [parameter(Mandatory=$true,position=0)] [string] $siteName,
            [parameter(Mandatory=$true,position=1)] [string] $sitePath,
            [parameter(Mandatory=$true,position=3)] [object[]] $bindings,
            [parameter(Mandatory=$true,position=5)] [string] $appPoolName
    )

    Write-Host "Updating Site: $siteName" -NoNewLine
    $exists = Confirm-SiteExists $siteName

    if ($exists){
        $bindingString = @()
        $bindings | % { $bindingString += "$($_.protocol)/*:$($_.port):$($_.hostName)" }
        
        Exec { Invoke-Expression  "$appcmd set Site $siteName/ /bindings:$($bindingString -join ",")"} -retry 10  | Out-Null
        Exec { Invoke-Expression  "$appcmd set App $siteName/ /applicationPool:$appPoolName"} -retry 10 | Out-Null
        Exec { Invoke-Expression  "$appcmd set App $siteName/ `"/[path='/'].physicalPath:$sitePath`""} -retry 10 | Out-Null
        Write-Host "`tDone" -f Green
    }else{
        Write-Host "" #forces a new line
        Write-Warning ($msgs.cant_find -f "Site",$siteName)
    }
}

<#
    .SYNOPSIS
        Checks to see if a website already exists

    .EXAMPLE
        Confirm-SiteExists "myWebsite.com"

    .PARAMETER siteName
        Name of the website as it appears in IIS
#>
function Confirm-SiteExists{
    [CmdletBinding()]
    param([string] $siteName)
    
    $getSite = Get-Site($siteName)
    return ($getSite -ne $null)
}
<#
    .SYNOPSIS
        Removes an existing website

    .EXAMPLE
        Remove-Site "myWebsite.com"

    .PARAMETER siteName
        Name of the website as it appears in IIS
#>
function Remove-Site{
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][string] $siteName)

    $getSite = "$appcmd delete App $siteName/"
    return Invoke-Expression $getSite
}

<#
    .SYNOPSIS
        Starts a website

    .EXAMPLE
        Start-Site "myWebsite.com"

    .PARAMETER siteName
        Name of the website as it appears in IIS
#>
function Start-Site{
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][string] $siteName)

    $getSite = "$appcmd start App $siteName/"
    return Invoke-Expression $getSite
}

<#
    .SYNOPSIS
        Stops a website

    .EXAMPLE
        Stop-Site "myWebsite.com"

    .PARAMETER siteName
        Name of the website as it appears in IIS
#>
function Stop-Site{
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][string] $siteName)

    $getSite = "$appcmd stop App $siteName/"
    return Invoke-Expression $getSite
}

<#
    .SYNOPSIS
        Gets a website's details

    .EXAMPLE
        Get-Site "myWebsite.com"

    .PARAMETER siteName
        Name of the website as it appears in IIS
#>
function Get-Site{
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][string] $siteName)

    $getSite = "$appcmd list App $siteName/"
    return Invoke-Expression $getSite
}

<#
    .SYNOPSIS
        Gets all websites from IIS

    .EXAMPLE
        Get-Sites
#>
function Get-Sites{
    $getSite = "$appcmd list Apps"
    Invoke-Expression $getSite
}
