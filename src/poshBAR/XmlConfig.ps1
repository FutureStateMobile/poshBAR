<#
    .DESCRIPTION
        Will parse an XML config file and replace the values at a xpath expression with the value passed in.

    .EXAMPLE
        Update-ConfigValues "C:\temp\somefile.config" "//SomeNode/AnotherNode" "Some New Value"

    .PARAMETER configFile
        A path to a file that is XML based

    .PARAMETER xpath
        Any valid XPath exression, wether result in 1 or many matches, wether a Element or and Attribute.

    .PARAMETER value
        Any valid XML value that you wish to set.

    .SYNOPSIS
        Updates a XML file with the value specified at the XPath expression specified..

    .NOTES
        Nothing yet...
#>
function Update-XmlConfigValues
{
    [CmdletBinding()]
    param( 
        [parameter(Mandatory=$true,position=0)] [string] $configFile,
        [parameter(Mandatory=$true,position=1)] [string] $xpath,
        [parameter(Mandatory=$true,position=2)] [AllowEmptyString()] [string] $value,
        [parameter(Mandatory=$false,position=3)] [string] $attributeName
    )

    $ErrorActionPreference = "Stop"

    $doc = New-Object System.Xml.XmlDocument;
    $doc.Load($configFile)

    $nodes = $doc.SelectNodes($xpath)

    $private:count = 0
 
    foreach ($node in $nodes) {
        if ($node -ne $null) {
            $private:count++

            if ($attributeName) {
                if ($node.HasAttribute($attributeName)) {
                    $node.SetAttribute($attributeName, $value)
                    #write message
                    $msgs.msg_updated_to -f "$xpath->$attributeName", $value
                } else {
                    #write message
                    $msgs.msg_wasnt_found -f $attributeName
                }
            } else {
                if ($node.NodeType -eq "Element") {
                    $node.InnerXml = $value
                }
                else {
                    $node.Value = $value
                }
                #write message
                $msgs.msg_updated_to -f "$xpath", $value
            }
        }
        else {
            #write message
            $msgs.msg_wasnt_found -f $xpath
        }
    }

    if($private:count -eq 0) {
        #write message
        $msgs.msg_wasnt_found -f $xpath
    }

    $doc.Save($configFile)
}



<#
    .DESCRIPTION
        Will parse an XML config file and add a xml node at a xpath expression.

    .EXAMPLE
        Add-ConfigValues "C:\temp\somefile.config" "//SomeNode/AnotherNode" "SomeNewNode" @{"key0"="value0";"key1"="value1"}

    .PARAMETER configFile
        A path to a file that is XML based

    .PARAMETER xpath
        Any valid XPath exression, whether result in 1 or many matches, must be an Element.

    .PARAMETER newnode
        Any valid XML node name that you wish to add.

    .PARAMETER attributes
        Hashtable of attributes for the new node being created

    .SYNOPSIS
        Updates a XML file with the value specified at the XPath expression specified..

    .NOTES
        Nothing yet...
#>
function Add-XmlConfigValue
{
    param( 
        [parameter(Mandatory=$true,position=0)] [string] $configFile,
        [parameter(Mandatory=$true,position=1)] [string] $xpath,
        [parameter(Mandatory=$true,position=2)] [string] $newnode,
        [parameter(Mandatory=$false,position=3)] [hashtable] $attributes
    )

    $ErrorActionPreference = "Stop"
    
    $doc = New-Object System.Xml.XmlDocument;
    $doc.Load($configFile)

    $nodes = $doc.SelectNodes($xpath)

    foreach ($node in $nodes) {
        if ($node -ne $null) {

            $nodeChild = $doc.CreateElement($newnode)
            if ($attributes)
            {
                foreach($attributekey in $attributes.Keys)
                {
                    $nodeChild.SetAttribute($attributekey, $attributes[$attributekey])
                }
            }

            $node.AppendChild($nodeChild) | Out-Null
        
            Write-Host "Add '$newnode' node into '$xpath' node"
        }
        else {
            Write-Host "$xpath wasn't found"
        }
    }

    $doc.Save($configFile)

}

