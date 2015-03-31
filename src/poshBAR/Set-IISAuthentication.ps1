<#
    .DESCRIPTION
       Will set the specified Authentication value for the specified applicaiton or website

    .EXAMPLE
        Set-IISAuthentication "windowsAuthentication" true "apps.tcpl.ca/MyApp"

    .PARAMETER authTypes
        The name of the Authentication setting that we are changing

    .PARAMETER value
        What we want to change the setting to.

    .PARAMETER location
        The IIS location of the Application or Website that we want to change the setting on.

    .PARAMETER disableOthers
        Disables all other authentication types except for the ones contained in the array.

    .SYNOPSIS
        Will set the specified Authentication value for the specified applicaiton or website.
#>
function Set-IISAuthentication
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string[]] [ValidateSet('anonymousAuthentication','basicAuthentication','clientCertificateMappingAuthentication','digestAuthentication','iisClientCertificateMappingAuthentication','windowsAuthentication')] [AllowNull()] $authTypes,
        [parameter(Mandatory=$true,position=1)] [PSObject] $value,
        [parameter(Mandatory=$true,position=2)] [string] $location,
        [parameter(Mandatory=$false, position=3)] [switch] $disableOthers
    )

    $ErrorActionPreference = "Stop"
    Import-Module "WebAdministration"

    if($disableOthers.IsPresent){
        #disable all types
        Write-Host ($msgs.msg_disable_auth -f $location) -NoNewLine
        Set-WebConfigurationPropertyExtended -filter "/system.webServer/security/authentication/anonymousAuthentication" -name enabled -value false -PSPath "IIS:\" -location $location -retry 10
        Set-WebConfigurationPropertyExtended -filter "/system.webServer/security/authentication/basicAuthentication" -name enabled -value false -PSPath "IIS:\" -location $location -retry 10
        Set-WebConfigurationPropertyExtended -filter "/system.webServer/security/authentication/clientCertificateMappingAuthentication" -name enabled -value false -PSPath "IIS:\" -location $location -retry 10
        Set-WebConfigurationPropertyExtended -filter "/system.webServer/security/authentication/digestAuthentication" -name enabled -value false -PSPath "IIS:\" -location $location -retry 10
        Set-WebConfigurationPropertyExtended -filter "/system.webServer/security/authentication/iisClientCertificateMappingAuthentication" -name enabled -value false -PSPath "IIS:\" -location $location -retry 10
        Set-WebConfigurationPropertyExtended -filter "/system.webServer/security/authentication/windowsAuthentication" -name enabled -value false -PSPath "IIS:\" -location $location -retry 10
        Write-Host "`tDone" -f Green
    }

    # no need to check if $authTypes is null, if it is, nothing happens.
    $validSet = @('anonymousAuthentication','basicAuthentication','clientCertificateMappingAuthentication','digestAuthentication','iisClientCertificateMappingAuthentication','windowsAuthentication')
    $authTypes | % {
        if($validSet -contains $_){
            Write-Host ($msgs.msg_update_auth -f $_, $location, $value) -NoNewLine
            Set-WebConfigurationPropertyExtended -filter "/system.webServer/security/authentication/$_" -name enabled -value "$value" -PSPath "IIS:\" -location $location -retry 10
            Write-Host "`tDone" -f Green
        }
    }
      

    # turn off anonymous auth if it's not part of the collection.
    if ($authTypes -notContains "anonymousAuthentication")
    {
         Set-WebConfigurationPropertyExtended -filter "/system.webServer/security/authentication/anonymousAuthentication" -name enabled -value false -PSPath "IIS:\" -location $location -retry 10
    }
    
}

function Set-WebConfigurationPropertyExtended {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true, position=0)] [string] $name,
        [parameter(Mandatory=$true, position=1)] [PSObject] $value,
        [parameter(Mandatory=$false,position=2)] [string[]] $filter,
        [parameter(Mandatory=$false,position=3)] [string[]] $PSPath,
        [parameter(Mandatory=$false,position=4)] [string[]] $location,
        [parameter(Mandatory=$false,position=5)] [int] $retry = 0
    )
    
    # Setting ErrorAction to Stop is important. This ensures any errors that occur in the command are 
    # treated as terminating errors, and will be caught by the catch block.
    $ErrorAction = "Stop"
    
    $retrycount = 0
    $completed = $false

    while (-not $completed) {
        try {
            Set-WebConfigurationProperty -filter $filter -name $name -value $value -PSPath $PSPath -location $location

            if ($lastexitcode -ne 0) {
                throw
            } else {
                $completed = $true
            }
        } catch {
            if ($retrycount -ge $retry) {
                Write-Verbose ("Set-WebConfigurationProperty failed after {1} retries." -f $retrycount)
                throw ($_)
            } else {
                Write-Verbose ("Set-WebConfigurationProperty failed. Retrying...")
                $retrycount++
            }
        }
    }
}