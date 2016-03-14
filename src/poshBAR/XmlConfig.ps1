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
                    Write-Host ($msgs.msg_updated_to -f "$xpath->$attributeName", $value)
                } else {
                    #write message
                    Write-Host ($msgs.msg_wasnt_found -f $attributeName)
                }
            } else {
                if ($node.NodeType -eq "Element") {
                    $node.InnerXml = $value
                }
                else {
                    $node.Value = $value
                }
                #write message
                Write-Host ($msgs.msg_updated_to -f "$xpath", $value)
            }
        }
        else {
            #write message
            Write-Host ($msgs.msg_wasnt_found -f $xpath)
        }
    }

    if($private:count -eq 0) {
        #write message
        Write-Host ($msgs.msg_wasnt_found -f $xpath)
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
#>
function Add-XmlConfigValue
{
    [CmdletBinding()]
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
        [Parameter(Mandatory=$true, Position=1)] 
        [string] $inputPathAndFile,
        
        [Parameter(Mandatory=$true, Position=2)]
        [string] $transformPathAndFile,
        
        [Parameter(Mandatory=$false, Position=3)] 
        [string] $outputPathAndFile,

        [Parameter(Mandatory=$false, Position=4)] 
        [string] $xmlTransformExe
    )    
    Write-Host "Transforming '$inputPathAndFile' with '$transformPathAndFile'."
    $outputPathAndFile = if($outputPathAndFile) {$outputPathAndFile} else {$inputPathAndFile}

    if (!$xmlTransformExe){
        Find-ToolPath xmltransform.exe
        Exec { xmltransform.exe -i $inputPathAndFile -t $transformPathAndFile -o $outputPathAndFile } "Failed to invoke xmltransform"
    } else {
        $command = '$xmlTransformExe -i $inputPathAndFile -t $transformPathAndFile -o $outputPathAndFile'
        Invoke-Expression "& $command"
    }
}

set-alias xdt Invoke-XmlDocumentTransform
set-alias XmlDocumentTransform Invoke-XmlDocumentTransform
