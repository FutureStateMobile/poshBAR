<#
    .DESCRIPTION
        Creates a linked server for ABIS database

    .EXAMPLE
        Add-SybaseLinkedServer

    .PARAMETER rootDir
        The root directory of the project used to locate the Sybase installer executable

    .SYNOPSIS
        Installs the Sybase 64-bit ODBC Driver if not already installed, creates
        a 64-bit System DSN for the ABIS database, and creates a linked server
        in SQL Server.

    .NOTES
        Nothing yet...
#>
function Add-SybaseLinkedServer
{
    param(
        [parameter(Mandatory=$true,position=0)] [string] $rootDir
    )

    $ErrorActionPreference = "Stop"

    $sybaseInstallDir = 'C:\Sybase'

    # Step 1) Install Driver
    if (Test-Path 'HKLM:\SOFTWARE\ODBC\ODBCINST.INI\Adaptive Server Enterprise') {
        Write-Host '64-bit Sybase ODBC driver already installed'
    } else {
        Write-Host 'Installing 64-bit Sybase ODBC driver...'
        $command = "$rootDir\tools\SybaseOdbcDriverInstaller\15.5\setup.exe"
        $params = '-i', 'silent',
                '-DRUN_SILENT=true',
                '-DAGREE_TO_SYBASE_LICENSE=true',
                "-DUSER_INSTALL_DIR=$sybaseInstallDir",
                '-DCHOSEN_FEATURE_LIST=fodbc64',
                '-DCHOSEN_INSTALL_FEATURE_LIST=fodbc64',
                '-DCHOSEN_INSTALL_SET=Custom'
        & $command $params
    }

    # Step 2) Create System DSN
    $dsnName = 'AbisLink'
    $basePath = 'HKLM:\SOFTWARE\ODBC\ODBC.INI' # 64-bit DSNs go here
    $dsnPath = "$basePath\$dsnName"
    if (Test-Path $dsnPath) {
        Write-Host "$dsnName System DSN already exists"
    } else {
        Write-Host "Adding $dsnName System DSN..."
        New-Item -Path $dsnPath
        New-ItemProperty -Path $dsnPath -Name 'Driver' -Value "$sybaseInstallDir\DataAccess64\ODBC\dll\sybdrvodb64.dll"
        New-ItemProperty -Path $dsnPath -Name 'server' -Value 's243p1.tcpl.ca'
        New-ItemProperty -Path $dsnPath -Name 'port' -Value '5600'
        New-ItemProperty -Path $dsnPath -Name 'database' -Value 'abis'
        New-ItemProperty -Path $dsnPath -Name 'userid' -Value 'abs_mlc'
        New-ItemProperty -Path $dsnPath -Name 'backendtype' -Value 'ASE'
        New-ItemProperty -Path $dsnPath -Name 'ansinull' -Value '1'
        New-ItemProperty -Path $dsnPath -Name 'serverinitiatedtransactions' -Value '1'
        # So DSN shows up in the ODBC Data Source Administrator application
        $dataSourcesPath = "$basePath\ODBC Data Sources"
        if (-Not (Test-Path $dataSourcesPath)) {
            New-Item -Path $dataSourcesPath
        }
        New-ItemProperty -Path $dataSourcesPath -Name $dsnName -Value 'Adaptive Server Enterprise'
    }

    # Step 3) Create Linked Server in SQL Server
    # TODO
}
