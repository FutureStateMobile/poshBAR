function Invoke-XmlDocumentTransform
{
    param(
        [Parameter(Position=0, Mandatory=$true)] [string] $xmlFilePath,
        [Parameter(Position=1, Mandatory=$true)] [string] $xmlFileName,
        [Parameter(Position=2, Mandatory=$true)] [string] $env
    )
    
    $xml = join-path $xmlFilePath $xmlFileName
    if (!(Test-Path -path $xml -PathType Leaf)) {
        Write-Host "There is no web.config to transform at $xmlFilePath."
        return
    }


    $xdtName = [System.IO.Path]::GetFileNameWithoutExtension("$xmlFileName")
    $xdtExt = [System.IO.Path]::GetExtension("$xmlFileName")
    $xdtName = "$xdtName.$env$xdtExt"
    $xdt = join-path $xmlFilePath $xdtName
    if (!(Test-Path -path $xdt -PathType Leaf)) {
        Write-Host "There is no $xdtName transform file at $xmlFilePath."
        return
    }

    Write-Host "Transforming '$xml' with '$xdt'."
    $here  = Split-Path $script:MyInvocation.MyCommand.Path
    Add-Type -LiteralPath "$here\Microsoft.Web.XmlTransform.dll"
    psUsing ($srcXml = new Microsoft.Web.XmlTransform.XmlTransformableDocument) {
        $srcXml.PreserveWhitespace = $true
        $srcXml.Load($xml)

        psUsing ($transXml = new Microsoft.Web.XmlTransform.XmlTransformation($xdt)) {
            if(!$transXml.Apply($srcXml)){
                throw "Transformation failed"
            }

            $srcXml.Save("$xml.texico")
        }
    }


}

set-alias xdt Invoke-XmlDocumentTransform