<#

    .SYNOPSIS
        Removes a directory, if it exists. 
    
    .DESCRIPTION
        The `Remove-Directory` function deletes an existing directory. If a directory doesn't exist, it does nothing.
    
    .PARAMETER path
       Path to delete 

    .PARAMETER Recurse 
       Deletes all files and subdirectories 

    .EXAMPLE
        Remove-Directory -Path c:\temp\foo -Recurse
    
#>
function Remove-Directory
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, position=0)] [string] $Path,
        [switch] $Recurse,
        [switch] $Force
    )

    if( (Test-Path -Path $Path -PathType Container) )
    {
        Remove-Item -Path $Path -Recurse:$Recurse -Force:$Force
    }
}
