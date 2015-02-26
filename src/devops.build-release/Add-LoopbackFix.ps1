<#
    .DESCRIPTION
        Adds a registry entry that overrides the default windows behaviour regarding allowing a different "C" name to point back to 127.0.0.1

    .EXAMPLE
        Add-LoopbackFix "local.tcpl.ca"

    .PARAMETER siteHostName
        The hostname that you want to loop back to the local host.

    .SYNOPSIS
        Will apply a registry entry fix for issue KB896861.  Uses the more conservative and recommend fix found in method 1.

    .NOTES
        Applies method 1 workaround fix for "You receive error 401.1 when you browse a Web site that uses Integrated Authentication and is hosted on 
        IIS 5.1 or a later version"

    .LINK
        http://support.microsoft.com/kb/896861
#>
function Add-LoopbackFix
{
    param(
        [parameter(Mandatory=$true,position=0)] [string] $siteHostName
    )

    $ErrorActionPreference = "Stop"

    Write-Host ($msgs.msg_add_loopback_fix -f $siteHostName) -NoNewLine

    $str = Get-ItemProperty -Name "BackConnectionHostNames" -path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0' -erroraction silentlycontinue
  
    if ($str) { 
        if($($str.BackConnectionHostNames) -like "*$siteHostName*")
        {
            Write-Host "`tAlready in place" -f Cyan
        } else{
            $str.BackConnectionHostNames += "`n$siteHostName"
            Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" -Name "BackConnectionHostNames" -Value $str.BackConnectionHostNames 
            Write-Host "`tDone" -f Green
        }
    } else {
        New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" -Name "BackConnectionHostNames" -Value $siteHostName -PropertyType "MultiString" 
        Write-Host "`tDone" -f Green
    }

    Write-Host ($msgs.msg_loopback_note -f $siteHostName) -f DarkGray
}
