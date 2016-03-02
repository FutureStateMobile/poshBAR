$version = '1.0.0' # contains the current version of poshBAR
$buildNumber = '1' # contains the current build number of poshBAR

if (Get-Module 'poshBAR') { return }
$global:poshBAR = @{
    'version' = $version
    'buildNumber' = $buildNumber
}

$currentThread = [System.Threading.Thread]::CurrentThread
$culture = [System.Globalization.CultureInfo]::InvariantCulture
$currentThread.CurrentCulture = $culture
$currentThread.CurrentUICulture = $culture

Write-Host @"
poshBAR version: $version
poshBar buildNumber: $buildNumber
Copyright ($([char]0x00A9)) Future State Mobile Inc. & Contributors
"@

Remove-Item alias:new -ea SilentlyContinue
Set-Alias new New-Object

Push-Location $psScriptRoot

# Set Overrides
. .\OctopusDeploy\Set-OverridesFromOctopusDeploy.ps1 $poshBAR
. .\TeamCity\Set-TeamCityEnvironment.ps1 $poshBAR

# Import Modules
. .\Add-HostsFileEntry.ps1
. .\Add-IISHttpVerb.ps1
. .\Add-IISMimeType.ps1
. .\Add-LoopbackFix.ps1
. .\Assert-That.ps1
. .\Assert-PSVersion.ps1
. .\Certificates.ps1
. .\Find-ToolPath.ps1
. .\ApplicationAdministration.ps1
. .\AppPoolAdministration.ps1
. .\AppPool-Start-Stop-IISAdminTool.ps1
. .\Approve-Permissions.ps1
. .\Assert-PSVersion.ps1
. .\Chutzpah.ps1
. .\DbDeploy.ps1
. .\Ecliptic.ps1
. .\EntityFramework.ps1
. .\Expand-NugetPackage.ps1
. .\Expand-ZipFile.ps1
. .\Format-TaskNameToHost.ps1
. .\Get-EnvironmentSettings.ps1
. .\Get-CurrentGitBranchAndSha1.ps1
. .\Grunt.ps1
. .\HealthCheck.ps1
. .\Helpers.ps1
. .\Install-WebApplication.ps1
. .\Install-WebApplicationToFolder.ps1
. .\Invoke-AspNetRegIIS.ps1
. .\Invoke-Deployment.ps1
. .\Invoke-DeployOctopusNugetPackage.ps1
. .\Invoke-ElevatedCommand.ps1
. .\Invoke-ExternalCommand.ps1
. .\Lock-Object.ps1
. .\MSBuild.ps1
. .\Nuget.ps1
. .\New-Directory.ps1
. .\nUnit.ps1
. .\Set-IISAuthentication.ps1
. .\Set-IISCustomHeader.ps1
. .\Invoke-PowershellScriptSigning.ps1
. .\Read-CredentialsToHashtable.ps1
. .\Remove-Directory.ps1
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
. .\Oracle.ps1
. .\TokenReplacement.ps1

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
          'Find-ToolPath'
          'Approve-Permissions',
          'Assert-That',
          'Assert-PSVersion',
          'Confirm-ApplicationExists',
          'Confirm-AppPoolExists',
          'Confirm-SiteExists',
          'Exec',
          'Expand-NugetPackage',
          'Get-VersionFromNuspec',
          'Expand-ZipFile',
          'Format-TaskNameToHost',
          'Get-Application',
          'Get-Applications',
          'Get-AppPool',
          'Get-AppPools',
          'Get-CurrentGitBranchAndSha1',
          'Get-DatabaseConnection',
          'Get-EnvironmentSettings',
          'Get-PfxCertificate',
          'Get-Site',
          'Get-Sites',
          'Get-TestFileName',
          'Get-WindowsFeatures',
          'Install-WebApplication',
          'Install-WebApplicationToFolder',
          'Install-WindowsFeatures',
          'Invoke-AspNetRegIIS',
          'Invoke-BulkCopy',
          'Invoke-Chutzpah',
          'Invoke-CleanMSBuild',
          'Invoke-DBMigration',
          'Invoke-DBDeploy',
          'Invoke-Deployment',
          'Invoke-DeployOctopusNugetPackage',
          'Invoke-Ecliptic',
          'Invoke-ElevatedCommand',
          'Invoke-EntityFrameworkMigrations',
          'Invoke-ExternalCommand',
          'Invoke-FromBase64', 
          'Invoke-GruntMinification',
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
          'Invoke-WebHealthCheck',
          'Invoke-XmlDocumentTransform',
          'Invoke-XUnit',
          'Invoke-XUnitWithCoverage',
          'Lock-Object',
          'New-Application',
          'New-AppPool',
          'New-Certificate',
          'New-CertificateSigningRequest',
          'New-Directory',
          'New-NugetPackage',
          'New-PfxCertificate',
          'New-PrivateKey',
          'New-PrivateKeyAndCertificateSigningRequest',
          'New-Site',
          'Read-CredentialsToHashtable',
          'Remove-Application',
          'Remove-AppPool',
          'Remove-Directory'
          'Remove-Site',
          'RequiredWindowsFeatures',
          'Set-IISAuthentication',
          'Set-IISCustomHeader',
          'Invoke-PowershellScriptSigning',
          'Set-WebConfigurationPropertyExtended',
          'Start-Application',
          'Start-AppPool',
          'Start-Stop-AppPool',
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
          'Use-Object',
          'Invoke-OracleCommand',
          'Invoke-OracleFile',
          'Remove-OracleDatabase',
          'New-OracleDatabase',
          'Reset-OracleDatabase',
          'Invoke-BlockWithTokenReplacedFile',
          'Write-TokenReplacedFile'
          )

