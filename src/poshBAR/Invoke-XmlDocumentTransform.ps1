<#
    .DESCRIPTION
        Will transform one XML doc with another using the standard xdt transform

    .EXAMPLE
        Invoke-XmlDocumentTransform C:\somepath\web.config  C:\build\web.prod.config
        This transforms the web.config from the xdt file to write environment specific values.

    .PARAMETER path
        A path to the XML file to transform

    .PARAMETER xdtPath
        A path to the XDT file 

    .PARAMETER destination
        The destination XML file's path (Optional).  If not provided, it will update the same XML file

    .SYNOPSIS
        This will transform one XML doc with another using the standard xdt transform
#>
function Invoke-XmlDocumentTransform
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=1)] 
        [string] $path,
        
        [Parameter(Mandatory=$true, Position=2)]
        [string] $xdtPath,
        
        [Parameter(Mandatory=$false, Position=3)] 
        [string] $destination
    )    

    Write-Verbose "Transforming '$path' with '$xdtPath'."
    if (!$destination) {
        $destination = $path
    }

    $modulePath = Split-Path $PSCommandPath -Parent 
    $xmlTransformFolder = Find-InParentPath $modulePath "XmlTransform*"
    $xmlTransformExe = (Get-ChildItem -Path $xmlTransformFolder -Recurse -File -Filter "XmlTransform.exe").FullName
    if (!$xmlTransformExe -or !(Test-Path $xmlTransformExe)) {
        throw "Could not find XmlTransform executable ($xmlTransformExe) in $xmlTransformFolder"
    } 
    Exec { Invoke-Expression "$xmlTransformExe -i $path -t $xdtPath -o $destination"} ("Could not invoke xmltransform")
}

set-alias xdt Invoke-XmlDocumentTransform
set-alias XmlDocumentTransform Invoke-XmlDocumentTransform
