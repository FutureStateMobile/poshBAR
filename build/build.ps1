$errorActionPreference = 'Stop'
$baseDir  = resolve-path ".\.."
$script:this = @{
    buildDir = "$baseDir\build-artifacts" 
    resultsDir = "$baseDir\build-artifacts\results"
    buildPublishDir = "$baseDir\build-artifacts\publish"
    packagesDir = "$baseDir\Packages"
    workingDir = "$baseDir\build-artifacts\Working"
    srcDir = "$baseDir\src\poshBAR"
    devopsNugetPackage = "$baseDir\nuspec\poshBAR.nuspec"
    devopsSummary = "Powershell Build `$amp; Release"
    testDir = "$baseDir\src\tests"
}

# Dogfood (dog eats own tail)
Import-Module "$($this.srcDir)\poshBAR" -force -Global

Task default -depends RunPesterTests, Package

Task SetupPaths {
    Write-Host "Adding some of our tools to the Path so we can run them easier"
    $env:Path += ";$($this.packagesDir)\NuGet.CommandLine.3.3.0\tools"
}

Task MakeBuildDir {
    Write-Host "Creating new build-artifacts directory"
    $this.buildDir
    rm -r $this.buildDir -force -ea SilentlyContinue
    New-Item -ItemType Directory -Force -Path $this.buildPublishDir
    New-Item -ItemType Directory -Force -Path $this.workingDir
    New-Item -ItemType Directory -Force -Path "$($this.workingDir)\poshBar"
    New-Item -ItemType Directory -Force -Path $this.resultsDir
}

Task UpdateVersion -depends MakeBuildDir {
    copy "$($this.srcDir)\*" "$($this.workingDir)\poshBar" -recurse

    Push-Location "$($this.workingDir)\poshBar"

    $versionPattern = '^\$version = [''|"](\d.\d.\d)[''|"] .*'
    $buildNumberPattern = '^\$buildNumber = [''|"](\d)[''|"] .*'
    $versionOutput = "`$version = '$version' # contains the current version of poshBAR"
    $buildNumberOutput = "`$buildNumber = '$buildNumber' # contains the current build number of poshBAR"
    
    ls -r -filter poshBAR.psm1 | % {
        $filename = $_.Directory.ToString() + '\' + $_.Name
        (Get-Content $filename) | % {
            % {$_ -replace $versionPattern, $versionOutput } |
            % {$_ -replace $buildNumberPattern, $buildNumberOutput }
        } | Out-File "$filename.temp"

        rm $filename -force
        ren "$filename.temp" $filename
        "$filename - Updated to $version.$buildNumber"
    }
    Pop-Location
}

Task GenerateDocumentation -depends SetupPaths, UpdateVersion, MakeBuildDir -alias docs {
    Exec {.\out-html.ps1 -moduleName 'poshBAR' -outputDir "$baseDir"} -retry 10 # retry because of the build agent issues when committing multiple branches.
}

Task Package -depends SetupPaths, UpdateVersion, MakeBuildDir, GenerateDocumentation {

    Update-XmlConfigValues $this.devopsNugetPackage "//*[local-name() = 'summary']" "$($this.devopsSummary) v-$version"
    exec { NuGet.exe Pack $this.devopsNugetPackage -Version "$version.$buildNumber" -OutputDirectory $this.buildPublishDir -NoPackageAnalysis } "Failed to package the Devops Scripts."
}

Task RunPesterTests -depends UpdateVersion, MakeBuildDir -alias tests {
    $tmp = $env:TEMP
    $env:TEMP = $this.workingDir
       
    # re-import poshBAR after changes.
    Remove-Module poshBAR -force
    Import-Module "$($this.workingDir)\poshBar" -force
    
    Import-Module "$($this.packagesDir)\pester.*\tools\pester.psm1" -force  -Global
    $results = Invoke-Pester -relative_path $this.testDir -TestName $pesterTestName -PassThru -OutputFile "$($this.resultsDir)\pester.xml" -OutputFormat NUnitXml
    if($results.FailedCount -gt 0) {
        throw "$($results.FailedCount) Tests Failed."
    }
    
    $env:TEMP = $tmp
}

FormatTaskName {
    param($taskName)
    Format-TaskNameToHost $taskName
}
