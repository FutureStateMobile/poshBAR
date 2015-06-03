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
    #if($result -ne 0){$result}
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
