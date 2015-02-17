$ErrorActionPreference = "Stop"

function Install-WebApplication() {
    param( 
        [parameter(Mandatory=$true,position=0)] [string] $environment,
        [parameter(Mandatory=$true,position=1)] [System.Xml.XmlElement] $websiteSettings,
        [parameter(Mandatory=$true,position=2)] [ValidatePattern("^([0-9]{0,3}\.[0-9]{0,3}\.[0-9]{0,3})(\.[0-9]*?)?$")] [string] $version,
        [parameter(Mandatory=$true,position=3)] [ValidateSet('anonymousAuthentication','windowsAuthentication','basicAuthentication','formsAuthentication')] [string] $authenticationType
    )
    Format-TaskNameToHost "Installing Web Application"
    $moduleDir = Split-Path $script:MyInvocation.MyCommand.Path
    $baseDir = Resolve-Path "$moduleDir\.."

    if ( ($websiteSettings.appPath.length -eq 0) -or ($websiteSettings.appPath -eq "/") -or ($websiteSettings.appPath -eq "\") ) {
        $siteFilePath = "$($websiteSettings.physicalPathRoot)\$($websiteSettings.siteName)\$($websiteSettings.physicalFolderPrefix)-$version"
        $appFilePath = "$($websiteSettings.physicalPathRoot)\$($websiteSettings.siteName)\$($websiteSettings.physicalFolderPrefix)-$version"
    }
    else {
        $siteFilePath = "$($websiteSettings.physicalPathRoot)\$($websiteSettings.siteName)"
        $appFilePath = "$($websiteSettings.physicalPathRoot)\$($websiteSettings.siteName)\$($websiteSettings.appPath)\$($websiteSettings.physicalFolderPrefix)-$version"
    }

    # Create Folder for the application
    if(!(Test-Path $($appFilePath))) {
        md $($appFilePath)
    } else {
        Remove-Item "$($appFilePath)\*" -recurse -Force
    }

    Write-Host "Copying website content to: $($appFilePath)"
    Copy-Item "$baseDir\website\*" $($appFilePath) -Recurse -Force
    Write-Host "Successfully copied website content"

    Write-Host "Granting read/write access to $($websiteSettings.physicalPathRoot)\$($websiteSettings.siteName) to ($($websiteSettings.appPool.userName)"
    icacls "$($websiteSettings.physicalPathRoot)\$($websiteSettings.siteName)" /grant ($($websiteSettings.appPool.userName) + ":(OI)(CI)(M)") | Out-Default
    Write-Host "Successfully granted read/write access to $($websiteSettings.physicalPathRoot)\$($websiteSettings.siteName)"

    Write-Host ""
    Write-Host "Granting read/write access to $($appFilePath) to ($($websiteSettings.appPool.userName)"
    icacls "$($appFilePath)" /grant ($($websiteSettings.appPool.userName) + ":(OI)(CI)(M)") | Out-Default
    Write-Host "Successfully granted read/write access to $($appFilePath)"

    New-AppPool $($websiteSettings.appPool.name) $($websiteSettings.appPool.identityType) $($websiteSettings.appPool.maxWorkerProcesses) $($websiteSettings.appPool.userName) $($websiteSettings.appPool.password)

    New-Site $($websiteSettings.siteName) $siteFilePath $($websiteSettings.siteHost) ($websiteSettings.siteProtcol) ($websiteSettings.portNumber) $($websiteSettings.appPool.name) -updateIfFound

    Set-IISAuthentication $authenticationType true $($websiteSettings.siteName)
    if ( ($websiteSettings.appPath.length -gt 0) -and ($websiteSettings.appPath -ne "/") -and ($websiteSettings.appPath -ne "\") ) {
        Format-TaskNameToHost "Create Application"
        New-Application $($websiteSettings.siteName) $($websiteSettings.appPath) $appFilePath $($websiteSettings.appPool.name) -updateIfFound

        $siteAndUriPath = $($websiteSettings.siteName) + "/" + $($websiteSettings.appPath)
        Format-TaskNameToHost "Setting IIS Authentication for $($siteAndUriPath)"
        Set-IISAuthentication $authenticationType true $($siteAndUriPath)
    }

    Write-Host -Fore Green "Successfully deployed Web Application"
}
