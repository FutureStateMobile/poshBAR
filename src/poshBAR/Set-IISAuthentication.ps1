<#
    .DESCRIPTION
       Will set the specified Authentication value for the specified applicaiton or website

    .EXAMPLE
        Set-IISAuthentication "windowsAuthentication" true "apps.tcpl.ca/MyApp"

    .PARAMETER settingName
        The name of the Authentication setting that we are changing

    .PARAMETER value
        What we want to change the setting to.

    .PARAMETER location
        The IIS location of the Application or Website that we want to change the setting on.

    .SYNOPSIS
        Will set the specified Authentication value for the specified applicaiton or website.
#>

function Set-IISAuthentication
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [AuthType] $settingName,
        [parameter(Mandatory=$true,position=1)] [PSObject] $value,
        [parameter(Mandatory=$true,position=2)] [string] $location
    )

    $ErrorActionPreference = "Stop"
    Import-Module "WebAdministration"
    Write-Host ($msgs.msg_updating_to -f $settingName, $value) -NoNewLine
    
    Set-WebConfigurationProperty -filter "/system.webServer/security/authentication/$settingName" -name enabled -value $value -PSPath "IIS:\" -location $location
    Write-Host "`tDone" -f Green

    if ($settingName -ne "anonymousAuthentication")
    {
        Write-Host ($msgs.msg_disable_anon_auth -f $location) -NoNewLine
        Set-WebConfigurationProperty -filter "/system.webServer/security/authentication/anonymousAuthentication" -name enabled -value "false" -PSPath "IIS:\" -location $location
        Write-Host "`tDone" -f Green
    }

    # Disable Negotiate (Kerberos) and use only NTLM
    # if ($settingName -eq "windowsAuthentication")
    # {
    #     Remove-WebConfigurationProperty -filter "/system.webServer/security/authentication/windowsAuthentication/providers" -name "." -PSPath "IIS:\" -location $location
    #     Add-WebConfiguration -filter "/system.webServer/security/authentication/windowsAuthentication/providers" -PSPath "IIS:\" -location $location -Value "NTLM"
    #     # if we ever need Kerberos then this would need to be added back 
    #     # Add-WebConfiguration-filter system.webServer/security/authentication/windowsAuthentication/providers -PSPath "IIS:\" -location $location -Value "Negotiate"
    # }

}

 Add-Type -TypeDefinition @'
    public enum AuthType{
        WindowsAuthentication,
        BasicAuthentication,
        AnonymousAuthentication,
        FormsAuthentication
    }
'@