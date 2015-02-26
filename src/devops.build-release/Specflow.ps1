function Invoke-SpecFlow {
    param(
        [parameter(Mandatory=$true, Position=0)] [string] $testProjectFile, 
        [parameter(Mandatory=$true, Position=1)] [string] $outputDir, 
        [parameter(Mandatory=$true, Position=2)] [string] $runCommand,
        [parameter(Mandatory=$true, Position=3)] [ValidateSet('nunit','xunit')] $testingFramework
    )
    $fileName = Get-TestFileName $outputDir $runCommand
    
    $xmlFile = "$fileName-TestResults.xml"
    $txtFile = "$fileName-TestResults.txt"
    $htmlFile = "$fileName.html"

    if($testingFramework -eq "nunit"){
        $tf = "nunitexecutionreport"
        Invoke-NUnit $testProjectFile $outputDir $runCommand
    }

    if($testingFramework -eq "xunit"){
        $tf = "xunitexecutionreport"
        Invoke-XUnit $testProjectFile $outputDir $runCommand
    }

    exec { specflow.exe $tf $testProjectFile /xmlTestResult:$xmlFile /testOutput:$txtFile /out:$htmlFile } "whoops" #($msgs.error_specflow_failed -f $fileName)
}