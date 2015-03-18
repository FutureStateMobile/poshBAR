function Invoke-WebConfigTransform
{
    param(
        [Parameter(Position=0, Mandatory=$true)] [string] $pathToWebConfig,
        [Parameter(Position=1, Mandatory=$true)] [string] $env
    )

    $xml = join-path $pathToWebConfig "web.config"
    $xdt = join-path $pathToWebConfig "web.$env.config"

    if (!(Test-Path -path $xml -PathType Leaf)) {
        Write-Host "There is no web.config to transform at $pathToWebConfig."
        return
    }

    if (!(Test-Path -path $xml -PathType Leaf)) {
        Write-Host "There is no web.$env.config transform file at $pathToWebConfig."
        return
    }

    Write-Host "Transforming $xml with $xdt"
    $here  = Split-Path $script:MyInvocation.MyCommand.Path
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