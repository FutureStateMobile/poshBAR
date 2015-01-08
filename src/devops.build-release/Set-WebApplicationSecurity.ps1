Function Set-WebApplicationSecurity() {
    param( 
        [parameter(Mandatory=$true,position=0)] [string] $environment,
        [parameter(Mandatory=$true,position=1)] [System.Xml.XmlElement] $websiteSettings,
        [parameter(Mandatory=$true,position=2)] [string] $version
    )

    Format-TaskNameToHost "Setting IIS Authentication for $($websiteSettings.siteName)"

    if (($environment -eq "local") -or ($environment -eq "dev"))
    {
        Set-IISAuthentication windowsAuthentication true $($websiteSettings.siteName)

        if ( ($websiteSettings.appPath.length -gt 0) -and ($websiteSettings.appPath -ne "/") -and ($websiteSettings.appPath -ne "\") ) {
            Format-TaskNameToHost "Create Application"
            New-Application $($websiteSettings.siteName) $($websiteSettings.appPath) $appFilePath $($websiteSettings.appPool.name) -updateIfFound

            $siteAndUriPath = $($websiteSettings.siteName) + "/" + $($websiteSettings.appPath)
            Format-TaskNameToHost "Setting IIS Authentication for $($siteAndUriPath)"
            Set-IISAuthentication anonymousAuthentication true $($siteAndUriPath)
        }
    }
    else
    {
        Set-IISAuthentication windowsAuthentication true $($websiteSettings.siteName)
        Set-IISAuthentication anonymousAuthentication false $($websiteSettings.siteName)

        if ( ($websiteSettings.appPath.length -gt 0) -and ($websiteSettings.appPath -ne "/") -and ($websiteSettings.appPath -ne "\") ) {
            Format-TaskNameToHost "Create Application"
            New-Application $($websiteSettings.siteName) $($websiteSettings.appPath) $appFilePath $($websiteSettings.appPool.name) -updateIfFound

            $siteAndUriPath = $($websiteSettings.siteName) + "/" + $($websiteSettings.appPath)
            Format-TaskNameToHost "Setting IIS Authentication for $($siteAndUriPath)"
            Set-IISAuthentication windowsAuthentication true $($siteAndUriPath)
            Set-IISAuthentication anonymousAuthentication false $($siteAndUriPath)
        }
    }

    Write-Host -Fore Green "Successfully deployed Web Application"
}
