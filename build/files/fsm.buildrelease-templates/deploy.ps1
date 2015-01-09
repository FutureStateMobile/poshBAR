param (
    [parameter(Mandatory=$false,position=0)][string] $environment = "local",
    [parameter(Mandatory=$false,position=1)][string] $version = "0.1.1.1",
)

$rootDir = Split-Path $script:MyInvocation.MyCommand.Path
$publishDir = "$rootDir\build-artifacts\publish"
$octopusNugetPackage = "$publishDir\[YOUR-NUGET-PACKAGE-HERE].$version"

Import-Module "$rootDir\packages\fsm.buildrelease.9.9.9.9\tools\modules\BuildDeployModules" -force

Test-RunAsAdmin
Expand-NugetPackage "$octopusNugetPackage.nupkg" "$octopusNugetPackage"

& "$octopusNugetPackage\deploy.ps1" $environment