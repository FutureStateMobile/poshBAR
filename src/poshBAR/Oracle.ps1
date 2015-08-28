<#
    .SYNOPSIS
        Execute Oracle SQL Command using OracleClient
        
    .PARAMETER sqlToRun
        SQL to be Executed
        
    .PARAMETER connectionString
        Oracle Connection String
        
    .EXAMPLE
        Invoke-OracleCommand "SELECT 2*35 FROM DUAL" "Data Source=;User Id=SYSTEM;Password=xxxx"
            
    .LINK
        https://msdn.microsoft.com/en-us/library/system.data.oracleclient%28v=vs.110%29.aspx
        
    .NOTES
        SQL commands can only contain a single command, you can get around this by using BEGIN EXECUTE IMMEDIATE 'SELECT .... '; EXECUTE IMMEDIATE 'SELECT ....'; END;
#>
function Invoke-OracleCommand {
    [CmdletBinding()]
    param(
        [parameter(Position=0)][string] $sqlToRun,
        [parameter(Position=1)][string] $connectionString
    )    
    $ErrorActionPreference = "Stop"
        
    [Reflection.Assembly]::LoadWithPartialName("System.Data.OracleClient") | Out-Null
    $connection = New-Object DATA.OracleClient.OracleConnection($connectionString)
    $cmd = New-Object DATA.OracleClient.OracleCommand($sqlToRun, $connection)

    try {
        $connection.Open()
        $result = $cmd.ExecuteNonQuery()
    } finally { 
        $connection.Close()
        $connection.Dispose()
    }
}
<#
    .SYNOPSIS
        Execute Oracle SQL Command using OracleClient
        
    .PARAMETER sqlFile
        SQL script containing sql commands
        
    .PARAMETER connectionString
        Oracle Connection String
        
    .EXAMPLE
        Invoke-OracleFile "C:\path\to\script.sql" "Data Source=;User Id=SYSTEM;Password=xxxx"
            
    .LINK
        https://msdn.microsoft.com/en-us/library/system.data.oracleclient%28v=vs.110%29.aspx
        
    .NOTES
        SQL commands can only contain a single command, you can get around this by using BEGIN EXECUTE IMMEDIATE 'SELECT .... '; EXECUTE IMMEDIATE 'SELECT ....'; END;
#>
function Invoke-OracleFile {
    [CmdletBinding()]
    param(
        [parameter(Position=0)][string] $sqlFile,
        [parameter(Position=1)][string] $connectionString
    )
    $ErrorActionPreference = "Stop"
        
    $sqlToRun = Get-Content $sqlFile | Out-String
    Invoke-OracleCommand $sqlToRun $connectionString
}

<#
    .SYNOPSIS
        DROPS Database! Drops a development Oracle database by dropping tablespace
        
    .PARAMETER $schemaName
        The name of the schema
        
    .PARAMETER $schemaOwnerUserId
        The user id of the user that owns the schema        
           
    .PARAMETER $connectionString
        The oracle database connection string
                     
    .EXAMPLE
        Remove-OracleDatabase 'MyDatabase' 'MyUser' 'Data Source=localhost/XE;User Id=system;Password=SAus3r' $false
                
    .NOTES
        WARNING: only to be used on development databases - DROPS the Database!
