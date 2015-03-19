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
    [CmdletBinding(DefaultParameterSetName="default")]
    param(
        [Parameter(Mandatory=$true, ParameterSetName='default', Position=0)] 
        [Parameter(Mandatory=$true, ParameterSetName='Overload1', Position=0)] 
        [System.Management.Automation.PathInfo] $xmlFilePathAndName,

        [Parameter(Mandatory=$true, ParameterSetName='default', Position=1)]
        [Parameter(Mandatory=$true, ParameterSetName='Overload1', Position=2)] 
        [string] $environment,

        [Parameter(Mandatory=$false, ParameterSetName='default', Position=2)]
        [Parameter(Mandatory=$false, ParameterSetName='Overload1', Position=3)] 
        [switch] $preventWrite,

        [Parameter(Mandatory=$false, ParameterSetName='default', Position=3)]
        [Parameter(Mandatory=$false, ParameterSetName='Overload1', Position=4)] 
        [switch] $writeAsTempFile,

        [Parameter(Mandatory=$true, ParameterSetName='Overload1', Position=1)]
        [System.Management.Automation.PathInfo] [alias('xdt')] $xmlTransformFilePathAndName

    )
    
    $xml = $xmlFilePathAndName
    if (!(Test-Path -path $xml -PathType Leaf)) {
        Write-Warning "There is no $xml to transform at $path."
        return
    }


    switch($PsCmdlet.ParameterSetName){
    
        "Overload1" {
            $xdtFile = [System.IO.Path]::GetFileName($xmlTransformFilePathAndName)
            $xdt = $xmlTransformFilePathAndName
            break
        }

        "default" { 
            $path = [System.IO.Path]::GetDirectoryName($xmlFilePathAndName)
            $xdtName = [System.IO.Path]::GetFileNameWithoutExtension("$xmlFilePathAndName")
            $xdtExt = [System.IO.Path]::GetExtension("$xmlFilePathAndName")

            $xdtFile = "$xdtName.$environment$xdtExt"
            $xdt = join-path $path $xdtFile
            break
        }
    }
        
    if (!(Test-Path -path $xdt -PathType Leaf)) {
        Write-Warning "There is no $xdtFile transform file at $path."
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
}


set-alias xdt Invoke-XmlDocumentTransform