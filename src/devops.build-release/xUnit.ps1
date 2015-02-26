function Invoke-XUnit ([string] $targetAssembly, [string] $outputDir, [string] $runCommand){
        if ( $includeCoverage ){
        Invoke-XUnitWithCoverage $targetAssembly $outputDir $runCommand
    } else {
        $fileName = Get-TestFileName $outputDir $runCommand
        $xmlFile = "$fileName-TestResults.xml"
        $txtFile = "$fileName-TestResults.txt"
        
        Write-Host "xunit.console.exe $targetAssembly /xml $xmlFile"
        exec {xunit.console.exe $targetAssembly /xml $xmlFile} "Error invoking xunit"
        Write-Host "done"
    }
}

function Invoke-XUnitWithCoverage  ([string] $targetAssembly, [string] $outputDir, [string] $runCommand){
    $fileName = Get-TestFileName $outputDir $runCommand

    $xmlFile = "$fileName-TestResults.xml"
    $txtFile = "$fileName-TestResults.txt"
    $coverageFile = "$fileName-CoverageResults.dcvr"

    exec{ dotcover.exe cover /TargetExecutable=$xunitRunnerDir\xunit.console.exe /TargetArguments="$targetAssembly /xml $xmlFile" /Output=$coverageFile /ReportType=html} ($msgs.error_coverage_failed -f $runCommand)
    $msgs.msg_teamcity_importdata -f 'dotNetCoverage', 'dotcover', $coverageFile
}