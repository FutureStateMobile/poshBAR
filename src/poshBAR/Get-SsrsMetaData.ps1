<#
    .DESCRIPTION
        Retrieve SSRS metadata

    .EXAMPLE
        Get-SsrsMetadata -ReportServerEndpoint "http://localhost/ReportServer/ReportService2010.asmx"  `
                            -ReportServerFolder "/TechnologyManagmentReports"

    .PARAMETER ReportServerEndpoint
        The url of the Reporting Services web service end point 
        For example, http://[hostname]/ReportServer/ReportService2010.asmx

    .PARAMETER ReportServerFolder
        The folder on the server where the reports are to be uploaded to 

    .PARAMETER ReportServiceCredentials 
         [System.Management.Automation.PSCredential] - service
             credentials used to connect to the Report Server.  Defaults to integrated authentication.
    
    .RETURNS 
        SSRS Meta data object that contains name, type, etc.
#>
function Get-SsrsMetaData
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [String] $ReportServerEndpoint,
        [parameter(Mandatory=$true,position=1)] [String] $ReportServerFolder,
        [parameter(Mandatory=$false,position=2)] [System.Management.Automation.PSCredential] $ReportServiceCredentials
    )

    if (-not $ReportServerFolder.StartsWith('/')) {
        $ReportServerFolder = '/' + $ReportServerFolder
    }

    $ReportServerProxy = $null
    try
    {
        if ($ReportServiceCredentials -ne $null)
        {
            $ReportServerProxy = New-WebServiceProxy -Uri $ReportServerEndpoint -Credential $Options.$ReportServiceCredentials
        }
        else
        {
            $ReportServerProxy = New-WebServiceProxy -Uri $ReportServerEndpoint -UseDefaultCredential 
        }

        $ReportServerProxy.ListChildren($ReportServerFolder, $true)
    } 
    finally
    {
        if ($ReportServerProxy)
        {
            $ReportServerProxy.Dispose();
        }
    }
}
