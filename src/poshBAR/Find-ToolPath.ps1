<#
    .SYNOPSIS
        Attempts to locate the path for the specified tool, and adds it to the $env:PATH so that the tool is accessable throughout the build/release cycle

    .DESCRIPTION
        Takes the name of a tool and tries to guess it's location. If it can't find it, it'll require the user to add the variable `$poshBAR.Paths['toolNamePath']`.
        If the tool cannot be located and added to the $env:PATH, an exception will be thrown.

    .PARAMETER toolName
        The name of the tool to add

    .EXAMPLE
        Find-ToolPath 'dotcover'

    .EXAMPLE
        Find-ToolPath 'nunit'

    .EXAMPLE
        Find-ToolPath 'xunit'
#>
function Find-ToolPath {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string] [alias('name')] $toolName
    )

    $here = Split-Path $script:MyInvocation.MyCommand.Path
    $upOne = Resolve-Path "$here\.."

    Write-Verbose "Current Directory is '$here'"
    Write-Verbose "Parent Directory is '$upOne'"

    if($env:PATH -like "*$toolName*" ) { return $toolName }

    # try to find it in the packages path
    $packagePath = "$upOne\packages\$toolName.*\tools"
    Write-Verbose "Looking for '$toolName' in '$packagePath'"
    if(Test-Path $packagePath) {
        $foundPath = (Resolve-Path $packagePath).Path
        $env:PATH += ";$foundPath"
        return $foundPath
    }

    # try to find it in the tools directory (usually in a nupkg file)
    $nuspecToolsPath = "$here\tools"
    Write-Verbose "Looking for '$toolName' in '$nuspecToolsPath'"
    if(Test-Path $nuspecToolsPath) {
        $foundPath = (Resolve-Path $nuspecToolsPath).Path
        $exists = Get-ChildItem $path | ? {$_ -like "*$toolName*"}
        if($exists) {
            Write-Verbose "Found '$toolName' in '$foundPath'"
            $env:PATH += ";$foundPath"
            return $foundPath
        }
    }

    # Heavy Weight, search entire directly tree from '$upOne' to search
    $itm = Get-ChildItem -Path $here -Recurse | ? {$_ -like "*$toolName*" -and $_.Extension -eq '.exe'} | select -First 1
    Write-Verbose "Looking for '$toolName' recursively from '$here'"
    if($itm){
        Write-Verbose "Found '$toolName' in '$($itm.DirectoryName)'"
        $foundPath = $($itm.DirectoryName)
        $env:PATH += ";$foundPath"
        return $foundPath
    }


    throw ($msgs.error_cannot_find_tool -f $toolName)
}