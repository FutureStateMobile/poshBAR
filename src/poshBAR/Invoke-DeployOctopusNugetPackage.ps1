<#
    .DESCRIPTION
        Deploys an nupkg the same way Octopus Deploy would do it.

    .EXAMPLE
        Test-DeployOctopusNugetPackage "C:\myApp\myApp.nupkg" "production"
    
    .PARAMETER pathToPackage
        The fully qualified path to your nupkg file that is being deployed

    .PARAMETER environment
        The name of the environment that you're deploying to.

    .PARAMETER removeNuspec
        Removes the nuspec file after expanding the package. Default is true - removes the nuspec file

    .SYNOPSIS
        This will invoke all of the deployment scripts in order in the same way that Octopus Deploy does it. 
        If a deployment fails, it will try to run the deployFailed.ps1 and then throws the exception.
#>
function Invoke-DeployOctopusNugetPackage{
    [CmdletBinding()]
    param(
        [parameter( Mandatory=$true, position=0 )] [ValidatePattern('^*?\.nupkg')] [string] $pathToPackage,
        [parameter( Mandatory=$true, position=1 )] [string] $environment,
        [parameter( Mandatory=$false, position=2 )] [bool] $removeNuspec = $true
    )
    $ErrorActionPreference = "Stop"
    Test-RunAsAdmin

    # Unpack the nupkg
    $pathOnly = $pathToPackage.Replace(".nupkg", "")
    Expand-NugetPackage $pathToPackage $pathOnly $removeNuspec

    # Deploy the nupkgs
    # This uses the convention laid out by Octopus Deploy
    # http://docs.octopusdeploy.com/display/OD/PowerShell+scripts
    $preDeployScript = "$pathOnly\preDeploy.ps1"
    $deployScript = "$pathOnly\deploy.ps1"
    $postDeployScript = "$pathOnly\postDeploy.ps1"
    $deployFailedScript = "$pathOnly\deployFailed.ps1"
    try{
        if(Test-Path $preDeployScript){ & $preDeployScript $environment }
        if(Test-Path $deployScript){ & $deployScript $environment }
        if(Test-Path $postDeployScript){ & $postDeployScript $environment }
    } catch [Exception]{
        if(Test-Path $deployFailedScript){ & $deployFailedScript $environment }   
        Write-Host ($msgs.error_octopus_deploy_failed -f $_.Exception.Message) -f Red
        $_.Exception.StackTrace 
        Exit 1 
    }
}
