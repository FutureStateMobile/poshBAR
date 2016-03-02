<#

    .SYNOPSIS
        Creates a new directory. If a directory exist, no change is made
    
    .DESCRIPTION
        The `New-Directory` function creates a new directory if it doesn't exist.
    
    .PARAMETER path
       Path to create 

    .EXAMPLE
        New-Directory c:\temp\foo
    
#>
function New-Directory
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, position=0)] [string] $Path
    )

    if( -not (Test-Path -Path $Path -PathType Container) )
    {
        New-Item -Path $Path -ItemType 'Directory' | Out-String | Write-Verbose
    }
}
