$buildScriptDir  = resolve-path .
$baseDir  = resolve-path "$buildScriptDir\.."
$buildDir = "$baseDir\build-artifacts"
$buildOutputDir = "$buildDir\output" 
$buildPublishDir = "$buildDir\publish"
$buildTestResultsDir = "$buildDir\results" 
$buildLogDir = "$buildDir\logs"
$buildWarningReportDir = "$buildLogDir\BuildWarningReport"
$workingDir = "$buildDir\working"
$packagesDir = "$baseDir\packages"
$solutionFile = "$baseDir\[MY-APP].sln"

Import-Module "$baseDir\packages\fsm.buildrelease.*\tools\modules\BuildDeployModules" -force


task default -depends Init
task Init -depends MakeBuildDir {
    $script:environmentSettings = Get-EnvironmentSettings $buildEnvironment "//environmentSettings" "$baseDir\build\environments"
    Framework '4.0'
}

task MakeBuildDir -depends Clean {
    Write-Host "Creating new build-artifacts directory"
    New-Item -ItemType Directory -Force -Path $buildOutputDir | Out-Null
    New-Item -ItemType Directory -Force -Path $buildPublishDir | Out-Null
    New-Item -ItemType Directory -Force -Path $buildTestResultsDir | Out-Null
    New-Item -ItemType Directory -Force -Path $buildLogDir | Out-Null
    New-Item -ItemType Directory -Force -Path $buildWarningReportDir | Out-Null
    New-Item -ItemType Directory -Force -Path $workingDir | Out-Null
}

task Clean -depends SetupPaths { 
    Write-Host "Cleaning old build-artifacts directory"
    remove-item -force -recurse $buildOutputDir -ErrorAction SilentlyContinue 
    remove-item -force -recurse $buildPublishDir -ErrorAction SilentlyContinue 
    remove-item -force -recurse $buildTestResultsDir -ErrorAction SilentlyContinue 
    remove-item -force -recurse $buildLogDir -ErrorAction SilentlyContinue
    remove-item -force -recurse $buildWarningReportDir -ErrorAction SilentlyContinue
    remove-item -force -recurse $workingDir -ErrorAction SilentlyContinue

    # exec { msbuild $solutionFile /t:clean /v:q /nologo /p:VisualStudioVersion=12.0 } "Error cleaning the solution."
} 

task SetupPaths {
    Write-Host "Adding some of our tools to the Path so we can run them easier"
    $toolsPath += ";$packagesDir\NuGet.CommandLine.2.8.3\tools"
    $toolsPath += ";$buildOutputDir"
    Write-Host "Path" -nonewline; Write-Host $toolsPath -f DarkGray
    $env:Path += $toolsPath
}

### Improves the default FormatTaskName that comes with PSake ###
FormatTaskName {
    param($taskName)
    Format-TaskNameToHost $taskName
}