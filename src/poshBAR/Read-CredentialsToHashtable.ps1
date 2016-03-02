<#
    .SYNOPSIS
    Reads credentials from user and returns a hashtable or dictionary.

    .DESCRIPTION
    Reads credentials from user and returns these as a hashtable or dictionary.

    .EXAMPLE
    Read-CredentialsToHashtable "database.username", "database.password"

    .EXAMPLE
    Read-CredentialsToHashtable "database.username", "database.password", "ams_support", "Enter credentials for AGA database"

    .PARAMETER usernameKey
    Key used to identify the username in the returned hashtable 

    .PARAMETER passwordKey
    Key used to identify the password in the returned hashtable 

    .PARAMETER defaultUsername
    Optional username 

    .PARAMETER message
    Message to appear in the credential dialog

#>
function Read-CredentialsToHashtable {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)][string] $usernameKey,
        [parameter(Mandatory=$true,position=1)][string] $passwordKey,
        [parameter(Mandatory=$false,position=2)][string] $message= "Enter credentials"
    )
       
    $credentialHashtable = @{}
    $credentials = Get-Credential -Message $message
    $credentialHashtable[$usernameKey] = $credentials.GetNetworkCredential().Username
    $credentialHashtable[$passwordKey] = $credentials.GetNetworkCredential().Password
    Write-Verbose-Settings $credentialHashtable
    $credentialHashtable
}

# region Private
function Write-Verbose-Settings {
    [CmdletBinding()]
    param(
        [hashtable] $credentialHashtable
    )
    $columnWidth = $credentialHashtable.Keys.length | Sort-Object| Select-Object -Last 1
    $credentialHashtable.GetEnumerator() | foreach {
        Write-Verbose ("   {0, -$columnWidth} : {1}" -F $_.Key, $_.Value)
    }
}
# end region