<#
    .DESCRIPTION
        Will transform one XML doc with another using the standard xdt transform

#>
function Invoke-XmlDocumentTransform
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0, ParameterSetName='path')] 
        [Parameter(Mandatory=$true, Position=0, ParameterSetName='doc')] 
        [string] $environment,

        [Parameter(Mandatory=$true, Position=1, ParameterSetName='path')] 
        [string] $xmlFilePathAndName,

        [Parameter(Mandatory=$true, Position=1, ParameterSetName='doc')] 
        [Microsoft.Web.XmlTransform.XmlTransformableDocument] $xmlTransformableDocument,
        
        [Parameter(Mandatory=$false, Position=2, ParameterSetName='path')]
        [Parameter(Mandatory=$true, Position=2, ParameterSetName='doc')]
        [string] $xmlTransformFilePathAndName,
        
        [Parameter(Mandatory=$false, Position=3, ParameterSetName='path')] 
        [Parameter(Mandatory=$false, Position=3, ParameterSetName='doc')] 
        [switch] $preventWrite,
        
        [Parameter(Mandatory=$false, Position=4, ParameterSetName='path')] 
        [Parameter(Mandatory=$false, Position=4, ParameterSetName='doc')] 
        [switch] $writeAsTempFile
    )

    $here  = Split-Path $script:MyInvocation.MyCommand.Path
    Add-Type -LiteralPath "$here\Microsoft.Web.XmlTransform.dll"
    


    if($xmlTransformFilePathAndName){
        $path = [System.IO.Path]::GetDirectoryName($xmlTransformFilePathAndName)
        $xdtExt = [System.IO.Path]::GetExtension($xmlTransformFilePathAndName)
        $xdtFile = [System.IO.Path]::GetFileName($xmlTransformFilePathAndName)
        $xdt = $xmlTransformFilePathAndName
    }

    if($PsCmdlet.ParameterSetName -eq 'path') {
        $xml = $xmlFilePathAndName
        if (!(Test-Path -path $xml -PathType Leaf) -and !($xmlTransformableDocument)) {
            Write-Warning "There is no xml to transform."
            return
        }

        if(!$xmlTransformFilePathAndName){
            $path = [System.IO.Path]::GetDirectoryName($xmlFilePathAndName)
            $xdtName = [System.IO.Path]::GetFileNameWithoutExtension("$xmlFilePathAndName")
            $xdtExt = [System.IO.Path]::GetExtension("$xmlFilePathAndName")

            $xdtFile = "$xdtName.$environment$xdtExt"
            $xdt = join-path $path $xdtFile
        }
        
        if (!(Test-Path -path $xdt -PathType Leaf)) {
            Write-Warning "There is no $xdtFile transform file at $path."
            return
        }

        psUsing ($srcXml = new Microsoft.Web.XmlTransform.XmlTransformableDocument) {
            $srcXml.PreserveWhitespace = $true
            $srcXml.Load($xml)

            psUsing ($transXml = new Microsoft.Web.XmlTransform.XmlTransformation($xdt)) {
                if(!$transXml.Apply($srcXml)){
                    throw "Transformation failed"
                }

                if(!$preventWrite.IsPresent){
                    if($writeAsTempFile.IsPresent){
                        $srcXml.Save("$xml.temp")
                    } else {
                        $srcXml.Save("$xml")
                    }
                }

                return $srcXml
            }

        }
    } else {
        psUsing ($xmlTransformableDocument) {
            psUsing ($transXml = new Microsoft.Web.XmlTransform.XmlTransformation($xdt)) {
                if(!$transXml.Apply($xmlTransformableDocument)){
                    throw "Transformation failed"
                }

                $x = "$path\$environment$xdtExt"
                if(!$preventWrite.IsPresent){
                    if($writeAsTempFile.IsPresent){
                        $xmlTransformableDocument.Save("$x.temp")
                    } else {
                        $xmlTransformableDocument.Save("$x")
                    }
                }

                return $xmlTransformableDocument
            }
        }
    }
}

set-alias xdt Invoke-XmlDocumentTransform