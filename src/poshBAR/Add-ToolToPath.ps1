<#
    .SYNOPSIS
        Adds a path to the $env:PATH so that the tool is accessable throughout the build/release cycle

    .DESCRIPTION
        Takes the name of a tool and tries to guess it's location. If it can't find it, it'll require the user to add the variable `$poshBAR.Paths['toolNamePath']`

    .PARAMETER toolName
        The name of the tool to add

    .EXAMPLE
        Add-ToolToPath 'dotcover'

    .EXAMPLE
        Add-ToolToPath 'nunit'

    .EXAMPLE
        Add-ToolToPath 'xunit'
#>
function Add-ToolToPath {
    [CmdletBinding()]
    param([parameter][string] $toolName)

    if($env:Path -like "*$toolName*" ) { return }

    $toolNameVariable = $toolName + 'Path'
    if($poshbar.Paths["$toolNameVariable"] -and (Test-Path $poshbar.Paths["$toolNameVariable"])){
        $env:Path += ";$(Resolve-Path $poshbar.Paths[$toolNameVariable])"
        return
    }

    $here = Split-Path $script:MyInvocation.MyCommand.Path
    $packagePath = "$here\..\..\..\$toolName.*\tools"
    if(Test-Path $packagePath) {
        $env:Path += ";$(Resolve-Path $packagePath)"
        return
    }

    $nuspecToolsPath = "$here\..\..\tools"
    if(Test-Path $nuspecToolsPath) {
        $path = (Resolve-Path $nuspecToolsPath).Path
        $exists = Get-ChildItem $path | ? {$_ -like "*$toolName*"}
        if($exists) {
            $env:Path += ";$(Resolve-Path $nuspecToolsPath)"
            return
        }
    }

    throw msgs.error_cannot_find_tool -f $toolName, $toolNameVariable
}