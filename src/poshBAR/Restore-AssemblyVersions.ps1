<#
    .DESCRIPTION
        Restores the Assembly versions
    .EXAMPLE
        Restore-AssemblyVersions $rootDir\src

    .PARAMETER ProjectRoot
        Where to begin recursion when searching for the AssemblyInfo.cs files to be updated.

    .PARAMETER GitExe 
        Location of the Git executable (optional)
        
    .SYNOPSIS
        Restores the AssemblyVersion.cs files using git checkout.  Typically used in a build, if the files have been updated.
#> 

function Restore-AssemblyVersions {
    [CmdletBinding()]
    param( 
        [parameter(Mandatory=$true, Position=0)][string] $projectRoot = "..\",
        [parameter(Mandatory=$false, Position=1)][string] $GitExe
    )

    if (!$GitExe){
        $GitExe = "git"
    }
    Get-ChildItem -File -Path $projectRoot -Include AssemblyInfo.cs -recurse -Name | 
        ForEach-Object { Execute-GitCheckout $(Resolve-Path "$projectRoot\$_") $GitExe}
}

# region Private
function Execute-GitCheckout {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true, Position=0)][string] $Path,
        [parameter(Mandatory=$true, Position=1)][string] $GitExe
    )
    Exec { Invoke-Expression "$GitExe checkout $Path"} ($msgs.error_failed_execution -f "git checkout")
}
# end region
