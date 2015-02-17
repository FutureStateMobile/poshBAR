<#
    .DESCRIPTION
        Converts a powershell script to UTF8 and then signs it against a certificate

    .EXAMPLE
        Set-PowershellScriptSigning @("C:\temp\someposh.ps1", "C:\otherposh.ps1")

    .EXAMPLE
        Set-PowershellScriptSigning @("C:\temp\someposh.ps1", "C:\otherposh.ps1") "CurrentUser\My"

    .PARAMETER scripts
        An array of powershell scripts to be signed

    .PARAMETER certPath
        Path to the certificate directory

    .SYNOPSIS
        Converts a powershell script to UTF8 and then signs it against a certificate

    .NOTES
        Nothing yet...
#>
function Set-PowershellScriptSigning{

    param(
        [parameter(Mandatory=$true,position=0)] [string[]] $scripts,
        [parameter(Mandatory=$false,position=1)] [string] $certPath = "LocalMachine\My"
    )

    $cert = @(Get-ChildItem cert:$certPath -codesign)[0]

    $scripts | % {
        # just make sure the file encoding is UTF8
        [System.Io.File]::ReadAllText($_) | Out-File -FilePath $_ utf8 -force

        # sign the file with our POSH cert.
        Set-AuthenticodeSignature $_ $cert
    }
}

Set-Alias sign Set-PowershellScriptSigning