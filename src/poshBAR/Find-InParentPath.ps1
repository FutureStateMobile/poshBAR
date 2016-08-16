<#
    .SYNOPSIS
    Navigates up a given path to find a matching directory 
    
    .DESCRIPTION
    Traverses up the directory hierarchy to find the matching filter 

    .EXAMPLE
    Find-InParentPath C:\build\modules\poshBar XmlTransform*
    Attempts to find the XmlTransform* path in the parents of C:\build\modules\poshBAR
    
    .PARAMETER path
    Initial path to navigate up the directory hierarchy

    .PARAMETER filter
    The name of the directory to match on.  Accepts wildcards.
#>
function Find-InParentPath
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)][ValidateNotNullOrEmpty()] [string] $path,
        [parameter(Mandatory=$true,position=1)][ValidateNotNullOrEmpty()] [string] $filter
    )

    $parent = $path
    while (($parent = Split-Path $parent -Parent)){

        $pathToFind = "$parent\$filter"
        if (Test-Path -Path $pathToFind){
            Write-Verbose "Found $filter in $pathToFind"
            return (Get-ChildItem -Path $pathToFind).FullName
        } 
    }

    throw ($msgs.msg_wasnt_found -f $filter)
}
