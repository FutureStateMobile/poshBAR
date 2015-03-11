param( 
    [string] $environment = "local",
    [string] $version = "0.1.1.1"
)
$ErrorActionPreference = "Stop"

if ( $OctopusParameters ) { 
    $environment = $OctopusParameters["Octopus.Environment.Name"]
    $version = $OctopusParameters["Octopus.Release.Number"]
}

$currentDir = Split-Path $script:MyInvocation.MyCommand.Path
Import-Module "$currentDir\..\packages\poshBAR.*\tools\modules\poshBAR" -force

$environmentSettings = Get-EnvironmentSettings $environment "//environmentSettings"
$websiteSettings = $environmentSettings.webSites.[NameOfYourWebsiteNode]

RequiredFeatures @(
    'IIS-WebServer',
    'IIS-WebServerRole')

Step InstallWebsite {
    Install-WebApplication $environment $websiteSettings $version $websiteSettings.authenticationType
}

Step AddHostFileEntry {
    Test-RunAsAdmin
    Add-HostsFileEntry $($websiteSettings.siteHost) -IncludeLoopbackFix    
}

Invoke-Deployment