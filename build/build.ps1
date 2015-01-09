properties { 

    # These params are passed in via the calling script
    Write-Host " "
    Write-Host " * Version: $version" -ForegroundColor Magenta
    Write-Host " * BuildNumber: $buildNumber" -ForegroundColor Magenta
    Write-Host " "

    $buildScriptDir  = resolve-path .
    $baseDir  = resolve-path "$buildScriptDir\.."
    $buildDir = "$baseDir\build-artifacts" 
    $buildPublishDir = "$buildDir\publish"
    $nugetRunnerDir = "$packagesDir\NuGet.CommandLine.2.8.3\tools"
    $modulesDir = "$baseDir\src\devops.build-release"


    #
    # Nuspec Properties
    #
    $devopsNugetPackage = "$baseDir\nuspec\fsm.buildrelease.nuspec"
    $gitNugetPackage = "$baseDir\nuspec\fsm.git.nuspec"
    $devopsSummary = "FSM Build-Release Modules"

    # Dogfood
     Import-Module "$modulesDir\BuildDeployModules" -force
}

Task default -depends Package
Task Package -depends PackageBuildRelease

Task SetupPaths {
    Write-Host "Adding some of our tools to the Path so we can run them easier"
    $env:Path += ";$nugetRunnerDir"
}

Task MakeBuildDir {
    Write-Host "Creating new build-artifacts directory"
    rm -R $buildDir -force -ea SilentlyContinue
    New-Item -ItemType Directory -Force -Path $buildDir
    New-Item -ItemType Directory -Force -Path $buildPublishDir
}

Task PackageBuildRelease -depends SetupPaths, MakeBuildDir {

    Update-ConfigValues $devopsNugetPackage "//*[local-name() = 'version']" $version
    Update-ConfigValues $devopsNugetPackage "//*[local-name() = 'summary']" "$devopsSummary v-$version"

    exec { NuGet.exe Pack $devopsNugetPackage -Version "$version.$buildNumber" -OutputDirectory $buildPublishDir -NoPackageAnalysis } "Failed to package the Devops Scripts."
}

FormatTaskName {
    param($taskName)
    Format-TaskNameToHost $taskName
}