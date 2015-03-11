function Get-TestFileName ( [string] $outputDir, [string] $runCommand ){
    $fileName = $runCommand -replace "\.", "-"
    return "$outputDir\$fileName"
}

function Assert-That
{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)]$conditionToCheck,
        [Parameter(Position=1,Mandatory=1)]$failureMessage
    )
    if (!$conditionToCheck) {
        throw ("Assert: " + $failureMessage)
    }
}
Set-Alias Assert Assert-That