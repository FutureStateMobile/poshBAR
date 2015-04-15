$ErrorActionPreference = "Stop"

function Install-WebApplication() {
    [CmdletBinding()]
    param( 
        [parameter(Mandatory=$true,position=0)] [string] $environment,
        [parameter(Mandatory=$true,position=1)] [System.Xml.XmlElement] $websiteSettings,
        [parameter(Mandatory=$true,position=2)] [ValidatePattern('^([0-9]{0,3}\.[0-9]{0,3}\.[0-9]{0,3})(\.[0-9]*?)?')] [string] $version
    )
    $moduleDir = Split-Path $script:MyInvocation.MyCommand.Path
    $baseDir = Resolve-Path "$moduleDir\..\.."

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

    Write-Host ($msgs.msg_copying_content -f $websiteSettings.siteName, $appFilePath) -NoNewLine
    # copy the website over, but be sure to exclude environment specific web configs.
    Copy-Item "$baseDir\website\*" $($appFilePath) -Exclude 'web.*.config'  -Recurse -Force 
    Write-Host "`tDone" -f Green

    # Site Permissions
    Approve-Permissions $siteFilePath $($websiteSettings.appPool.userName) "read-execute"

    if(Test-Path "$siteFilePath/App_Data"){
        Approve-Permissions "$siteFilePath/App_Data" $($websiteSettings.appPool.userName) "modify"
    }

    # App Permissions
    Approve-Permissions $appFilePath $($websiteSettings.appPool.userName) "read-execute"

    if(Test-Path "$appFilePath/App_Data"){
        Approve-Permissions "$appFilePath/App_Data" $($websiteSettings.appPool.userName) "modify"
    }

    New-AppPool $($websiteSettings.appPool.name) $($websiteSettings.appPool.identityType) $($websiteSettings.appPool.maxWorkerProcesses) $($websiteSettings.appPool.userName) $($websiteSettings.appPool.password)

    New-Site $($websiteSettings.siteName) $siteFilePath ($websiteSettings.bindings) $($websiteSettings.appPool.name) -updateIfFound
    Set-IISAuthentication $websiteSettings.iisAuthenticationTypes true $($websiteSettings.siteName)
    
    
    if ( ($websiteSettings.appPath.length -gt 0) -and ($websiteSettings.appPath -ne "/") -and ($websiteSettings.appPath -ne "\") ) {
        New-Application $($websiteSettings.siteName) $($websiteSettings.appPath) $appFilePath $($websiteSettings.appPool.name) -updateIfFound

        $siteAndUriPath = $($websiteSettings.siteName) + "/" + $($websiteSettings.appPath)
        Set-IISAuthentication $websiteSettings.iisAuthenticationTypes true $($siteAndUriPath)
    }

    $msgs.msg_web_app_success -f $websiteSettings.siteName
}