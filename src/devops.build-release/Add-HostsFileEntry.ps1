<#
    .DESCRIPTION
        Adds the specified line to the hosts file if it doesn't already exist.

    .EXAMPLE
        Add-HostsFileEntry "local.example.ca"

    .EXAMPLE
        Add-HostsFileEntry "local.example.ca" "10.1.1.1"

    .EXAMPLE
        Add-HostsFileEntry "local.example.ca" -includeLoopbackFix

    .PARAMETER ipAddress
        The ip address of the machine you want to target.

    .PARAMETER hostName
        The "host name" name you want routed to the target ip address.

    .PARAMETER includeLoopbackFix
        Switch to determine if the Loopback Fix should also be applied (Add-LoopbackFix)

    .SYNOPSIS
        Will add a hosts file entry for the host name specified targeting the specified ip address.

    .NOTES
        Nothing yet...
#>
function Add-HostsFileEntry
{
	param(
        [parameter(Mandatory=$true,position=0)] [string] $hostName,
        [parameter(Mandatory=$false,position=1)] [ValidatePattern("\d{1,3}(\.\d{1,3}){3}")] [string] $ipAddress = "127.0.0.1",
        [parameter(Mandatory=$false,position=2)][switch] $includeLoopbackFix
	)

    $ErrorActionPreference = "Stop"
    Write-Host ($msgs.msg_add_host_entry -f $hostName) -NoNewLine

	$HostsLocation = "$env:windir\System32\drivers\etc\hosts"
	$NewHostEntry = "`t$ipAddress`t$hostName"


	if((gc $HostsLocation) -contains $NewHostEntry)
	{
        Write-Host "`tExists" -f Cyan
	}
	else
	{
        Write-Host "`tDone"
		Add-Content -Path $HostsLocation -Value $NewHostEntry
	}

	# Validate entry
    Write-Host ($msgs.msg_validate_host_entry -f $hostName) -NoNewLine
	if((gc $HostsLocation) -contains $NewHostEntry)
	{
        Write-Host "`tPassed" -f Green
	}
	else
	{
        Write-Host "`tFailed" -f Red
	}

    if($includeLoopbackFix.IsPresent){
        Add-LoopbackFix $hostName
    }
}