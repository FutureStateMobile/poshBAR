Function Set-WebApplicationSecurity() {
    param( 
        [parameter(Mandatory=$true,position=0)] [string] $environment,
        [parameter(Mandatory=$true,position=1)] [System.Xml.XmlElement] $websiteSettings,
        [parameter(Mandatory=$true,position=2)] [ValidatePattern("^([0-9]{0,3}\.[0-9]{0,3}\.[0-9]{0,3})(\.[0-9]*?)?$")] [string] $version
    )

    if (($environment -eq "local") -or ($environment -eq "dev"))
    {
        Set-IISAuthentication windowsAuthentication true $($websiteSettings.siteName)

        if ( ($websiteSettings.appPath.length -gt 0) -and ($websiteSettings.appPath -ne "/") -and ($websiteSettings.appPath -ne "\") ) {
            New-Application $($websiteSettings.siteName) $($websiteSettings.appPath) $appFilePath $($websiteSettings.appPool.name) -updateIfFound

            $siteAndUriPath = $($websiteSettings.siteName) + "/" + $($websiteSettings.appPath)
            Set-IISAuthentication anonymousAuthentication true $($siteAndUriPath)
        }
    }
    else
    {
        Set-IISAuthentication windowsAuthentication true $($websiteSettings.siteName)
        Set-IISAuthentication anonymousAuthentication false $($websiteSettings.siteName)

        if ( ($websiteSettings.appPath.length -gt 0) -and ($websiteSettings.appPath -ne "/") -and ($websiteSettings.appPath -ne "\") ) {
            New-Application $($websiteSettings.siteName) $($websiteSettings.appPath) $appFilePath $($websiteSettings.appPool.name) -updateIfFound

            $siteAndUriPath = $($websiteSettings.siteName) + "/" + $($websiteSettings.appPath)
            Set-IISAuthentication windowsAuthentication true $($siteAndUriPath)
            Set-IISAuthentication anonymousAuthentication false $($siteAndUriPath)
        }
    }

    Write-Host -Fore Green "Successfully deployed Web Application"
}
