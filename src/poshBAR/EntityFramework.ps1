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