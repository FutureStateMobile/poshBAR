<#
    .DESCRIPTION
        Publish and upload SSRS reports to a Reporting Services

    .EXAMPLE
        Publish-SsrsReports -ReportsPath "C:\tms.1.1.1\Reports
                            -ReportServerEndpoint "http://repdev3.tcpl.ca/ReportServer/ReportService2010.asmx"  `
                            -ReportServerFolder "/TechnologyManagmentReports"
                            -Options @{"IncludeReports" = "YER.rdl"; "BackupFolder" = "C:\foo"}

    .PARAMETER ReportsPath
        The location where the report files to deploy 

    .PARAMETER ReportServerEndpoint
        The url of the Reporting Services web service end point 
        For example, http://[hostname]/ReportServer/ReportService2010.asmx

    .PARAMETER ReportServerFolder
        The folder on the server where the reports are to be uploaded to 

    .PARAMETER Options 
        The options is a hashtable that may contain one or more of the following:
    
         IncludeReports  - [string[]] one or more patterns to select which reports to deploy
         ExcluceReports  - [string[] one or more patters to exclude certain reports
         BackupFolder - [string] folder to download the reports currently on the server
         ReportServiceCredentials [System.Management.Automation.PSCredential] - service
             credentials used to connect to the Report Server.  Defaults to integrated authentication.
         OverwriteDataSources - [bool] Overwrite the datasources if present.  Defaults to false. 

         DataSourceName.Username - [string] if the datasource is not configured to 
           for windows authentication, then this should store the username.  
           NOte: 'Replace DataSourceName with the name of the data source'
            ex. TechnologyManagement.Username = 'TCPL\technology_mgmt_dev'
         DataSourceName.Password - [string] same as above only the password is stored.

    .NOTES
      Assumes flat structure where reporrts and datasource are in the same directory
      Does not support Datasets
#>
function Publish-SsrsReports
{
    [CmdletBinding()]
	param(
        [parameter(Mandatory=$true,position=0)] [String] $ReportsPath,
        [parameter(Mandatory=$true,position=1)] [String] $ReportServerEndpoint,
        [parameter(Mandatory=$true,position=2)] [String] $ReportServerFolder,
        [parameter(Mandatory=$false,position=3)] [Hashtable] $Options = @{}
	)

    $Include = $Options.IncludeReports
    $Exclude = $Options.ExcludeReports

    $FilesToUpload = Get-ChildItem $ReportsPath -Recurse -Include $Include -Exclude $Exclude -File
    Write-Verbose ("Reports Path: $ReportsPath, Number of files to upload:{0}" -f $FilesToUpload.Count)

    if (-not $ReportServerFolder.StartsWith('/')) {
        $ReportServerFolder = '/' + $ReportServerFolder
    }

    $Reports = $FilesToUpload | Where {$_.Extension -match ".rdl" } 
    $ReportDatasources = $FilesToUpload | Where {$_.Extension -match ".rds" }

    try
    {
        if ($Options.ReportServiceCredentials -ne $null)
        {
            $script:ReportServerProxy = New-WebServiceProxy -Uri $ReportServerEndpoint -Credential $Options.$ReportServiceCredentials
        }
        else
        {
            $script:ReportServerProxy = New-WebServiceProxy -Uri $ReportServerEndpoint -UseDefaultCredential 
        }

        New-SsrsFolder $ReportServerFolder

        $ExistingSsrsItems = $ReportServerProxy.ListChildren($ReportServerFolder, $true)

        $ReportDatasources   | foreach {
            $dataSourceFile = $_
            New-SsrsDataSource $dataSourceFile $ExistingSsrsItems $ReportServerFolder $Options
        }

        $Reports | foreach {
            $ReportFile = $_
            Backup-ExistingItem  $ReportFile $ExistingSsrsItems $Options.BackupFolder "Report"
            Upload-Reports $ReportFile $ReportServerFolder
        }
    } 
    finally
    {
        if ($ReportServerProxy)
        {
            $ReportServerProxy.Dispose();
        }
    }
}


#region private 

function New-SsrsFolder ([string] $Name) {

    if ($ReportServerProxy.GetItemType($Name) -ne 'Folder') {
        $Parts = $Name -split '/'
        $Leaf = $Parts[-1]
        $Parent = $Parts[0..($Parts.Length-2)] -join '/'
 
        if ($Parent) {
            New-SsrsFolder -Name $Parent
        } else {
            $Parent = '/'
        }
        
        $CatalogItem = $ReportServerProxy.CreateFolder($Leaf, $Parent, $null)
    }
}

function New-SsrsDataSource([System.IO.FileInfo]$DataSourceFile, [Array]$ExistingSsrsItems, [string]$ReportFolder, [Hashtable]$Options){
    
    $OverwriteDataSources = if ($Options.OverwriteDataSources) {[System.Convert]::ToBoolean($Options.OverwriteDataSources)} else {$false}

    $DataSourceXml = [xml](Get-Content -Path $DataSourceFile.FullName)
    $DataSourceName = "$($DataSourceXml.RptDataSource.Name)"

    $found = $ExistingSsrsItems | where {
        $_.TypeName -eq "DataSource" -and $_.Name -eq $DataSourceName
    }

    if ($found.length -le 0 -or $OverwriteDataSources) {
        $Definition = New-DataSourceDefinition $DataSourceXml.RptDataSource $ReportFolder $Options
        $ReportServerProxy.CreateDataSource($DataSourceName, $ReportFolder, $OverwriteDataSources, $Definition, $null)
    }
}

function New-DataSourceDefinition([System.Xml.XmlElement]$DataSourceXml, [string]$ReportFolder, [Hashtable]$Options){

    $DsType = ("$($ReportServerProxy.GetType().Namespace)" + '.DataSourceDefinition')
    $Definition = new-object ($DsType)
   
    $DsName = "$($DataSourceXml.Name)"
    $ConnectionProperties = $DataSourceXml.ConnectionProperties
    $Definition.ConnectString = $ConnectionProperties.ConnectString
    $Definition.Extension= $ConnectionProperties.Extension
    $Definition.Enabled = $true
    
    if ([System.Convert]::ToBoolean($($ConnectionProperties.IntegratedSecurity))) {
        $Definition.CredentialRetrieval = 'Integrated'
        Write-Verbose "Configuring $DsName for Windows Integrated Authentication"
    } else {
        $Definition.CredentialRetrieval = 'Store'

        $dsUsername = $($Options["$($DsName).Username"])
        $Definition.UserName = $dsUsername

        $dsPassword = $($Options["$($DsName).Password"])
        $Definition.Password = $dsPassword

        Write-Verbose "Configuring $DsName to store credentials: $dsUsername/$dsPassword"
    }
    $Definition
}


function Backup-ExistingItem([System.IO.FileInfo]$ReportFile, [Array]$ExistingSsrsItems, [string]$BackupFolder, 
    [string] $itemType){

    if (!$BackupFolder){
        return
    }

    $found = $ExistingSsrsItems | where {
        $_.TypeName -eq $itemType -and $_.Name -eq $ReportFile.Basename
    }

    if ($found.length -gt 0) {

        if (!(Test-Path $BackupFolder)){
            New-Item -ItemType Directory -Path $BackupFolder
        }


        $ExistingReportAsBytes = $ReportServerProxy.GetItemDefinition($found[0].Path)

        $BackupPath = "{0}\{1}{2}" -f $BackupFolder, $ReportFile.Basename, $ReportFile.Extension

        [System.IO.File]::WriteAllBytes($BackupPath, $ExistingReportAsBytes)

        Write-Verbose "Backed up $($found[0].Path) to $BackupPath"
    }
}

function Upload-Reports ([System.IO.FileInfo] $ReportFile, [string] $ReportFolder) {
    Upload-Item $ReportFile "Report" $ReportFolder
}

function Upload-Item ([System.IO.FileInfo] $ItemFile, [string] $ItemType, [string] $ReportFolder) {

    $ItemData = [System.IO.File]::ReadAllBytes($ItemFile.Fullname)
    $ItemName = $ItemFile.Basename
    $Warnings = $null 
   
    [void]$ReportServerProxy.CreateCatalogItem($ItemType, $ItemName, $ReportFolder, $true, $ItemData, $null, [ref] $Warnings)

    if ($Warnings){
        $Warnings | % {Write-Warning $_.Message }
    }
    Write-Host "Uploaded $ItemName"
}
#endregion 
