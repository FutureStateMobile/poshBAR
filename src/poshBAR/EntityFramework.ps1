<#
    .DESCRIPTION
        Run Entity Framework migrations against a target database.

    .SYNOPSIS
        Run Entity Framework migrations against a target database.
    
    .PARAMETER targetAssembly
        The assembly containing the Entity Framework Migrations
    
    .PARAMETER startupDirectory
        If your assembly has dependencies or reads files relative to the working directory then you will need to set startupDirectory.
    
    .PARAMETER connectionString
        Connection string to the database server
        
    .PARAMETER databaseName
        Name of the database being migrated
    
    .PARAMETER dropDB
        Should the database be dropped prior to running the migrations. This is good during integration testing.
        
    .NOTES
        This method depends on the SQLHelpers module, and the EF 'migrate.exe' (see links below).
        
    .LINK
        Invoke-SqlStatement
        
    .LINK
        https://msdn.microsoft.com/en-us/data/jj618307.aspx
    
#>
function Invoke-EntityFrameworkMigrations ([string] $targetAssembly, [string] $startupDirectory, [string] $connectionString, [string] $databaseName, [switch] $dropDB){
    if($dropDB.IsPresent){ 
        Write-Host "Dropping current database."
        try{
            Invoke-SqlStatement "DROP DATABASE $databaseName" $connectionString -useMaster | Out-Null
        } catch [Exception] {
            Write-Warning $_
        }

    }

    Write-Host "`nRunning Entity Framework Migrations."
    exec {migrate.exe $targetAssembly /StartUpDirectory=$startupDirectory /connectionString=$connectionString /connectionProviderName="System.Data.SqlClient"}
}
Set-Alias efMigrate Invoke-EntityFrameworkMigrations