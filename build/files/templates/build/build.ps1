<#
    The file may look quite verbose, but it'll get you setup with everything you need for a solid build script.

    Below is the [hashtable] use to store all of the required variables. Feel free to add custom variables to $this.
#>
#region Variable Block
    $rootDir  = resolve-path ".\.."
    $script:this = @{
        project = 'myProject'
        rootDir = Resolve-Path "$rootDir"
        path = Resolve-Path "$rootDir\build"
        modulesDir = "$rootDir\build\modules"
        environmentsDir = "$rootDir\build\environments"
        visualStudioVersion = "12.0"
        artifactsDir = @{
            rootDir = "$rootDir\build-artifacts"
            logsDir = "$rootDir\build-artifacts\logs"
            outputDir =  "$rootDir\build-artifacts\output"
            resultsDir = "$rootDir\build-artifacts\results"
            publishDir = "$rootDir\build-artifacts\publish"
            workingDir = "$rootDir\build-artifacts\working"
        }
        packagesDir = "$rootDir\packages"
        nuspecDir = "$rootDir\nuspec"
        solutionFile = "$rootDir\[MY-APP].sln"
        rootNamespace = '[My.App]'
        myFirstApp = @{
                namespace = "[My.First.App]"
                solution = "$rootDir\src\[my.first.app]\[MY-FIRST-APP].csproj"
                projectDir = "$rootDir\src\[my.first.app]"
                testAssemblyFile = "$rootDir\build-artifacts\output\[My.First.App].Tests.dll"
                unitTestNamespace = '[My.First.App].Tests.Unit'
                nuspecFile = "$rootDir\nuspec\[My.First.App].nuspec"
            }
        mySecondApp = @{
                namespace = "[My.Second.App]"
                solution = "$baseDir\src\[my.second.app]\[MY-SECOND-APP].csproj"
                projectDir = "$rootDir\src\[my.second.app]"
                testAssemblyFile = "$rootDir\build-artifacts\output\[My.Second.App].Tests.dll"
                unitTestNamespace = '[My.Second.App].Tests.Unit'
                nuspecFile = "$rootDir\nuspec\[My.Second.App].nuspec"
            }
    }
#endregion VariableBlock
Import-Module "$($this.packagesDir)\poshBAR.*\tools\modules\poshBAR" -force
# Import any other custom module you might need.

#default task (required by psake)
task default -depends TestFirstApp, TestSecondApp, PackageFirstApp, PackageSecondApp


task CompileSolution -depends Init {
    Update-AssemblyVersions $this.version $this.buildNumber $this.informationalVersion $this.myFirstApp.projectDir
    Update-AssemblyVersions $this.version $this.buildNumber $this.informationalVersion $this.mySecondApp.projectDir
    Invoke-MSBuild $this.artifactsDir.outputDir $this.solutionFile $this.artifactsDir.logsDir $this.rootNamespace $this.visualStudioVersion 
}

task TestFirstApp -depends CompileSolution {
    Invoke-NUnit $this.myFirstApp.testAssemblyFile $this.artifactsDir.resultsDir $this.myFirstApp.unitTestNamespace
}

task TestFirstApp -depends CompileSolution {
    Invoke-NUnit $this.mySecondApp.testAssemblyFile $this.artifactsDir.resultsDir $this.mySecondApp.unitTestNamespace
}

task PackageFirstApp -depends CompileSolution {
    Update-XmlConfigValues $this.myFirstApp.nuspecFile "//*[local-name() = 'version']" $this.version
    Update-XmlConfigValues $this.myFirstApp.nuspecFile "//*[local-name() = 'summary']" "$($this.myFirstApp.namespace) $($this.informationalVersion)"

    New-NugetPackage $this.myFirstApp.nuspecFile "$($this.version).$($this.buildNumber)" $this.artifactsDir.publishDir
}

task PackageSecondApp -depends CompileSolution {
    Update-XmlConfigValues $this.mySecondApp.nuspecFile "//*[local-name() = 'version']" $this.version
    Update-XmlConfigValues $this.mySecondApp.nuspecFile "//*[local-name() = 'summary']" "$($this.mySecondApp.namespace) $($this.informationalVersion)"

    New-NugetPackage $this.mySecondApp.nuspecFile "$($this.version).$($this.buildNumber)" $this.artifactsDir.publishDir
}

# the init task simply finishes setting everything up.
task Init -depends MakeBuildDir SetupPaths {
    $this.version = $version
    $this.environment = $buildEnvironment
    $this.buildNumber = $buildNumber
    $this.informationalVersion = $informationalVersion
    $this.includeCoverage = $includeCoverage
    $script:environmentSettings = Get-EnvironmentSettings $this.environment "//environmentSettings" $this.environmentsDir
    Framework '4.0'
}

task MakeBuildDir {
    Write-Host "[re]Generating build-artifacts directory."
    # iterate over all of the nested artifacts directories, deleting the contents and re-creating the directory
    $this.artifactsDir.keys | %{ 
        remove-item -force -recurse $this.artifactsDir[$_] -ErrorAction SilentlyContinue 
        New-Item -ItemType Directory -Force -Path $this.artifactsDir[$_] | Out-Null
    }
    # uncomment if you want MSBUILD to clean the build output directory.
    # Invoke-CleanMSBuild $this.solutionFile
}

task SetupPaths {
    # used to add a custom tool to your $env:PATH if it's not in a standard location.
    $poshBAR.Paths['someToolPath'] = "$here\tools\someTool"
}

<#
    Improves the default FormatTaskName that comes with PSake 
    Leave this at the bottom of your script.
#>
FormatTaskName {
    param($taskName)
    Format-TaskNameToHost $taskName
}