properties { 
    $buildScriptDir  = resolve-path .
    $baseDir  = resolve-path "$buildScriptDir\.."
    $buildDir = "$baseDir\build-artifacts" 
    $buildPublishDir = "$buildDir\publish"
    $packagesDir = "$baseDir\Packages"
    $modulesDir = "$baseDir\src\devops.build-release"


    #
    # Nuspec Properties
    #
    $devopsNugetPackage = "$baseDir\nuspec\fsm.buildrelease.nuspec"
    $gitNugetPackage = "$baseDir\nuspec\fsm.git.nuspec"
    $devopsSummary = "FSM Build-Release Modules"

    # Dogfood
    Import-Module "$modulesDir\BuildDeployModules" -force
    Write-BuildInformation (get-variable -scope 0)
}

Task default -depends Package
Task Package -depends PackageBuildRelease

Task SetupPaths {
    Write-Host "Adding some of our tools to the Path so we can run them easier"
    $env:Path += ";$packagesDir\NuGet.CommandLine.2.8.3\tools"
}

Task MakeBuildDir {
    Write-Host "Creating new build-artifacts directory"
    rm -r $buildDir -force -ea SilentlyContinue
    New-Item -ItemType Directory -Force -Path $buildDir
    New-Item -ItemType Directory -Force -Path $buildPublishDir
}

Task PackageBuildRelease -depends SetupPaths, MakeBuildDir {

    Update-XmlConfigValues $devopsNugetPackage "//*[local-name() = 'version']" $version
    Update-XmlConfigValues $devopsNugetPackage "//*[local-name() = 'summary']" "$devopsSummary v-$version"

    exec { NuGet.exe Pack $devopsNugetPackage -Version "$version.$buildNumber" -OutputDirectory $buildPublishDir -NoPackageAnalysis } "Failed to package the Devops Scripts."
}

FormatTaskName {
    param($taskName)
    Format-TaskNameToHost $taskName
}