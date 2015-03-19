$version = "1.1.1" # contains the current version of poshBAR

Write-Host "`nposhBAR version $version `nCopyright ($([char]0x00A9)) Future State Mobile Inc. & Contributors`n"

Remove-Item alias:new -ea SilentlyContinue
Set-Alias new New-Object

Push-Location $psScriptRoot

. .\Add-HostsFileEntry.ps1
. .\Add-IISHttpVerb.ps1
. .\Add-IISMimeType.ps1
. .\Add-LoopbackFix.ps1
. .\ApplicationAdministration.ps1
. .\AppPoolAdministration.ps1
. .\Approve-Permissions.ps1
. .\Assert-PSVersion.ps1
. .\Chutzpah.ps1
. .\Ecliptic.ps1
. .\EntityFramework.ps1
. .\Expand-NugetPackage.ps1
. .\Expand-ZipFile.ps1
. .\Format-TaskNameToHost.ps1
. .\Get-EnvironmentSettings.ps1
. .\Grunt.ps1
. .\Helpers.ps1
. .\Install-WebApplication.ps1
. .\Invoke-Deployment.ps1
. .\Invoke-DeployOctopusNugetPackage.ps1
. .\Invoke-ElevatedCommand.ps1
. .\Invoke-ExternalCommand.ps1
. .\Invoke-HealthCheck.ps1
. .\Invoke-XmlDocumentTransform.ps1
. .\MSBuild.ps1
. .\Nuget.ps1
. .\nUnit.ps1
. .\Set-IISAuthentication.ps1
. .\Set-IISCustomHeader.ps1
. .\Set-PowershellScriptSigning.ps1
. .\SiteAdministration.ps1
. .\Specflow.ps1
. .\SqlHelpers.ps1
. .\Test-PathExtended.ps1
. .\Test-RunAsAdmin.ps1
. .\TextUtils.ps1
. .\Update-AssemblyVersions.ps1
. .\Use-Object.ps1
. .\JsonConfig.ps1
. .\XmlConfig.ps1
. .\WindowsFeatures.ps1
. .\xUnit.ps1

Pop-Location

Export-ModuleMember `
    -Alias @(
        '*') `
    -Function @(
          'Add-HostsFileEntry',
          'Add-IISHttpVerb',
          'Add-IISMimeType',
          'Add-LoopbackFix',
          'Add-XmlConfigValue',
          'Approve-Permissions',
          'Assert-That',
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
          'Get-WindowsFeatures',
          'Install-WebApplication',
          'Install-WindowsFeatures',
          'Invoke-BulkCopy',
          'Invoke-Chutzpah',
          'Invoke-CleanMSBuild',
          'Invoke-DBMigration',
          'Invoke-Deployment',
          'Invoke-DeployOctopusNugetPackage',
          'Invoke-Ecliptic',
          'Invoke-ElevatedCommand',
          'Invoke-EntityFrameworkMigrations',
          'Invoke-ExternalCommand',
          'Invoke-FromBase64', 
          'Invoke-GruntMinification',
          'Invoke-HealthCheck',
          'Invoke-HtmlDecode', 
          'Invoke-HtmlEncode',
          'Invoke-KarmaTests',
          'Invoke-MSBuild',
          'Invoke-Nunit',
          'Invoke-NUnitWithCoverage'
          'Invoke-SpecFlow',
          'Invoke-SqlFile',
          'Invoke-SqlStatement',
          'Invoke-ToBase64', 
          'Invoke-UrlDecode', 
          'Invoke-UrlEncode', 
          'Invoke-XmlDocumentTransform',
          'Invoke-XUnit',
          'Invoke-XUnitWithCoverage',
          'New-Application',
          'New-AppPool',
          'New-NugetPackage',
          'New-Site',
          'New-WarningsFromMSBuildLogs', 
          'Remove-Application',
          'Remove-AppPool',
          'Remove-Site',
          'RequiredFeatures',
          'Set-IISAuthentication',
          'Set-IISCustomHeader',
          'Set-PowershellScriptSigning',
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
          'Use-Object'
          )


# Messages
DATA msgs {
convertfrom-stringdata @"
    error_duplicate_step_name = Step {0} has already been defined.
    error_must_supply_a_feature = You must supply at least one Windows Feature.
    error_feature_set_invalid = The argument `"{0}`" does not belong to the set `"{1}`".
    error_admin_required = You are required to 'Run as Administrator' when running this deployment.
    error_loading_sql_file = Error loading '{0}'. {1}.
    error_octopus_deploy_failed = Failed to deploy: {0}.
    error_specflow_failed = Publishing specflow results  for '{0}' failed.
    error_coverage_failed = Running code coverage for '{0}' failed.
    error_tests_failed = Running tests '{0}' failed.
    error_msbuild_compile = Error compiling '{0}'.
    error_specflow_generation = Error generating the specflow feature files for '{0}'.
    error_chutzpah = Error running the chutzpah javascipt tests for '{0}'.
    wrn_full_permission = You have applied FULL permission to '{0}' for '{1}'. THIS IS DANGEROUS!
    wrn_cant_find = Could not find {0} with the name: {0}.
    msg_grant_permission = Granting {0} permissions to {1} for {2}.
    msg_enabling_windows_feature = Enabling Windows Feature: `"{0}`".
    msg_wasnt_found = `"{0}`" wasn't found.
    msg_updated_to = Updated `"{0}`" to `"{1}`".
    msg_updating_to = Updating `"{0}`" to `"{1}`".
    msg_changing_to = Changing `"{0}`" to `"{1}`".
    msg_overriding_to = Overriding node `"{0}`" with value `"{1}`".
    msg_updating_assembly = Updating AssemblyVersion to '{0}'. Updating AssemblyFileVersion to '{1}'. Updating AssemblyInformationalVersion to '{2}'.
    msg_not_updating = Not updating {0}, you must specify the '-updateIfFound' if you wish to update the {0} settings.
    msg_custom_header = Setting custom header '{0}' on site '{1}' to value '{2}'.
    msg_web_app_success = Successfully deployed Web Application '{0}'.
    msg_copying_content = Copying {0} content to {1}.
    msg_use_machine_environment = Using config for machine {0} instead of the {1} environment.
    msg_octopus_overrides = Checking for Octopus Overrides for environment '{0}'.
    msg_teamcity_importdata = ##teamcity[importData type='{0}' tool='{1}' path='{2}']
    msg_teamcity_buildstatus = ##teamcity[buildStatus text='{0}']
    msg_teamcity_buildstatisticvalue = ##teamcity[buildStatisticValue key='{0}' value='{1}']
    msg_add_loopback_fix = Adding loopback fix for '{0}'.
    msg_add_mime_type = Adding mime type '{0}' for extension '{1}' to IIS site '{2}'.
    msg_add_verb = Adding IIS Http Verb '{0}' to site '{1}'.
    msg_add_host_entry = Adding host entry for '{0}' into the hosts file.
    msg_validate_host_entry = Validating host entry for '{0} in the hosts file'
    msg_loopback_note = note: we're not disabling the loopback check all together, we are simply adding '{0}' to an allowed list.
    msg_disable_auth = Updating all authentication types for {0} to false.
    msg_update_auth = Updating {0} for {1} to {2}
"@
}