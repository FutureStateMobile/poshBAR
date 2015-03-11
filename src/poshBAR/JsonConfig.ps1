<#
    .DESCRIPTION
        Updates a JSON element with a new value

    .EXAMPLE
        Update-JsonConfigValues "c:\path\to.json" "user[0].address.streetAddress" "21 Jump St."

    .EXAMPLE
        Update-JsonConfigValues "c:\path\to.json" "website.siteHost" "http://www.example.com"

    .PARAMETER configFile
        Path to JSON config file

    .PARAMETER node
         Path to property being updated (dotted notation)

    .PARAMETER value
         New value for the updated node.

    .SYNOPSIS
        Updates a JSON element with a new value

    .NOTES
        If Powershell version => 3 is available, the final text will retain formatting. If only Powershell
        version 2 is available, all formatting will be lost, and the output will be a single line.
#>
function Update-JsonConfigValues{
    [CmdletBinding()]
    param( 
        [parameter(Mandatory=$true,position=0)] [string] $configFile,
        [parameter(Mandatory=$true,position=1)] [string] $node,
        [parameter(Mandatory=$true,position=2)] [AllowEmptyString()] [string] $value
    )
    $ErrorActionPreference = "Stop"
    
    $msgs.msg_changing_to -f $node, $value

    if(Get-Command ConvertFrom-Json -ea SilentlyContinue){
    #Powershell => 3 support

        Assert-PSVersion 3 

        $config = Get-Content -Path $configFile -Raw | ConvertFrom-Json
        Invoke-Expression "`$config.$node = `$value"

        Set-Content $configFile $($config | ConvertTo-Json)
    } else {
    #Powershell 2 support

        [System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions") | out-null
        $ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer

        $json = Get-Content -Path $configFile  | Out-String
        $config = $ser.DeserializeObject($json) 

        Invoke-Expression "`$config.$node = `$value"

        $json = $ser.Serialize($config)
        Set-Content $configFile $json
    }
}