#>
function Remove-OracleDatabase {
    param(        
        [parameter(Mandatory=$true,position=0)] [string] $schemaName,
        [parameter(Mandatory=$true,position=1)] [string] $schemaOwnerUserId,
        [parameter(Mandatory=$true,position=2)] [string] $connectionString,
        [parameter(Mandatory=$false,position=3)] [boolean] $failOnError = $true
	)        	                                  
    try {
        Write-Verbose "Dropping database schema owner $schemaOwnerUserId"
        Invoke-OracleCommand "drop user $schemaOwnerUserId cascade" $connectionString
    } catch {
        $message = "Failed to drop schema owner $schemaOwnerUserId when removing database."
        if ($failOnError) { throw $message } else { Write-Warning $message }        
    }            
    try {
        
        Write-Verbose "Removing database tablespace $schemaName"
        Invoke-OracleCommand "DROP TABLESPACE $schemaName INCLUDING CONTENTS AND DATAFILES" $connectionString
    } catch {
        $message = "Failed to drop tablespace $schemaName when removing database."
        if ($failOnError) { throw $message } else { Write-Warning $message }
    }                    
}
<#
    .SYNOPSIS
        CREATES new database with requested user as owner
        
    .PARAMETER $schemaName
        The name of the schema
        
    .PARAMETER $databaseStorageFile
        The absolute path of the file to store the tablespace in
        
    .PARAMETER $schemaOwnerUserId
        The user id of the user to own the schema
        
    .PARAMETER $schemaOwnerPassword
        The password for the schema owner
           
    .PARAMETER $connectionString
        The oracle database connection string
                     
    .EXAMPLE
        New-OracleDatabase 'MyDatabase' 'C:\databases\MyDatabase.dbf' 'MyUser' 'MyUserPassword' 'Data Source=localhost/XE;User Id=system;Password=SAus3r'
                    
#>
function New-OracleDatabase {
    param(        
        [parameter(Mandatory=$true,position=0)] [string] $schemaName,
        [parameter(Mandatory=$true,position=1)] [string] $databaseStorageFile,
        [parameter(Mandatory=$true,position=2)] [string] $schemaOwnerUserId,
        [parameter(Mandatory=$true,position=3)] [string] $schemaOwnerPassword,
        [parameter(Mandatory=$true,position=4)] [string] $connectionString
	)        	   

    $dbDir = Split-Path $databaseStorageFile                       
    if(! (Test-Path $dbDir)) {
        # create the database directory if it doesn't exist
        New-Item -ItemType Directory -Force -Path $dbDir 
    }    
    Write-Host "Creating tablespace $schemaName in file $databaseStorageFile"
    Invoke-OracleCommand "CREATE TABLESPACE $schemaName DATAFILE '$databaseStorageFile' SIZE 10M REUSE AUTOEXTEND ON NEXT 10M MAXSIZE 200M" $connectionString       
    Write-Host "Creating user $($databaseConfig.userId)" 
    Invoke-OracleCommand "GRANT all PRIVILEGES TO $userId IDENTIFIED BY $schemaOwnerPassword" $connectionString    		
}
<#
    .SYNOPSIS
        DROPS and RECREATES Database! Resets a development Oracle database by dropping tablespace and recreating with requested user as owner
        
    .PARAMETER $schemaName
        The name of the schema
        
    .PARAMETER $databaseStorageFile
        The absolute path of the file to store the tablespace in
        
    .PARAMETER $schemaOwnerUserId
        The userId of the user to own the schema
        
    .PARAMETER $schemaOwnerPassword
        The password for the user
           
    .PARAMETER $connectionString
        The oracle database connection string
                     
    .EXAMPLE
        Reset-OracleDatabase 'MyDatabase' 'C:\databases\MyDatabase.dbf' 'MyUser' 'MyUserPassword' 'Data Source=localhost/XE;User Id=system;Password=SAus3r'
                
    .NOTES
        WARNING: only to be used on development databases - DROPS the Database!
#>
function Reset-OracleDatabase {
    param(        
        [parameter(Mandatory=$true,position=0)] [string] $schemaName,
        [parameter(Mandatory=$true,position=1)] [string] $databaseStorageFile,
        [parameter(Mandatory=$true,position=2)] [string] $schemaOwnerUserId,
        [parameter(Mandatory=$true,position=3)] [string] $schemaOwnerPassword,
        [parameter(Mandatory=$true,position=4)] [string] $connectionString
	)        	   

    $dbDir = Split-Path $databaseStorageFile                       
    if(Test-Path $dbDir) {
        Remove-OracleDatabase $schemaName $schemaOwnerUserId $connectionString
    }    
    New-OracleDatabase $schemaName $databaseStorageFile $schemaOwnerUserId $schemaOwnerPassword $connectionString    		
}
