function Approve-Permissions{
	param(
		[Parameter(Mandatory=$true, Position=0)] [string] $path,
        [Parameter(Mandatory=$true, Position=1)] [string] $trustee,
        [Parameter(Mandatory=$true, Position=3)] [ValidateSet('full','modify','read-execute','read-only','write-only')] [string] $permission
	)

    if($permission -eq "full"){
        Write-Warning "You have applied FULL permission to $path for $trustee. THIS IS DANGEROUS!"
    }
    
    switch ($permission){
        'full' {$perm = "(F)"}
        'modify' {$perm = "(M)"}
        'read-execute' {$perm = "(RX)"}
        'read-only' {$perm = "(R)"}
        'write-only' {$perm = "(W)"}
    }
    
    Write-Host "Granting $permission permissions to $path for user $trustee" -NoNewLine
    icacls "$path" /grant ($($trustee) + ":(OI)(CI)$perm") | Out-Null
    Write-Host "`tDone" -f Green
}