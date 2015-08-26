<#
    .DESCRIPTION
        Writes the message to the Host formatted to be easy to read

    .EXAMPLE
        Format-TaskNameToHost "Doing Some Task"
        This is a sample of how to use the method on it's own
            
    .EXAMPLE
        FormatTaskName { param($taskName) Format-TaskNameToHost $taskName }
        Input this into your psake build script to upgrade the output headers.

    .PARAMETER taskName
        The Name of the task you are executing

    .SYNOPSIS
        This is just a simple helper function to write the current task name to screen in a nice friendly way.

    .NOTES
        We use this in conjunction with psake for writing headers. 
#>
function Format-TaskNameToHost
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string] $taskName
    )

    $ErrorActionPreference = "Stop"
    $taskName = $taskName.SubString(0,1).ToUpper()+$taskName.SubString(1)
    $taskName = $($taskName -csplit '(?<!^)(?=[A-Z])' -join ' ')
    $taskNameWithBraces = "[ $taskName ]"

    [int] $headingLength = 120
    [int] $leftLength = (($headingLength - $taskNameWithBraces.length) / 2) + $taskNameWithBraces.length 

    write-host ""
    write-host $taskNameWithBraces.padleft($leftLength, "-").padright($headingLength, "-") -foregroundcolor cyan

    if($poshBAR.IsRunningOnTeamCity) {
        Write-Host "##teamcity[progressMessage '$taskName']"
    }
}
Set-Alias ftnhost Format-TaskNameToHost