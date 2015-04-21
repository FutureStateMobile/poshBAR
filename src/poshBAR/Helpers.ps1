
function Get-TestFileName ( [string] $outputDir, [string] $runCommand ){
    $fileName = $runCommand -replace "\.", "-"
    return "$outputDir\$fileName"
}

<#
    .DESCRIPTION
        Asserts that the condition is true
             
    .SYNOPSIS
        Asserts that the condition is true, and if it is not, will throw the specified failure message.

    .EXAMPLE
        Assert-That ($name -ne $null) "Name cannot be null."


    .PARAMETER conditionToCheck
        The condition that you're asserting

    .PARAMETER failureMessage
        The message to throw if the condition is not met.

#>
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