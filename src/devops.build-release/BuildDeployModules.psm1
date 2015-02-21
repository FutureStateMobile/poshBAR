$fsmbrVersion = "1.1.1" # contains the current version of fsm.buildrelease

Write-Host "`nfsm.buildrelease version $fsmbrVersion `nCopyright ($([char]0x00A9)) Future State Mobile Inc. & Contributors`n"

Push-Location $psScriptRoot

. .\Add-HostsFileEntry.ps1
. .\Add-IISHttpVerb.ps1
. .\Add-IISMimeType.ps1
. .\Add-LoopbackFix.ps1
. .\ApplicationAdministration.ps1
. .\AppPoolAdministration.ps1
. .\Approve-Permissions.ps1
. .\Assert-PSVersion.ps1
. .\Expand-NugetPackage.ps1
. .\Expand-ZipFile.ps1
. .\Format-TaskNameToHost.ps1
. .\Get-EnvironmentSettings.ps1
. .\Helpers.ps1
. .\Install-IISRewriteModule.ps1
. .\Install-WebApplication.ps1
. .\Invoke-Deployment.ps1
. .\Invoke-DeployOctopusNugetPackage.ps1
. .\Invoke-ElevatedCommand.ps1
. .\Invoke-ExternalCommand.ps1
. .\Invoke-Using.ps1
. .\Set-IISAuthentication.ps1
. .\Set-IISCustomHeader.ps1
. .\SiteAdministration.ps1
. .\SqlHelpers.ps1
. .\Test-PathExtended.ps1
. .\Test-RunAsAdmin.ps1
. .\TextUtils.ps1
. .\Update-AssemblyVersions.ps1
. .\Update-JsonConfigFile.ps1
. .\Update-XmlConfigFile.ps1
. .\Write-BuildInformation.ps1

Pop-Location

Export-ModuleMember `
    -Alias @(
        '*') `
    -Function @(
          'Add-HostsFileEntry',
          'Add-IISHttpVerb',
          'Add-IISMimeType',
          'Add-LoopbackFix',
          'Approve-Permissions',
          'Assert-PSVersion',
          'Confirm-ApplicationExists',
          'Confirm-AppPoolExists',
          'Confirm-SiteExists',
          'Exec',
          'Expand-NugetPackage',
          'Expand-ZipFile',
          'Format-TaskNameToHost',
          'Get-Application',
          'Get-Applications',
          'Get-AppPool',
          'Get-AppPools',
          'Get-DatabaseConnection',
          'Get-EnvironmentSettings',
          'Get-Site',
          'Get-Sites',
          'Get-TestFileName',
          'Get-WarningsFromMSBuildLog', 
          'Install-IISRewriteModule',
          'Install-WebApplication',
          'Invoke-BulkCopy',
          'Invoke-DBMigration',
          'Invoke-Deployment',
          'Invoke-DeployOctopusNugetPackage',
          'Invoke-ElevatedCommand',
          'Invoke-EntityFrameworkMigrations',
          'Invoke-ExternalCommand',
          'Invoke-FromBase64', 
          'Invoke-GruntMinification',
          'Invoke-GruntTests',
          'Invoke-HtmlDecode', 
          'Invoke-HtmlEncode',
          'Invoke-Nunit',
          'Invoke-NUnitWithCoverage'
          'Invoke-SpecFlow',
          'Invoke-SqlFile',
          'Invoke-SqlStatement',
          'Invoke-ToBase64', 
          'Invoke-UrlDecode', 
          'Invoke-UrlEncode', 
          'Invoke-Using',
          'Invoke-XUnit',
          'Invoke-XUnitWithCoverage',
          'New-Application',
          'New-AppPool',
          'New-Site',
          'Remove-Application',
          'Remove-AppPool',
          'Remove-Site',
          'Set-IISAuthentication',
          'Set-IISCustomHeader',
          'Start-Application',
          'Start-AppPool',
          'Start-Site',
          'Step',
          'Stop-Application',
          'Stop-AppPool',
          'Stop-Site',
          'Test-PathExtended',
          'Test-RunAsAdmin',
          'Update-Application',
          'Update-AppPool',
          'Update-AssemblyVersions',
          'Update-JsonConfigValues',
          'Update-Site',
          'Update-XmlConfigValues',
          'Write-BuildInformation'
          )