
function Get-TestFileName ( [string] $outputDir, [string] $runCommand ){
    $fileName = $runCommand -replace "\.", "-"
    return "$outputDir\$fileName"
}