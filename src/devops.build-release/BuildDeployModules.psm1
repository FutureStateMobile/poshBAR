if (Get-Module BuildDeployModules) { return }

$PSVersionTable.PSVersion | % {
     if($_.Major -lt 4){
          Write-Host "ERROR: You are running an incompatable version of Powershell." -f Red
          Write-Host "A newer version of Powershell can be found at " -nonewline
          Write-Host "http://www.microsoft.com/en-us/download/details.aspx?id=40855&WT.mc_id=rss_alldownloads_all" -f cyan
          Write-Host "Or by installing through Chocolatey `(" -nonewline
          Write-Host "http://chocolatey.org" -f Cyan -nonewline
          Write-Host ")."
          Write-Host "`t> choco install Powershell" -f Cyan
          Write-Host "After installing Powershell, you may need to reboot your computer."
          throw "Powershell V4 is required to use these modules."
     }
}

Push-Location $psScriptRoot

. .\Add-HostsFileEntry.ps1
. .\Add-LoopbackFix.ps1
. .\Add-SybaseLinkedServer.ps1
. .\ApplicationAdministration.ps1
. .\AppPoolAdministration.ps1
. .\DatabaseDeploy.ps1
. .\Expand-NugetPackage.ps1
. .\Expand-ZipFile.ps1
. .\Format-TaskNameToHost.ps1
. .\Get-EnvironmentSettings.ps1
. .\Helpers.ps1
. .\Install-IISRewriteModule.ps1
. .\Install-WebApplication.ps1
. .\Invoke-ElevatedCommand.ps1
. .\Invoke-ExternalCommand.ps1
. .\Invoke-Using.ps1
. .\Set-IISAuthentication.ps1
. .\Set-WebApplicationSecurity.ps1
. .\SiteAdministration.ps1
. .\SqlHelpers.ps1
. .\Test-RunAsAdmin.ps1
. .\TextUtils.ps1
. .\Timer.ps1
. .\Update-AssemblyVersions.ps1
. .\Update-JsonConfigFile.ps1
. .\Update-XmlConfigFile.ps1

Pop-Location

Export-ModuleMember `
    -Alias @(
        '*') `
    -Function @(
          'Add-HostsFileEntry',
          'Add-LoopbackFix',
          'Add-SybaseLinkedServer',
          'Expand-NugetPackage',
          'Expand-ZipFile',
          'Format-TaskNameToHost',
          'Get-EnvironmentSettings',
          'Install-IISRewriteModule',
          'Install-WebApplication',
          'Invoke-ElevatedCommand',
          'Invoke-DatabaseDeploy',
          'Invoke-ExternalCommand',
          'Invoke-Using',
          'Set-IISAuthentication',
          'Set-WebApplicationSecurity',
          'Test-RunAsAdmin',
          'Update-AssemblyVersions',
          'Update-ConfigValues',
          'Invoke-FromBase64', 
          'Invoke-ToBase64', 
          'Invoke-UrlDecode', 
          'Invoke-UrlEncode', 
          'Invoke-HtmlDecode', 
          'Invoke-HtmlEncode',
          'Get-DatabaseConnection',
          'Invoke-SqlStatement',
          'Invoke-SqlFile',
          'Invoke-BulkCopy',
          'New-Site',
          'Update-Site',
          'Confirm-SiteExists',
          'Remove-Site',
          'Start-Site',
          'Stop-Site',
          'Get-Site',
          'Get-Sites',
          'New-AppPool',
          'Get-AppPool',
          'Get-AppPools',
          'Update-AppPool',
          'Remove-AppPool',
          'Start-AppPool',
          'Stop-AppPool',
          'Confirm-AppPoolExists',
          'New-Application',
          'Update-Application',
          'Confirm-ApplicationExists',
          'Remove-Application',
          'Start-Application',
          'Stop-Application',
          'Get-Application',
          'Get-Applications',
          'Write-TaskTimeSummary',
          'Initialize-TaskTimer',
          'Set-TaskTimeStamp',
          'Invoke-DBMigration',
          'Invoke-Nunit',
          'Invoke-NUnitWithCoverage',
          'Invoke-SpecFlow',
          'Get-TestFileName',
          'Get-WarningsFromMSBuildLog', 
          'Update-JsonConfigValues')