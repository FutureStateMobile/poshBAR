<#
    .DESCRIPTION
        Enforces a specific Dot Net Framework 
         

    .EXAMPLE
        Assert-DotNet "4.6.1"

    .PARAMETER requiredVersion
        The version of dot net framework

    .NOTES
        Currently only supports identification of versions 4.6.1 or less
#>
function Assert-DotNetVersion{
    [CmdletBinding()]
    param(
      [Parameter(Mandatory=$true, position=0)][ValidateSet('4.5', '4.5.1', '4.5.2', '4.6', '4.6.1')] $requiredVersion
    )

    $dotNetVersions = @{
        378389 = "4.5"
        378675 = "4.5.1"
        378758 = "4.5.1"
        379893 = "4.5.2"
        393295 = "4.6"
        393297 = "4.6"
        394254 = "4.6.1"
        394271 = "4.6.1" 
    }

    $searchFor = $dotNetVersions.Keys | ? { $dotNetVersions[$_] -eq $requiredVersion} | sort | select -first 1

    $currentDotNet = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name "Release"
   
    if ($currentDotNet.Release -lt $searchFor){

      $msg = "Current Dot Net Framework version is {0} but {1} is required" `
            -f $dotNetVersions[$currentDotNet.Release],$requiredVersion
      Write-Host $msg -f Red
      throw "Dot Net $requiredVersion is required"
    }
}

