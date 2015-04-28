param([string] $environment = "local", [string] $version = "0.1.1.1")

$ErrorActionPreference = "Stop"

if ( $OctopusParameters ) { 
    $environment = $OctopusParameters["Octopus.Environment.Name"]
    $version = $OctopusParameters["Octopus.Release.Number"]
}

$here = Split-Path $script:MyInvocation.MyCommand.Path
Import-Module "$here\..\packages\poshBAR.*\tools\modules\poshBAR" -force

$environmentSettings = Get-EnvironmentSettings $environment "//environmentSettings"
$websiteSettings = $environmentSettings.webSites.[NameOfYourWebsiteNode]

RequiredFeatures @(
    'IIS-WebServer',
    'IIS-WebServerRole')

Step RegIis {
    aspnet_regiis -i -framework 4.5
}

Step UpdateConfiguration {
    #using standard xdt, we merge the web.[environment-name].config with the default web.config.
    xdt "$here\website\web.config" "$here\website\web.$environment.config"

    # update additional config values (useful if config is stored within Octopus's sensitive variables)
    Update-XmlConfigValues "$here\website\web.config" $xpath $newValue "optionalAttributeName"
}

Step InstallWebsite {
    Install-WebApplication $environment $websiteSettings $version 
}

# local only step
if($environment -eq 'local'){
    Step AddHostFileEntry {
        Test-RunAsAdmin
        Add-HostsFileEntry $($websiteSettings.siteHost) -IncludeLoopbackFix    
    } 
}

Invoke-Deployment