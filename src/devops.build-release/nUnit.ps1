function Invoke-Nunit ( [string] $targetAssembly, [string] $outputDir, [string] $runCommand, [string] $testAssemblyRootNamespace ) {

    if ( $includeCoverage ){
        Invoke-NUnitWithCoverage $targetAssembly $outputDir $runCommand $testAssemblyRootNamespace
    } else {
        $fileName = Get-TestFileName $outputDir $runCommand

        $xmlFile = "$fileName-TestResults.xml"
        $txtFile = "$fileName-TestResults.txt"
        
        exec { nunit-console.exe $targetAssembly /fixture:$runCommand /xml=$xmlFile /out=$txtFile /nologo /framework=4.0 } ($msgs.error_tests_failed -f $runCommand)
    }    
}

function Invoke-NUnitWithCoverage ( [string] $targetAssembly, [string] $outputDir, [string] $runCommand, [string] $testAssemblyRootNamespace){
    $fileName = Get-TestFileName $outputDir $runCommand

    $xmlFile = "$fileName-TestResults.xml"
    $txtFile = "$fileName-TestResults.txt"
    $coverageFile = "$fileName-CoverageResults.dcvr"

    $coverageConfig = (Get-TestFileName "$buildFilesDir\coverageRules" $testAssemblyRootNamespace) + ".config"
    # /AttributeFilters="Test;TestFixture;SetUp;TearDown"
    Write-Host "dotcover.exe cover $coverageConfig /TargetExecutable=$nunitRunnerDir\nunit-console.exe /TargetArguments=$targetAssembly /fixture:$runCommand /xml=$xmlFile /out=$txtFile /nologo /framework=4.0 /Output=$coverageFile /ReportType=html /Filters=$coverageFilter"
    exec{ dotcover.exe cover $coverageConfig /TargetExecutable=$nunitRunnerDir\nunit-console.exe /TargetArguments="$targetAssembly /fixture:$runCommand /xml=$xmlFile /out=$txtFile /nologo /framework=4.0" /Output=$coverageFile /ReportType=html } ($msgs.error_coverage_failed -f $runCommand)
    $msgs.msg_teamcity_importdata -f 'dotNetCoverage', 'dotcover', $coverageFile
}

function Invoke-NunitSpecFlow ( [string] $testProjectFile, [string] $outputDir, [string] $runCommand ) {
    $fileName = Get-TestFileName $outputDir $runCommand

    $xmlFile = "$fileName-TestResults.xml"
    $txtFile = "$fileName-TestResults.txt"
    $htmlFile = "$fileName.html"

    exec { specflow.exe nunitexecutionreport $testProjectFile /xmlTestResult:$xmlFile /testOutput:$txtFile /out:$htmlFile } ($msgs.error_specflow_failed -f $fileName)
}
