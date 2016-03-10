<#
    .SYNOPSIS
    Gets a value from a given Nuspec file, such as version

    .DESCRIPTION
    Gets a value from a given Nuspec file

    .EXAMPLE
        Get-MetadataValueFromNuspec  "version"
        This returns the value of version from the nuspect file

    .EXAMPLE
        Get-MetadataValueFromNuspec  "id"
        This returns the value of id from the nuspect file
    
    .PARAMETER nuspecPath
    Location of the nuspec file
#>
function Get-ValueFromNuspec
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)][ValidateNotNullOrEmpty()] [string] $nuspecPath,
        [parameter(Mandatory=$true,position=1)][ValidateNotNullOrEmpty()] [string] $metadataNodeName
    )
    if (!(Test-Path $nuspecPath)){
        throw ($msgs.msg_wasnt_found -f $nuspecPath)
    } 
    $nuspec = [xml](Get-Content -Path $nuspecPath)
    return $nuspec.package.metadata.$metadataNodeName
}
