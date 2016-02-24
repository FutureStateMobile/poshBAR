<#
    .SYNOPSIS
        Attempts to locate the path for the specified tool, and adds it to the $env:PATH so that the tool is accessable throughout the build/release cycle

    .DESCRIPTION
        Takes the name of a tool and tries to guess it's location. If it can't find it, it'll require the user to add the variable `$poshBAR.Paths['toolNamePath']`.
        If the tool cannot be located and added to the $env:PATH, an exception will be thrown.

    .PARAMETER toolName
        The name of the tool to add

    .EXAMPLE
        Find-ToolPath 'dotcover.exe'

    .EXAMPLE
        Find-ToolPath 'sometool.exe'
#>
function Find-ToolPath {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string] [alias('name')] $toolName
    )
    
    $here = Split-Path $script:MyInvocation.MyCommand.Path
    Write-Verbose "Current Directory is '$here'"
    
    # try to find it in the existing path.
    $toolNameWithoutExt = $toolName.Split('.')[0]
    Write-Verbose "Looking for '$toolNameWithoutExt' on the `$env:PATH"
    if($env:PATH -like "*$toolNameWithoutExt*" ) { 
        $paths = $env:PATH.Split(';',[StringSplitOptions]::RemoveEmptyEntries)
        $foundPath = $paths | ? { $_ -like "*$toolNameWithoutExt*" } | select -First 1
        Write-Verbose "Found '$toolName' in '$foundPath'"
        return $foundPath
    }

    # try to find it in the current directory
    Write-Verbose "Looking for '$toolName' in '$here'"
    if(Test-Path $here) {
        $foundPath = try { (Get-ChildItem $here -recurse | ? {$_ -like "*$toolName*"})[0].DirectoryName } catch { $null }
        if($foundPath) {
            Write-Verbose "Found '$toolName' in '$foundPath'"
            $env:PATH += ";$foundPath;"
            return $foundPath
        }
    }

    # try to find it in the packages path
    $packagePath = "$here\..\..\..\..\packages"
    Write-Verbose "Looking for '$toolName' in '$packagePath'"
    if(Test-Path $packagePath) {
        $foundPath = try { (Get-ChildItem $packagePath -recurse | ? {$_ -like "*$toolName*"})[0].DirectoryName } catch { $null }
        if($foundPath) {
            Write-Verbose "Found '$toolName' in '$foundPath'"
            $env:PATH += ";$foundPath;"
            return $foundPath
        }
    }

    # try to find it in the tools directory (usually in a nupkg file)
    $nuspecToolsPath = "$here\..\..\tools"
    Write-Verbose "Looking for '$toolName' in '$nuspecToolsPath'"
    if(Test-Path $nuspecToolsPath) {
        $foundPath = try { (Get-ChildItem $nuspecToolsPath -recurse | ? {$_ -like "*$toolName*"})[0].DirectoryName } catch { $null }
        if($foundPath) {
            Write-Verbose "Found '$toolName' in '$foundPath'"
            $env:PATH += ";$foundPath;"
            return $foundPath
        }
    }

    # try to find it in the packages tools based on the tests working directory
    $altPathForTests = "$here\..\..\..\tools"
    Write-Verbose "Looking for '$toolName' in '$altPathForTests'"
    if(Test-Path $altPathForTests) {
        $foundPath = try { (Get-ChildItem $altPathForTests -recurse | ? {$_ -like "*$toolName*"})[0].DirectoryName } catch { $null }
        if($foundPath) {
            Write-Verbose "Found '$toolName' in '$foundPath'"
            $env:PATH += ";$foundPath;"
            return $foundPath
        }
    }

    throw ($msgs.error_cannot_find_tool -f $toolName)
}