# Messages
DATA msgs {
convertfrom-stringdata @"
    test_message = This is a test.
    error_duplicate_step_name = Step {0} has already been defined.
    error_must_supply_a_feature = You must supply at least one Windows Feature.
    error_feature_set_invalid = The argument `"{0}`" does not belong to the set `"{1}`".
    error_admin_required = You are required to 'Run as Administrator' when running this deployment.
    error_loading_sql_file = Error loading '{0}'. {1}.
    error_octopus_deploy_failed = Failed to deploy: {0}.
    error_specflow_failed = Publishing specflow results  for '{0}' failed.
    error_coverage_failed = Running code coverage for '{0}' failed.
    error_tests_failed = Running tests '{0}' failed.
    error_failed_execution = Failed to execute '{0}'.
    error_msbuild_compile = Error compiling '{0}'.
    error_specflow_generation = Error generating the specflow feature files for '{0}'.
    error_chutzpah = Error running the chutzpah javascipt tests for '{0}'.
    error_cannot_find_tool = Could not find {0}, please specify it's path to `$env:PATH
    error_windows_features_admin_disabled = Enabling {0} is not permitted because "DisableWindowsFeaturesAdministration" has been set to "true" for this environment.
    error_invalid_windows_feature = {0} is not a valid Windows Feature. Please verify against {1}
    error_aspnet_regiis_not_found = aspnet_regiis.exe was not found on this machine.
    error_apppool_creation_disabled = Creating an application pool is not permitted because "DisableCreateIISApplicationPool" has been set to "true" for this environment.
    error_website_creation_disabled = Creating a website is not permitted because "DisableCreateIISWebsite" has been set to "true" for this environment.
    error_webapplication_creation_disabled = Creating a web application is not permitted because "DisableCreateIISApplication" has been set to "true" for this environment.
    error_healthchecks_failed = {0} of {1} Health Check[s] Failed.
    wrn_aspnet_regiis_not_found = An error occurred while trying to register IIS. If you're running this command on Server => 2012, please add IIS-ASPNET45 as a Windows Feature.
    wrn_aspnet_regiis_disabled = Installing ASP.NET {0} is not permitted because "DisableGlobalASPNETRegIIS" has been set to "true".
    wrn_host_file_admin_disabled = Editing the host file is not permitted because "DisableHostFileAdministration" has beeen set to "true" for this environment.
    wrn_loopback_fix_disabled = Adding a loopback fix to the registry is not permitted because "DisableLoopbackFix" has been set to "true" for this environment.
    wrn_full_permission = You have applied FULL permission to '{0}' for '{1}'. THIS IS DANGEROUS!
    wrn_cant_find = Could not find {0} with the name: {0}.
    msg_healthchecks_passed = {0} Health Check[s] Passed for {1}.
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
    msg_use_machine_environment = Transforming config file {0}.xml with {1}.xml (xdt transform).
    msg_octopus_overrides = Checking for overrides for environment '{0}'.
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
$poshBAR.msgs = $msgs # Exporting the messages so that they can be used in tests.
