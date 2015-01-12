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
        Nothing yet...
#>
function Update-JsonConfigValues{
    param( 
        [parameter(Mandatory=$true,position=0)] [string] $configFile,
        [parameter(Mandatory=$true,position=1)] [string] $node,
        [parameter(Mandatory=$true,position=2)] [AllowEmptyString()] [string] $value
    )
    $ErrorActionPreference = "Stop"

    $config = Get-Content -Path $configFile -Raw | ConvertFrom-Json
    Invoke-Expression "`$config.$node = `$value"

    Set-Content $configFile $($config | ConvertTo-Json)
}