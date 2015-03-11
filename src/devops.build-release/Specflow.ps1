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