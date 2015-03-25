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
        [parameter(Mandatory=$true,position=0)] [AuthType[]] [AllowNull()] $authTypes,
        [parameter(Mandatory=$true,position=1)] [PSObject] $value,
        [parameter(Mandatory=$true,position=2)] [string] $location,
        [parameter(Mandatory=$false, position=3)] [switch] $disableOthers
    )

    $ErrorActionPreference = "Stop"
    Import-Module "WebAdministration"
    
    if($disableOthers.IsPresent){
        #disable all types
        Write-Host ($msgs.msg_disable_auth -f $location) -NoNewLine
        Set-WebConfigurationProperty -filter "/system.webServer/security/authentication/anonymousAuthentication" -name enabled -value false -PSPath "IIS:\" -location $location
        Set-WebConfigurationProperty -filter "/system.webServer/security/authentication/basicAuthentication" -name enabled -value false -PSPath "IIS:\" -location $location
        Set-WebConfigurationProperty -filter "/system.webServer/security/authentication/clientCertificateMappingAuthentication" -name enabled -value false -PSPath "IIS:\" -location $location
        Set-WebConfigurationProperty -filter "/system.webServer/security/authentication/digestAuthentication" -name enabled -value false -PSPath "IIS:\" -location $location
        Set-WebConfigurationProperty -filter "/system.webServer/security/authentication/iisClientCertificateMappingAuthentication" -name enabled -value false -PSPath "IIS:\" -location $location
        Set-WebConfigurationProperty -filter "/system.webServer/security/authentication/windowsAuthentication" -name enabled -value false -PSPath "IIS:\" -location $location
        Write-Host "`tDone" -f Green
    }

    # no need to check if $authTypes is null, if it is, nothing happens.
    $authTypes | % {
        if(-not ([string]::IsNullOrWhiteSpace($_))){
            Write-Host ($msgs.msg_update_auth -f $_, $location, $value) -NoNewLine
            Set-WebConfigurationProperty -filter "/system.webServer/security/authentication/$_" -name enabled -value $value -PSPath "IIS:\" -location $location
            Write-Host "`tDone" -f Green
        }
    }
      

    # turn off anonymous auth if it's not part of the collection.
    if ($authTypes -notContains "anonymousAuthentication")
    {
         Set-WebConfigurationProperty -filter "/system.webServer/security/authentication/anonymousAuthentication" -name enabled -value false -PSPath "IIS:\" -location $location
    }
    
}

if(!("AuthType" -as [Type])){
 Add-Type -TypeDefinition @'
    public enum AuthType{
        anonymousAuthentication,
        basicAuthentication,
        clientCertificateMappingAuthentication,
        digestAuthentication,
        iisClientCertificateMappingAuthentication,
        windowsAuthentication    
    }
'@
}