<#
    .SYNOPSIS
        Expands any Nuget package and places the contents in the specified folder.

    .DESCRIPTION
        Extracts a Nuget Package file and puts the contents in the specified location.

    .EXAMPLE
        Expand-NugetPackage "something.pkg" "C:\temp\zipcontents"

    .PARAMETER nugetPackageName
        The full path to the Nuget package.

    .PARAMETER destinationFolder
         The full path to the desired destination.
#>
function Expand-NugetPackage
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string] [alias('pkgName')] $nugetPackageName,
        [parameter(Mandatory=$true,position=1)] [string] [alias('dest')] $destinationFolder
    )
    $ErrorActionPreference = "Stop"

    Format-TaskNameToHost "Expanding Nuget Package"
    Write-Host "Expanding: $nugetPackageName" -NoNewLine

    $pwd = Get-ModuleDirectory

    Expand-ZipFile $nugetPackageName $destinationFolder

    Remove-Item "$destinationFolder\``[Content_Types``].xml" -ea SilentlyContinue
    Remove-Item "$destinationFolder\*.nuspec" -ea SilentlyContinue
    Remove-Item "$destinationFolder\_rels" -recurse -ea SilentlyContinue
    Remove-Item "$destinationFolder\package" -recurse -ea SilentlyContinue

    Get-ChildItem $destinationFolder -recurse | where {$_.Mode -match "d"} | move-item -ea SilentlyContinue -dest { ( Invoke-UrlDecode $_.FullName ) }
    Get-ChildItem $destinationFolder -Recurse | Where-Object { !$_.PSIsContainer } |  Rename-Item -ea SilentlyContinue -NewName { Invoke-UrlDecode $_.Name }
    Write-Host "`tDone" -f Green
}

function Get-ModuleDirectory {
    return Split-Path $script:MyInvocation.MyCommand.Path
}
