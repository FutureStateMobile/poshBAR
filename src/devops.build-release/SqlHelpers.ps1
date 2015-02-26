$ErrorActionPreference = "Stop"

if(-NOT (Get-Module sqlps -erroraction silentlycontinue)){
    # Pushing and Poping because SQLPS changes the directory to SQLSERVER:\
    Push-Location
    Import-Module sqlps -DisableNameChecking -ErrorAction SilentlyContinue
    Pop-Location
}

function Get-DatabaseConnectionProperties() {
    param(
        [parameter(Mandatory=$true,position=0)][string] $connectionString
    )

    $connStringBuilder = New-Object System.Data.Common.DbConnectionStringBuilder
    $connStringBuilder.set_ConnectionString($connectionString)
    
    # Fix to ensure we get the appropriate variables out of the connection string.
    if(!$connStringBuilder['Server']){$connStringBuilder['Server'] = $connStringBuilder['Data Source']}
    if(!$connStringBuilder['Database']){$connStringBuilder['Database'] = $connStringBuilder['Initial Catalog']}
    if(!$connStringBuilder['Password']){$connStringBuilder['Password'] = $connStringBuilder['Pwd']}

    return $connStringBuilder
}

function Invoke-SqlStatement() {
    param(
        [parameter(Mandatory=$true,position=0)][string] $sqlToRun,
        [parameter(Mandatory=$true,position=1)][string] $connectionString,
        [parameter(Mandatory=$false)][switch] $useMaster
    )

    try {
        $conn = Get-DatabaseConnectionProperties $connectionString

        if ( $useMaster.isPresent ) {
            $conn["Database"] = "master"
        }

        if ($conn["User Id"] -ne $null) {
            Invoke-SqlCmd -Query $sqlToRun -serverinstance $conn["Server"] -database $conn["Database"] -Username $conn["User Id"] -Password $conn["Password"]
        }
        else {
            Invoke-SqlCmd -Query $sqlToRun -serverinstance $conn["Server"] -database $conn["Database"]
        }
    } catch {
        Write-Host $_ -f Red  # will display the actual sql error in the console
        throw $_
    }
}

function Invoke-SqlFile() {
    param(
        [parameter(Mandatory=$true,position=0)][string] $sqlFile,
        [parameter(Mandatory=$true,position=1)][string] $connectionString,
        [parameter(Mandatory=$false,position=2)][switch] $useMaster
    )

    try {
        $conn = Get-DatabaseConnectionProperties $connectionString

        if ( $useMaster.isPresent ) {
            $conn["Database"] = "master"
        }

        if ($conn["User Id"] -ne $null) {
            Invoke-SqlCmd -InputFile $sqlFile -serverinstance $conn["Server"] -database $conn["Database"] -Username $conn["User Id"] -Password $conn["Password"]
        }
        else {
            Invoke-SqlCmd -InputFile $sqlFile -serverinstance $conn["Server"] -database $conn["Database"]
        }
    } catch {
        Write-Host $_ -f Red  # will display the actual sql error in the console
        throw $_
    }
}

function Invoke-BulkCopy() {
    param(
        [parameter(Mandatory=$true,position=0)][string] $targetTable,
        [parameter(Mandatory=$true,position=1)][string] $inputFile,
        [parameter(Mandatory=$true,position=2)][string] $formatType,
        [parameter(Mandatory=$true,position=3)][string] $connectionString
    )

    $copySql = "BULK INSERT dbo.$targetTable
                FROM '$inputFile'
                WITH (FIELDTERMINATOR = '$formatType',  ROWTERMINATOR = '\n',  FirstRow = 2, KEEPIDENTITY, KEEPNULLS)
                GO"

    try {

        Invoke-SqlStatement $copySql $connectionString

    } catch {
        Write-Error ($msgs.error_loading_sql_file -f $inputFile, $_)
        exit 1
    }
}