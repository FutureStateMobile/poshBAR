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
        Exec { Invoke-Expression  "$appcmd add App /site.name:$siteName /path:/$appName /physicalPath:$appPath" } -retry 10 | Out-Null
        Exec { Invoke-Expression  "$appcmd set App /app.name:$siteName/$appName /applicationPool:$appPoolName"} -retry 10 | Out-Null
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

<#
    .DESCRIPTION
       Update IIS Application
    .SYNOPSIS
       Will update an IIS Application, only works if the application already exists.

    .EXAMPLE
        Update-Application 'mySite' 'myApp' 'C:\inetput\wwwroot' 'appPoolName'

    .PARAMETER siteName
        Name of the associated IIS Website

    .PARAMETER appName
        Name of the IIS Application to be updated

    .PARAMETER appPath
        Fully qualified path to the application being updated.

    .PARAMETER appPoolName
        Name of the application pool that the app is running under.

#>
function Update-Application{
    [CmdletBinding()]
    param(
        [parameter( Mandatory=$true, position=0 )] [string] $siteName,
        [parameter( Mandatory=$true, position=1 )] [string] $appName,
        [parameter( Mandatory=$true, position=2 )] [string] $appPath,
        [parameter( Mandatory=$true, position=3 )] [string] $appPoolName
    )
    $ErrorActionPreference = "Stop"

    Write-Host "Updating Application: $siteName/$appName" -NoNewLine
    $exists = Confirm-ApplicationExists $siteName $appName

    if ($exists){
        Exec { Invoke-Expression  "$appcmd set App /app.name:$siteName/$appName /applicationPool:$appPoolName"} -retry 10 | Out-Null
        Exec { Invoke-Expression  "$appcmd set app /app.name:$siteName/$appName `"/[path='/'].physicalPath:$appPath`"" } -retry 10 | Out-Null
        Write-Host "`tDone" -f Green
    }else{
        Write-Host "" #forces a new line
        Write-Warning ($msgs.cant_find -f "Application", "$siteName/$appName")
    }
}

<#
    .DESCRIPTION
       Confirms that the application in question actually exists in IIS

    .SYNOPSIS
        Confirms that the application in question actually exists in IIS

    .EXAMPLE
        Confirm-ApplicatonExists 'mySite' 'myApp'

    .PARAMETER siteName
        Name of the assocaited IIS website

    .PARAMETER appName
        Name of the IIS application that we're confirming.

#>
function Confirm-ApplicationExists( $siteName, $appName ){
    $getApp = Get-Application $siteName $appName
    
    if ($getApp -ne $null){
        return $getApp.Contains( "APP ""$siteName/$appName")
    }

    return ($getApp -ne $null)
}

<#
    .DESCRIPTION
        Removes an application from IIS
       
    .SYNOPSIS
        Removes an application from IIS

    .EXAMPLE
        Remove-Application 'mySite' 'myApp'

    .PARAMETER siteName
        Name of the associated IIS website

    .PARAMETER appName
        Name of the IIS application being removed.
#>
function Remove-Application( $siteName, $appName ){
    $getApp = "$appcmd delete App '$siteName/$appName/'"
    return Invoke-Expression $getApp
}

<#
    .DESCRIPTION
        Starts an application from IIS
       
    .SYNOPSIS
        Starts an application from IIS

    .EXAMPLE
        Start-Application 'mySite' 'myApp'

    .PARAMETER siteName
        Name of the associated IIS website

    .PARAMETER appName
        Name of the IIS application being started.
#>
function Start-Application( $siteName, $appName ){
    $getApp = "$appcmd start App '$siteName/$appName/'"
    return Invoke-Expression $getApp
}

<#
    .DESCRIPTION
        Stops an application from IIS
       
    .SYNOPSIS
        Stops an application from IIS

    .EXAMPLE
        Stop-Application 'mySite' 'myApp'

    .PARAMETER siteName
        Name of the associated IIS website

    .PARAMETER appName
        Name of the IIS application being stopped.
#>
function Stop-Application( $siteName, $appName ){
    $getApp = "$appcmd stop App '$siteName/$appName/'"
    return Invoke-Expression $getApp
}

<#
    .DESCRIPTION
        Retrieves an application from IIS
       
    .SYNOPSIS
        Retrieves an application from IIS

    .EXAMPLE
        Get-Application 'mySite' 'myApp'

    .PARAMETER siteName
        Name of the associated IIS website

    .PARAMETER appName
        Name of the IIS application being retrieved.
#>
function Get-Application{
[CmdletBinding()]
    param(
        [parameter][string]$siteName, 
        [parameter][string]$appName
    )
    $getApp = "$appcmd list App '$siteName/$appName/'"
    return Invoke-Expression $getApp
}

<#
    .DESCRIPTION
        Retrieves all applications from IIS
       
    .SYNOPSIS
        Retrieves all applications from IIS

    .EXAMPLE
        Get-Applications
#>
function Get-Applications{
    $getApp = "$appcmd list Apps"
    Invoke-Expression $getApp
}
