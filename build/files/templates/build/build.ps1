<#
    The file may look quite verbose, but it'll get you setup with everything you need for a solid build script.

    Below is the [hashtable] use to store all of the required variables. Feel free to add custom variables to $this.
#>
#region Variable Block
    $rootDir  = resolve-path ".\.."
    $script:this = @{
        project = '[project]'
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
        solutionFile = "$rootDir\[solution].sln"
        rootNamespace = '[solution]'
        [project] = @{
                namespace = "[project]"
                solution = "$rootDir\src\[project]\[project].csproj"
                projectDir = "$rootDir\src\[project]"
                testAssemblyFile = "$rootDir\build-artifacts\output\[project].Tests.dll"
                unitTestNamespace = '[project].Tests.Unit'
                nuspecFile = "$rootDir\nuspec\[project].nuspec"
            }
    }
#endregion VariableBlock
Import-Module "$($this.packagesDir)\poshBAR.*\tools\modules\poshBAR" -force
# Import any other custom module you might need.

#default task (required by psake)
task default -depends compile, test, package
task compile -depends Compile[solution]
task test -depends Test[project]
task package -depends Package[project]


task Compile[solution] -depends Init {
    Update-AssemblyVersions $this.version $this.buildNumber $this.informationalVersion $this.[project].projectDir
    Update-AssemblyVersions $this.version $this.buildNumber $this.informationalVersion $this.[project].projectDir
    Invoke-MSBuild $this.artifactsDir.outputDir `
               $this.solutionFile `
               -logPath $this.artifactsDir.logsDir `
               -namespace $this.rootNamespace `
               -visualStudioVersion $this.visualStudioVersion
}

task Test[project] -depends Compile[project] {
    Invoke-NUnit $this.[project].testAssemblyFile $this.artifactsDir.resultsDir $this.[project].unitTestNamespace
}

task Package[project] -depends Compile[project] {
    Update-XmlConfigValues $this.[project].nuspecFile "//*[local-name() = 'version']" $this.version
    Update-XmlConfigValues $this.[project].nuspecFile "//*[local-name() = 'summary']" "$($this.[project].namespace) $($this.informationalVersion)"

    New-NugetPackage $this.[project].nuspecFile "$($this.version).$($this.buildNumber)" $this.artifactsDir.publishDir
}

# the init task simply finishes setting everything up.
task Init -depends MakeBuildDir, SetupPaths {
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
    # $envPATH += ";$rootDir\tools\someTool"
}

<#
    Improves the default FormatTaskName that comes with PSake 
    Leave this at the bottom of your script.
#>
FormatTaskName {
    param($taskName)
    Format-TaskNameToHost $taskName
}