function Invoke-Nunit {
    [CmdletBinding()]
    param( 
        [string] $targetAssembly, 
        [string] $outputDir, 
        [string] $runCommand, 
        [bool] $includeCoverage,
        [string] $coverageRulesPath )
    Find-ToolPath 'nunit-console.exe'
    if ( $includeCoverage ){
        Invoke-NUnitWithCoverage $targetAssembly $outputDir $runCommand $coverageRulesPath
    } else {
        $fileName = Get-TestFileName $outputDir $runCommand

        $xmlFile = "$fileName-TestResults.xml"
        $txtFile = "$fileName-TestResults.txt"
        
        exec { nunit-console.exe $targetAssembly /fixture:$runCommand /xml=$xmlFile /out=$txtFile /nologo /framework=4.0 /labels } ($msgs.error_tests_failed -f $runCommand)
    }    
}

function Invoke-NUnitWithCoverage {
    [CmdletBinding()]
    param( 
        [string] $targetAssembly, 
        [string] $outputDir, 
        [string] $runCommand, 
        [string] $coverageRulesPath)
    Find-ToolPath 'nunit-console.exe'
    Find-ToolPath 'dotcover.exe'
    $fileName = Get-TestFileName $outputDir $runCommand

    $xmlFile = "$fileName-TestResults.xml"
    $txtFile = "$fileName-TestResults.txt"
    $coverageFile = "$fileName-CoverageResults.dcvr"

    # who knows, this might fall over one day.
    $nu = resolve-path ".\..\packages\nunit.runners.*\tools\nunit-console.exe"
    exec{ dotcover.exe cover $coverageRulesPath /TargetExecutable=$nu /TargetArguments="$targetAssembly /fixture:$runCommand /xml=$xmlFile /out=$txtFile /nologo /framework=4.0 /labels" /Output=$coverageFile /ReportType=html } ($msgs.error_coverage_failed -f $runCommand)
    $msgs.msg_teamcity_importdata -f 'dotNetCoverage', 'dotcover', $coverageFile
}

function Get-ConfigFile ($input) {
    $x = $input -replace ".dll", ".config"
    $x = $x -replace ".", "-"
    return $x
}