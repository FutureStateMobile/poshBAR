$ErrorActionPreference = "Stop"

function Install-WebApplication() {
    param( 
        [parameter(Mandatory=$true,position=0)] [string] $environment,
        [parameter(Mandatory=$true,position=1)] [System.Xml.XmlElement] $websiteSettings,
        [parameter(Mandatory=$true,position=2)] [ValidatePattern("^([0-9]{0,3}\.[0-9]{0,3}\.[0-9]{0,3})(\.[0-9]*?)?$")] [string] $version,
        [parameter(Mandatory=$true,position=3)] [ValidateSet('anonymousAuthentication','windowsAuthentication','basicAuthentication','formsAuthentication')] [string] $authenticationType
    )
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

    # Site Permissions
    Write-Host "Setting permissions for $($websiteSettings.appPool.userName) on $siteFilePath"
    icacls "$siteFilePath" /grant ($($websiteSettings.appPool.userName) + ":(OI)(CI)(RX)") | Out-Default
    Write-Host "Successfully granted read/write access to $($websiteSettings.physicalPathRoot)\$($websiteSettings.siteName)"

    if(Test-Path "$siteFilePath/App_Data"){
        icacls "$($siteFilePath)/App_Data" /grant ($($websiteSettings.appPool.userName) + ":(OI)(CI)(M)") | Out-Default
        Write-Host "Successfully granted read/execute access to $($appFilePath)"
    }

    # App Permissions
    Write-Host ""
    Write-Host "Setting permissions for $($websiteSettings.appPool.userName) on $appFilePath"
    icacls "$($appFilePath)" /grant ($($websiteSettings.appPool.userName) + ":(OI)(CI)(RX)") | Out-Default
    Write-Host "Successfully granted read/execute access to $($appFilePath)"

    if(Test-Path "$appFilePath/App_Data"){
        icacls "$($appFilePath)/App_Data" /grant ($($websiteSettings.appPool.userName) + ":(OI)(CI)(M)") | Out-Default
        Write-Host "Successfully granted read/execute access to $($appFilePath)"
    }

    New-AppPool $($websiteSettings.appPool.name) $($websiteSettings.appPool.identityType) $($websiteSettings.appPool.maxWorkerProcesses) $($websiteSettings.appPool.userName) $($websiteSettings.appPool.password)

    New-Site $($websiteSettings.siteName) $siteFilePath $($websiteSettings.siteHost) ($websiteSettings.siteProtcol) ($websiteSettings.portNumber) $($websiteSettings.appPool.name) -updateIfFound

    Set-IISAuthentication $authenticationType true $($websiteSettings.siteName)
    if ( ($websiteSettings.appPath.length -gt 0) -and ($websiteSettings.appPath -ne "/") -and ($websiteSettings.appPath -ne "\") ) {
        New-Application $($websiteSettings.siteName) $($websiteSettings.appPath) $appFilePath $($websiteSettings.appPool.name) -updateIfFound

        $siteAndUriPath = $($websiteSettings.siteName) + "/" + $($websiteSettings.appPath)
        Set-IISAuthentication $authenticationType true $($siteAndUriPath)
    }

    Write-Host -Fore Green "Successfully deployed Web Application"
}
