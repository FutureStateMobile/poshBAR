<#
    .DESCRIPTION
        Deploys the specified database using the configuration found in the matching environments
        configuration file found in the environments folder.

    .EXAMPLE
        Invoke-DatabaseDeploy "local" "MY_Database"

    .PARAMETER buildEnvironment
        The name of the environment we are deploying to, must match one of the configuration
        settings filenames in the evironments folder

    .PARAMETER targetDatabase
        The name of the database to deploy, uses this name to lookup the configuration settings
        for this database from the build environment xml file.

    .PARAMETER databaseDeployScriptsDir
        TODO

    .SYNOPSIS
        Will Deploy a database using DatabaseDeploy.exe and the xml settings for the configured environment
#>

function Invoke-DatabaseDeploy() {
    param(
        [parameter(Mandatory=$true,position=0)][string] $buildEnvironment,
        [parameter(Mandatory=$true,position=1)][string] $targetDatabase,
        [parameter(Mandatory=$true,position=2)][string] $connectionString,
        [parameter(Mandatory=$false,position=3)][switch] $rebuild,
        [parameter(Mandatory=$false,position=4)][switch] $loadData
    )
    
    $ErrorActionPreference = "Stop"

    Push-Location

    $currentDir = Split-Path $script:MyInvocation.MyCommand.Path
    $baseDir  = Resolve-Path "$currentDir\.."

    if ( Test-Path "$baseDir\..\database\$targetDatabase") {
        # Used during regular build
        $dbDir = Resolve-Path "$baseDir\..\database\$targetDatabase"

    } else {
        # when used during deploy of a nuget package
        $dbDir = "$baseDir\database"
    }

    $dbMigrationDir = "$dbDir\migrations"
    $createDatabaseScript = "$dbDir\CreateDatabase.sql"
    $updateScript = "$dbDir\upgradeScript.sql"
    $undoScript = "$dbDir\undoScript.sql"
    $dropAllScript = "$dbDir\DropAll.sql"
    $bulkloadDir = "$dbDir\bulkload"    
    $truncateScript = "$dbDir\Truncate.sql"
    $env:Path += ";$baseDir\modules\dbdeploy"

    Write-Host "Running the $targetDatabase database migrations for the $buildEnvironment environment."

    if ( $rebuild.IsPresent ) {
        # wrapping try catch here cause if the database doesn't exist, login will fail
        try {
            Write-Host "Dropping database $targetDatabase"
            Invoke-SqlFile $buildEnvironment $targetDatabase $dropAllScript $connectionString
        } catch {
            Write-Host "A database named $targetDatabase was not found."
        }
    }

    Write-Host "Creating the $targetDatabase database..." -noNewLine
    Invoke-SqlFile $buildEnvironment $targetDatabase $createDatabaseScript $connectionString -useMaster 
    Write-Host "done."

    Write-Host "Upgrading the $targetDatabase database..."  -noNewLine
    Invoke-ExternalCommand { DatabaseDeploy.exe -c "$connectionString" -d "mssql" -p "$dbMigrationDir" -f "$updateScript" -o "$dbMigrationDir" -s dbo -u "$undoScript" } "DatabaseDeploy failed to generate upgrade script."
        
    if (Test-Path -Path $updateScript) {
        Start-Sleep 5
        Invoke-SqlFile $buildEnvironment $targetDatabase $updateScript  $connectionString
        Write-Host "done."
    } else {
        Write-Host "the $targetDatabase database is up to date no upgrades necessary."
    }

    Pop-Location

    if ( $loadData.IsPresent ) {
        Write-Host "Looking for files to load in $bulkloadDir"

        if (Test-Path  ($bulkloadDir)){
            Invoke-SqlFile $buildEnvironment $targetDatabase $truncateScript $connectionString

            Get-ChildItem $bulkloadDir -recurse -include *.* | `
                Foreach-Object{
                    $fileName = $_.BaseName
                    $ext = $_.Extension
                    $tableName = $fileName -replace [RegEx]::Matches($fileName,"\d* ") , ""
                    $type = ","

                    if ($ext -eq ".txt") {
                        $type = "\t"
                    }

                    Invoke-BulkCopy $buildEnvironment $targetDatabase $tableName $_ $type $connectionString
                }

            Write-Host "Done data load for $targetDatabase"
        } else {
            Write-Host "No bulkload files exists for $targetDatabase."
        }
    }

    Write-Host "Finished $targetDatabase database migration."
}
