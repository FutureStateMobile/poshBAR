if(Test-Path Function:\Get-PfxCertificate){
    Copy Function:\Get-PfxCertificate Function:\Get-PfxCertificateOriginal
}

<#
    .SYNOPSIS
        Extends the default Get-PfxCertificate function to add 'password' support.

    .DESCRIPTION
        Since the default Get-PfxCertificate function only prompts for a password, it's difficult to automate the process. This function adds password support to the default function

    .PARAMETER filePath
        A relative path to the pfx file

    .PARAMETER literalPath
        The literal path to the pfx file

    .PARAMETER password
        The password associated with the pfx file

    .PARAMETER x509KeyStorageFlag
        Defines where and how to import the private key of an X.509 certificate.
        Valid flags are: [DefaultKeySet, Exportable, MachineKeySet, PersistKeySet, UserKeySet, UserProtected]

    .EXAMPLE
        Get-PfxCertificate "$here\myCert.pfx" 'P@$$W0rd'

    .EXAMPLE
        Get-PfxCertificate -literalPath "C:\certs\myCert.pfx" 'P@$$W0rd'

    .EXAMPLE
        Get-PfxCertificate ".\myCert.pfx" 'P@$$W0rd' 'UserKeySet'

    .EXAMPLE
        Get-PfxCertificate "$here\myCert.pfx"
        This simply calls the original method

    .EXAMPLE
        Get-PfxCertificate -literalPath "C:\certs\myCert.pfx"
        This simply calls the original method with a literal path

    .NOTES
        the -x509KeyStorageFlag flag is only used if you are also passing in a -password

#>
function Get-PfxCertificate {
    [CmdletBinding(DefaultParameterSetName='ByPath')]
    param(
        [Parameter(Position=0, Mandatory=$true, ParameterSetName='ByPath')] [string[]] $filePath,
        [Parameter(Mandatory=$true, ParameterSetName='ByLiteralPath')] [string[]] $literalPath,
        
        [Parameter(Position=1, ParameterSetName='ByPath')] 
        [Parameter(Position=1, ParameterSetName='ByLiteralPath')] [string] $password,

        [Parameter(Position=2, ParameterSetName='ByPath')]
        [Parameter(Position=2, ParameterSetName='ByLiteralPath')] [string] 
        [ValidateSet('DefaultKeySet','Exportable','MachineKeySet','PersistKeySet','UserKeySet','UserProtected')] $x509KeyStorageFlag = 'DefaultKeySet'
    )

    if($PsCmdlet.ParameterSetName -eq 'ByPath'){
        $literalPath = Resolve-Path $filePath 
    }

    if(!$password){
        $cert = Get-PfxCertificateOriginal -literalPath $literalPath
    } else {
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $cert.Import($pfxFilePath, $password, $X509KeyStorageFlag)
    }

    return $cert
}