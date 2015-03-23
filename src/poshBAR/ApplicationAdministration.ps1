$appcmd = "$env:windir\system32\inetsrv\appcmd.exe"

<#
    .DESCRIPTION
        Will setup a web application under the specified Website and AppPool.

    .EXAMPLE
        New-Application "MyApp" "apps.tcpl.ca" "C:\inetpub\apps.tcpl.ca\MyApp" "MyApp"

    .PARAMETER appName
        The name of the application.

    .PARAMETER appPath
        The physical path where this application is located on disk.

    .PARAMETER siteName
        The name of the website that contains this application.

    .PARAMETER appPoolName
        The application pool that this application runs under.

    .PARAMETER updateIfFound
        With this switch passed in, the Applications PhysicalPath will be updated to point to the new AppPath provided, otherwise, if it already exists it will just be left alone.

    .SYNOPSIS
        Will setup a web application under the specified Website and AppPool.
#>

function New-Application
{
    [CmdletBinding()]
    param(
        [parameter( Mandatory=$true, position=0 )] [string] $siteName,
        [parameter( Mandatory=$true, position=1 )] [string] $appName,
        [parameter( Mandatory=$true, position=2 )] [string] $appPath,
        [parameter( Mandatory=$true, position=3 )] [string] $appPoolName,
        [parameter( Mandatory=$false, position=4 )] [switch] $updateIfFound
    )

    $ErrorActionPreference = "Stop"

    Write-Host "Creating new Application: $siteName/$appName" -NoNewLine
    $exists = Confirm-ApplicationExists $siteName $appName
    
    if (!$exists) {
        & $appcmd add App /site.name:$siteName /path:/$appName /physicalPath:$appPath | Out-Null
        & $appcmd set App /app.name:$siteName/$appName /applicationPool:$appPoolName | Out-Null
        Write-Host "`tDone" -f Green
    } else {
        Write-Host "`tApplication already exists..." -f Cyan
        if ($updateIfFound.isPresent) {
            Update-Application $siteName $appName $appPath $appPoolName
        } else {
            Write-Host ($msgs.msg_not_updating -f "Application")
        }
    }
}

function Update-Application{
    param(
        [parameter( Mandatory=$true, position=0 )] [string] $siteName,
        [parameter( Mandatory=$true, position=1 )] [string] $appName,
        [parameter( Mandatory=$true, position=2 )] [string] $appPath,
        [parameter( Mandatory=$true, position=3 )] [string] $appPoolName
    )

    Write-Host "Updating Application: $siteName/$appName" -NoNewLine
    $exists = Confirm-ApplicationExists $siteName $appName

    if ($exists){
        & $appcmd set App /app.name:$siteName/$appName /applicationPool:$appPoolName | Out-Null
        & $appcmd set app /app.name:$siteName/$appName "/[path='/'].physicalPath:$appPath" | Out-Null
        Write-Host "`tDone" -f Green
    }else{
        Write-Host "" #forces a new line
        Write-Warning ($msgs.cant_find -f "Application", "$siteName/$appName")
    }
}

function Confirm-ApplicationExists( $siteName, $appName ){
    $getApp = Get-Application $siteName $appName
    
    if ($getApp -ne $null){
        return $getApp.Contains( "APP ""$siteName/$appName")
    }

    return ($getApp -ne $null)
}

function Remove-Application( $siteName, $appName ){
    $getApp = "$appcmd delete App '$siteName/$appName/'"
    return Invoke-Expression $getApp
}

function Start-Application( $siteName, $appName ){
    $getApp = "$appcmd start App '$siteName/$appName/'"
    return Invoke-Expression $getApp
}

function Stop-Application( $siteName, $appName ){
    $getApp = "$appcmd stop App '$siteName/$appName/'"
    return Invoke-Expression $getApp
}

function Get-Application( $siteName, $appName ){
    $getApp = "$appcmd list App '$siteName/$appName/'"
    return Invoke-Expression $getApp
}

function Get-Applications{
    $getApp = "$appcmd list Apps"
    Invoke-Expression $getApp
}
