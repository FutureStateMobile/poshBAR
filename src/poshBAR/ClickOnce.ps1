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

   $params = @(
    "-Sign $manifestPath",
    "-CertFile $pfxPath",
    "-Password ClickOnceExample"
   )

   exec {mage.exe $params }

}



$manifestPath = 'build\ClickOnceExample-Release\Application Files\1.1.0.6125\ClickOnceExample.exe.manifest'
$pfxPath = 'src\Robolize.ClickOnceExample\ClickOnceExample.pfx'
$password = 'for you to pass'

Invoke-SignAppliationManifest $manifestPath $pfxPath $password