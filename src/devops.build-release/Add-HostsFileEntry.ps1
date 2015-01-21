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
    Format-TaskNameToHost "Add Host File Entry"

	Write-Host "Adding hosts entry for custom host header..."

	$HostsLocation = "$env:windir\System32\drivers\etc\hosts"
	$NewHostEntry = "`t$ipAddress`t$hostName"

    $output = @()

	if((gc $HostsLocation) -contains $NewHostEntry)
	{
        $output += new-object PSObject -property @{ Info = "[ $hostName | $ipAddress ]"; Message = "Host file entry already Exists"}
	}
	else
	{
        $output += new-object PSObject -property @{ Info = "[ $hostName | $ipAddress ]"; Message = "Attempting to update host file."}
		Add-Content -Path $HostsLocation -Value $NewHostEntry
	}

	# Validate entry
	if((gc $HostsLocation) -contains $NewHostEntry)
	{
        $output += new-object PSObject -property @{ Info = "[ $hostName | $ipAddress ]"; Message = "TEST PASSED"}
	}
	else
	{
        $output += new-object PSObject -property @{ Info = "[ $hostName | $ipAddress ]"; Message = "TEST FAILED"}
	}

    $output | Format-Table -autoSize -property Info,Message | Out-Default
    
    if($includeLoopbackFix.IsPresent){
        Add-LoopbackFix $hostName
    }
}