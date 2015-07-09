<#
    .DESCRIPTION
        Properly returns all the environmental settings for the particualr context in which this build is being run.

    .EXAMPLE
        $dbSettings = Get-EnvironmentSettings "ci" "//database"
        $value = $dbSettings.connectionString

    .PARAMETER environment
        The environment which this build is being run, these environments will match the names of the environments xml config files.  
        If a config file is found that matches the computer on which this is executing, it will use that instead.

    .PARAMETER nodeXPath
        A valid XPath expression that matches the set of values you are after.

    .PARAMETER culture
        If provided will look up settings for an environment based on culture information provided.

    .SYNOPSIS
        Will grab a set of values from the proper environment file and returns them as an object which you can reffer to like any other object.
        If there is a matching variable in the OctopusParameters, it will use that variable instead of the one located in the XML.

    .NOTES
        There MUST be a value present in the XML (even if it's empty). In order to override the value from Octopus. 
        If it's not represented in the XML, it will not be represented in the output of this method.
#>
function Get-EnvironmentSettings
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string] [alias('env')] $environment,
        [parameter(Mandatory=$true,position=1)] [string] [alias('xpath')] $nodeXPath = "/",
        [parameter(Mandatory=$false,position=2)] [string] $environmentsPath,
        [parameter(Mandatory=$false,position=3)] [string] $culture
    )

    $ErrorActionPreference = "Stop"

    $computerName = $env:COMPUTERNAME
    $doc = New-Object System.Xml.XmlDocument

    $environmentsPath = if($environmentsPath){
        (Resolve-Path $environmentsPath).Path
    } else {
        ((Get-ChildItem -Attributes Directory -filter 'environments' -recurse)[0]).FullName
    }
    $environmentsDir = if($culture){"$environmentsPath\$culture"} else {$environmentsPath}

    if (Test-Path "$environmentsDir\$($computerName).xml") {
        Write-Host ($msgs.msg_use_machine_environment -f $environment, $computerName) -f Magenta
        Invoke-XmlDocumentTransform "$environmentsDir\$($environment).xml" "$environmentsDir\$($computerName).xml" "$environmentsDir\$($environment).xml.temp"
        $doc.Load("$environmentsDir\$($environment).xml.temp")
        rm "$environmentsDir\$($environment).xml.temp"
    } else {
        $doc.Load("$environmentsDir\$($environment).xml")
    }

    if($OctopusParameters){
        Write-Host ($msgs.msg_octopus_overrides -f $environment) 
        foreach($key in $OctopusParameters.Keys)
        {
            $myXPath = "$nodeXPath/$($key.Replace(".", "/"))"
            try{
                $node = $doc.SelectSingleNode($myXPath)
            
                if($node){
                    Write-Host ($msgs.msg_overriding_to -f $key, $($OctopusParameters["$key"]))
                    $node.InnerText = $($OctopusParameters["$key"])
                }
            } catch { 
                <# sometimes Octopus passes in crappy data #> 
            } finally {
                $node = $null
            }
        }
    }

    return $doc.SelectSingleNode($nodeXPath)
}