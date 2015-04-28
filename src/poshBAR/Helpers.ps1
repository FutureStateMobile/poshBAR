
function Get-TestFileName ( [string] $outputDir, [string] $runCommand ){
    $fileName = $runCommand -replace "\.", "-"
    return "$outputDir\$fileName"
}

<#
    .DESCRIPTION
        Asserts that the condition is true
             
    .SYNOPSIS
        Asserts that the condition is true, and if it is not, will throw the specified failure message.

    .EXAMPLE
        Assert-That ($name -ne $null) "Name cannot be null."


    .PARAMETER conditionToCheck
        The condition that you're asserting

    .PARAMETER failureMessage
        The message to throw if the condition is not met.

#>
function Assert-That
{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)]$conditionToCheck,
        [Parameter(Position=1,Mandatory=1)]$failureMessage
    )
    if (!$conditionToCheck) {
        throw ("Assert: " + $failureMessage)
    }
}
Set-Alias Assert Assert-That

function Add-ToolToPath ($toolName){

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

    throw "Could not find $toolName, please specify it's path to `$poshbar.Paths[`"$toolNameVariable`"]"
}