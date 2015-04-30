<#
    .SYNOPSIS
        Attempts to locate the path for the specified tool, and adds it to the $env:PATH so that the tool is accessable throughout the build/release cycle

    .DESCRIPTION
        Takes the name of a tool and tries to guess it's location. If it can't find it, it'll require the user to add the variable `$poshBAR.Paths['toolNamePath']`

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
        [parameter(Mandatory=$true,position=0)] [string] $toolName
    )

    $here = Resolve-Path './'
    $upOne = Resolve-Path './../'

    if($env:Path -like "*$toolName*" ) { return }

    # try to find it in the packages path
    $packagePath = "$upOne\packages\$toolName.*\tools"
    if(Test-Path $packagePath) {
        $private:Path = (Resolve-Path $packagePath).Path
        $env:Path += ";$private:Path"
        return
    }

    # try to find it in the tools directory (usually in a nupkg file)
    $nuspecToolsPath = "$here\tools"
    if(Test-Path $nuspecToolsPath) {
        $private:Path = (Resolve-Path $nuspecToolsPath).Path
        $exists = Get-ChildItem $path | ? {$_ -like "*$toolName*"}
        if($exists) {
            $env:Path += ";$($private:Path)"
            return
        }
    }

    # Heavy Weight, search entire directly tree from '$upOne' to search
    $itm = Get-ChildItem -Path $loc -Recurse | ? {$_ -like "*$toolName*" -and $_.Extension -eq '.exe'} | select -First 1
    if($itm){
        $env:Path += ";$($itm.DirectoryName)"
        return
    }

    throw ($msgs.error_cannot_find_tool -f $toolName)
}