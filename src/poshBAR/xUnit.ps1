<#
    .SYNOPSIS
        Runs XUnit against a test dll
    .DESCRIPTION
        
    .PARAMETER targetAssembly
        The target test assembly
    .PARAMETER outputDir
        The directory to store the output
    .PARAMETER runCommand
        The namespace to start the tests from
    .PARAMETER includeCoverage
        Switch to tell if we want coverage on the tests
    .PARAMETER coverageRulesPath
        Path to coverage rules
    .EXAMPLE
        Invoke-Nunit "$buildDir\myTestAssembly.dll" "$outputDir" "myAssembly.Unit" -includeCoverage "$coverageRulesPath"
    .NOTES
        Currently 'includeCoverage' invokes the DotCover coverage tool. Some day we'll need to re-think how we want to achieve this.
#>
function Invoke-XUnit{
    [CmdletBinding()]
    param( 
        [string] $targetAssembly, 
        [string] $outputDir, 
        [string] $runCommand, 
        [bool] $includeCoverage,
        [string] $coverageRulesPath )

        Find-ToolPath 'xunit'

    if ( $includeCoverage ){
        Invoke-XUnitWithCoverage $targetAssembly $outputDir $runCommand $coverageRulesPath
    } else {
        $fileName = Get-TestFileName $outputDir $runCommand
        
        $xmlFile = "$fileName-TestResults.xml"
        $txtFile = "$fileName-TestResults.txt"

        exec { xunit.console.exe $targetAssembly /xml $xmlFile } ($msgs.error_tests_failed -f $runCommand)
    }
}

<#
    .SYNOPSIS
        Runs XUnit against a test dll
    .DESCRIPTION
        
    .PARAMETER targetAssembly
        The target test assembly
    .PARAMETER outputDir
        The directory to store the output
    .PARAMETER runCommand
        The namespace to start the tests from
    .PARAMETER coverageRulesPath
        Path to coverage rules
    .EXAMPLE
        Invoke-XUnitWithCoverage "$buildDir\myTestAssembly.dll" "$outputDir" "myAssembly.Unit" "$coverageRulesPath"
    .NOTES
        Currently 'includeCoverage' invokes the DotCover coverage tool. Some day we'll need to re-think how we want to achieve this.
#>
function Invoke-XUnitWithCoverage {
    [CmdletBinding()]
    param( 
        [string] $targetAssembly, 
        [string] $outputDir, 
        [string] $runCommand, 
        [string] $coverageRulesPath)
        
        Find-ToolPath 'xunit'
        Find-ToolPath 'dotcover'
    
    $fileName = Get-TestFileName $outputDir $runCommand

    $xmlFile = "$fileName-TestResults.xml"
    $txtFile = "$fileName-TestResults.txt"
    $coverageFile = "$fileName-CoverageResults.dcvr"
    
    # who knows, this might fall over one day.
    $xu = resolve-path ".\..\packages\xunit.runners.*\tools\xunit-console.exe"
    exec{ dotcover.exe cover $coverageRulesPath /TargetExecutable=$xu /TargetArguments="$targetAssembly /fixture:$runCommand /xml=$xmlFile /out=$txtFile /nologo /framework=4.0" /Output=$coverageFile /ReportType=html} ($msgs.error_coverage_failed -f $runCommand)
    $msgs.msg_teamcity_importdata -f 'dotNetCoverage', 'dotcover', $coverageFile
}