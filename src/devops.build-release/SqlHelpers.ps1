$ErrorActionPreference = "Stop"

if(-NOT (Get-Module sqlps -erroraction silentlycontinue)){
    # Pushing and Poping because SQLPS changes the directory to SQLSERVER:\
    Push-Location
    Import-Module sqlps -DisableNameChecking
    Pop-Location
}

Function Get-DatabaseConnectionProperties() {
    param(
        [parameter(Mandatory=$true,position=0)][string] $buildEnvironment,
        [parameter(Mandatory=$true,position=1)][string] $targetDatabase,
        [parameter(Mandatory=$true,position=2)][string] $connectionString
    )

    $connStringBuilder = New-Object System.Data.Common.DbConnectionStringBuilder
    $connStringBuilder.set_ConnectionString($connectionString)

    return $connStringBuilder
}

Function Invoke-SqlStatement() {
    param(
        [parameter(Mandatory=$true,position=0)][string] $buildEnvironment,
        [parameter(Mandatory=$true,position=1)][string] $targetDatabase,
        [parameter(Mandatory=$true,position=2)][string] $sqlToRun,
        [parameter(Mandatory=$true,position=3)][string] $connectionString,
        [parameter(Mandatory=$false,position=4)][switch] $useMaster
    )

    try {
        $conn = Get-DatabaseConnectionProperties $buildEnvironment $targetDatabase $connectionString

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
        $errorMsg = $_
        Write-Host $errorMsg   # will display the actual sql error in the console
        throw $errorMsg
    }
}

Function Invoke-SqlFile() {
    param(
        [parameter(Mandatory=$true,position=0)][string] $buildEnvironment,
        [parameter(Mandatory=$true,position=1)][string] $targetDatabase,
        [parameter(Mandatory=$true,position=2)][string] $sqlFile,
        [parameter(Mandatory=$true,position=3)][string] $connectionString,
        [parameter(Mandatory=$false,position=4)][switch] $useMaster
    )

    try {
        $conn = Get-DatabaseConnectionProperties $buildEnvironment $targetDatabase $connectionString

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
        $errorMsg = $_
        Write-Host $errorMsg   # will display the actual sql error in the console
        throw $errorMsg
    }
}

Function Invoke-BulkCopy() {
    param(
        [parameter(Mandatory=$true,position=0)][string] $buildEnvironment,
        [parameter(Mandatory=$true,position=1)][string] $targetDatabase,
        [parameter(Mandatory=$true,position=2)][string] $targetTable,
        [parameter(Mandatory=$true,position=3)][string] $inputFile,
        [parameter(Mandatory=$true,position=4)][string] $formatType,
        [parameter(Mandatory=$true,position=5)][string] $connectionString
    )

    $copySql = "BULK INSERT dbo.$targetTable
                FROM '$inputFile'
                WITH (FIELDTERMINATOR = '$formatType',  ROWTERMINATOR = '\n',  FirstRow = 2, KEEPIDENTITY, KEEPNULLS)
                GO"

	try {

		Invoke-SqlStatement $buildEnvironment $targetDatabase $copySql $connectionString

	} catch {
        $errorMsg = $_
        Write-Host "Error loading $inputFile error: " $errorMsg   # will display the actual sql error in the console
		throw $errorMsg
	}
}
