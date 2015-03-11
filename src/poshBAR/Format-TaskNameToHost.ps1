<#
    .DESCRIPTION
        Writes the message to the Host formatted to be easy to read

    .EXAMPLE
        Format-WriteHost "Doing Some Task"

    .PARAMETER taskName
        The Name of the task you are executing

    .SYNOPSIS
        This is just a simple helper function to write the current task name to screen in a nice friendly way.

    .NOTES
        Nothing yet...
#>
function Format-TaskNameToHost
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string] $taskName,
        [parameter(Mandatory=$false)]           [switch] $suppressTimer
    )

    $ErrorActionPreference = "Stop"
    $taskName = $taskName.SubString(0,1).ToUpper()+$taskName.SubString(1)
    $taskName = "[ $($taskName -csplit '(?<!^)(?=[A-Z])' -join ' ') ]"

    [int] $headingLength = 120
    [int] $leftLength = (($headingLength - $taskName.length) / 2) + $taskName.length 

    write-host ""
    write-host $taskName.padleft($leftLength, "-").padright($headingLength, "-") -foregroundcolor cyan
}
