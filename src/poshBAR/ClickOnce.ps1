<#
    .SYNOPSIS Signs a Click Once Manifest

    .PARAMETER manifestPath
        Path to your manifest file

    .PARAMETER pfxPath
        Path to your PFX certificate file

    .PARAMETER pfxPassword
        Password associated with the pfx certificate

    .EXAMPLE
        Invoke-SignAppliationManifest $manifestPath $pfxPath $password
#>
function Invoke-SignAppliationManifest {
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true)] [string] $manifestPath,
        [Parameter(Position=1, Mandatory=$true)] [string] $pfxPath,
        [Parameter(Position=2, Mandatory=$true)] [string] $pfxPassword

    )
   $ErrorActionPreference = "Stop"
   Find-ToolPath 'mage'

   exec { mage.exe -sign ""$manifestPath"" -certfile ""$pfxPath"" -password ""$pfxPassword"" }
}