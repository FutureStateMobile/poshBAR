param (
    [parameter(Mandatory=$false,position=0)][string] $environment = "local",
    [parameter(Mandatory=$false,position=1)][string] $version = "0.1.1.1"
)

$currentDir = Split-Path $script:MyInvocation.MyCommand.Path
$publishDir = "$currentDir\build-artifacts\publish"

Import-Module "$currentDir\packages\fsm.buildrelease.*\tools\modules\BuildDeployModules" -force

Test-RunAsAdmin

# Iterates over all of the nupkg files in the publisDir in alphabetical order
Get-ChildItem "$publishDir\*.nupkg" | % {
    Invoke-DeployOctopusNugetPackage $_ $environment
}

# The above can also be iterated over in a specific order if you so require.
# This would closer emulate the Octopus process steps
<#    
    $pkgInOrder = @(
        "TransCanada.CLS.Administration.Services.WebAPI.$version.nupkg", 
        "TransCanada.CLS.Presentation.$version.nupkg")
    $pkgInOrder | % {
        Invoke-DeployOctopusNugetPackage $_ $environment
    }
#>