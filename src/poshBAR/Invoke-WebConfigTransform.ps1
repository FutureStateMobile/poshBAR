function Invoke-WebConfigTransform
{
    param(
        [Parameter(Position=0, Mandatory=$true)] [string] $pathToWebConfig,
        [Parameter(Position=1, Mandatory=$true)] [string] $env
    )

    $xml = "$pathToWebConfig\web.config"
    $xdt = "$pathToWebConfig\web.$env.config"

    if (!$xml -or !(Test-Path -path $xml -PathType Leaf)) {
        Write-Host "There is no web.config to transform at $pathToWebConfig."
    }

    if (!$xml -or !(Test-Path -path $xml -PathType Leaf)) {
        Write-Host "There is no web.$env.config transform file at $pathToWebConfig."
    }

    Write-Host "Transforming $xml with $xdt"
    $here  = resolve-path "."
    Add-Type -LiteralPath "$here\Microsoft.Web.XmlTransform.dll"
    psUsing ($srcXml = new Microsoft.Web.XmlTransform.XmlTransformableDocument) {
        $srcXml.PreserveWhitespace = $true
        $srcXml.Load($xml)

        psUsing ($transXml = new Microsoft.Web.XmlTransform.XmlTransformation($xdt)) {
            if(!$transXml.Apply($srcXml)){
                throw "Transformation failed"
            }

            $srcXml.Save("$xml")
        }
    }
}