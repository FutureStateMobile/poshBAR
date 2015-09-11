<#
    .SYNOPSIS
        Runs SpecFlow tests against a test dll using the specified testing framework
          
     .PARAMETER testProjectFile
            the .csproj file containing your tests.
          
    .PARAMETER testAssemblyFile
        The target test assembly (dll)
    
    .PARAMETER outputDir
        The directory to store the output
    
    .PARAMETER runCommand
        The namespace to start the tests from
    
    .PARAMETER testingFramework
        Which testing framework is being leveraged (nunit & xunit supported)
    
    .PARAMETER coverageRulesPath
        Path to coverage rules
        
    .PARAMETER includeCoverage
        Switch to tell if we want coverage on the tests
    
    .PARAMETER showSpecflowReport
        Should the specflow report be loaded in the browser after testing is complete.
    
    .EXAMPLE
        Invoke-Nunit "$buildDir\myTestAssembly.dll" "$outputDir" "myAssembly.Unit" -includeCoverage "$coverageRulesPath"
    
    .NOTES
        Currently 'includeCoverage' invokes the DotCover coverage tool. Some day we'll need to re-think how we want to achieve this.
#>
function Invoke-SpecFlow {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true, Position=0)] [string] $testProjectFile, 
        [parameter(Mandatory=$true, Position=1)] [string] $testAssemblyFile, 
        [parameter(Mandatory=$true, Position=2)] [string] $outputDir, 
        [parameter(Mandatory=$true, Position=3)] [string] $runCommand,
        [parameter(Mandatory=$true, Position=4)] [ValidateSet('nunit','xunit')] $testingFramework,
        [parameter(Mandatory=$false, Position=5)] [string] $coverageRulesPath,
        [parameter(Mandatory=$false, Position=6)] [switch] $includeCoverage,
        [parameter(Mandatory=$false, Position=7)] [switch] $showSpecflowReport
    )

    $fileName = Get-TestFileName $outputDir $runCommand
    
    $xmlFile = "$fileName-TestResults.xml"
    $txtFile = "$fileName-TestResults.txt"
    $htmlFile = "$fileName.html"
    Find-ToolPath 'specflow.exe'
    try{        
        if($testingFramework -eq "nunit"){
            $tf = "nunitexecutionreport"
            Invoke-NUnit $testAssemblyFile $outputDir $runCommand -includeCoverage:$includeCoverage -coverageRulesPath:$coverageRulesPath
        }

        if($testingFramework -eq "xunit"){
            $tf = "xunitexecutionreport"
            Invoke-XUnit $testAssemblyFile $outputDir $runCommand -includeCoverage:$includeCoverage -coverageRulesPath:$coverageRulesPath
        }
    } finally {
        exec { specflow.exe $tf $testProjectFile /xmlTestResult:$xmlFile /testOutput:$txtFile /out:$htmlFile } ($msgs.error_specflow_failed -f $fileName)
        if($showSpecflowReport){
            Invoke-Expression $htmlFile
        }
    }
}