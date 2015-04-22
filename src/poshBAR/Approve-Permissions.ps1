<#
    .DESCRIPTION
       Sets permissions to a specified path for a specific trustee (user)

    .SYNOPSIS
        Sets permissions to a specified path for a specific trustee (user)

    .EXAMPLE
        Approve-Permissions 'c:\inetpub\wwwroot' 'Network Service' 'read-execute'
    
    .PARAMETER path
        The path that you are modifying permissions on

    .PARAMETER trustee
        The user who is being granted the specified permission

    .PARAMETER permission
        The permission level
        [full, modify, read-execute, read-only, write-only]

#>
function Approve-Permissions{
    [CmdletBinding()]
	param(
		[Parameter(Mandatory=$true, Position=0)] [string] $path,
        [Parameter(Mandatory=$true, Position=1)] [string] $trustee,
        [Parameter(Mandatory=$true, Position=3)] [ValidateSet('full','modify','read-execute','read-only','write-only')] [string] $permission
	)

    if($permission -eq "full"){
        Write-Warning ($msgs.wrn_full_permission -f $path, $trustee)
    }
    
    switch ($permission){
        'full' {$perm = "(F)"}
        'modify' {$perm = "(M)"}
        'read-execute' {$perm = "(RX)"}
        'read-only' {$perm = "(R)"}
        'write-only' {$perm = "(W)"}
    }
    
    Write-Host ($msgs.msg_grant_permission -f $permission, $path, $trustee) -NoNewLine
    icacls "$path" /grant ($($trustee) + ":(OI)(CI)$perm") | Out-Null
    Write-Host "`tDone" -f Green
}