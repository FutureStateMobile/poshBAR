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

    Write-Host "Transforming '$path' with '$xdtPath'."
    if (!$destination) {
        $destination = $path
    }

    $modulePath = Split-Path $PSCommandPath -Parent 
    $xmlTransformPath = Find-InParentPath $modulePath "XmlTransform*"
    $transformAssembly = (Get-ChildItem -Path $xmlTransformPath -Recurse -Filter "Microsoft.Web.XmlTransform.dll").FullName
    Add-Type -Path $transformAssembly
    try
    {
        $document = New-Object Microsoft.Web.XmlTransform.XmlTransformableDocument
        $document.PreserveWhitespace = $true
        $document.Load($path)

        $xmlTransform = New-Object Microsoft.Web.XmlTransform.XmlTransformation $xdtPath

        $success = $xmlTransform.Apply($document)

        if($success)
        {
            $document.Save($destination)
        }
    }
    finally
    {
        if( $xmlTransform )
        {	
            $xmlTransform.Dispose()
        }
        if( $document )
        {
            $document.Dispose()
        }
    }
}

set-alias xdt Invoke-XmlDocumentTransform
set-alias XmlDocumentTransform Invoke-XmlDocumentTransform
