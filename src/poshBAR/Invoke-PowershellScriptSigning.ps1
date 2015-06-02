<#
    .DESCRIPTION
        Converts a powershell script to UTF8 and then signs it against a certificate

    .EXAMPLE
        Invoke-PowershellScriptSigning @("C:\temp\someposh.ps1", "C:\otherposh.ps1")

    .EXAMPLE
        Invoke-PowershellScriptSigning @("C:\temp\someposh.ps1", "C:\otherposh.ps1") "CurrentUser\My"

    .EXAMPLE
        Invoke-PowershellScriptSigning @("C:\temp\someposh.ps1", "C:\otherposh.ps1") (Resolve-Path 'C:\path\to\my.pfx')

    .PARAMETER scripts
        An array of powershell scripts to be signed

    .PARAMETER certStorePath
        Path to the certificate directory

    .PARAMETER pfxFilePath
        File path to a .pfx certificate.

    .SYNOPSIS
        Converts a powershell script to UTF8 and then signs it against a certificate

    .NOTES
        If using -pfxFilePath, be sure to use Resolve-Path and pass in the PathInfo object.
#>
function Invoke-PowershellScriptSigning{
    [CmdletBinding(DefaultParameterSetName='store')]
    param(
        [parameter(Mandatory=$true, position=0, ParameterSetName='store')] [string[]] 
        [parameter(Mandatory=$true, position=0, ParameterSetName='path')] [string[]] $scripts,

        [parameter(Mandatory=$false, position=1, ParameterSetName='store')] [string] $certStorePath = 'LocalMachine\My',
        [parameter(Mandatory=$false, position=1, ParameterSetName='path')] [Management.Automation.PathInfo] $pfxFilePath,

        [parameter(Mandatory=$false, position=2, ParameterSetName='path')] [string] $password
    )
    switch($PsCmdlet.ParameterSetName){
        'store' {
            $cert = @(Get-ChildItem cert:$certStorePath -codesign)[0] # grabs the first code signing cert out of the cert store.
            break 
        }
        'path' {
           $cert = Get-PfxCertificate $pfxFilePath $password # note: poshBAR has overridden this function to enable the password field.
            break
        }
    }
    $scripts | ? {$_.EndsWith(".ps1") -or $_.EndsWith(".psm1")} | % {
        # just make sure the file encoding is UTF8
        [System.Io.File]::ReadAllText($_) | Out-File -FilePath $_ utf8 -force

        # sign the file with our POSH cert.
        Set-AuthenticodeSignature -FilePath $_ -certificate $cert
    }
}

Set-Alias signscripts Invoke-PowershellScriptSigning