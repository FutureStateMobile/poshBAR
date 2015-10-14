<#
    .SYNOPSIS
    Executes DBDeploy to generate a database delta script
    
    .PARAMETER fileToTokenReplace
    the file containing tokens to be replaced.
    
#>
function Invoke-DBDeploy {
	[CmdletBinding()]
	param(
		[parameter(Mandatory=$true,position=0)][string] $databaseName,
		[parameter(Mandatory=$true,position=1)][string] $dbDeployPackageDir,
		[parameter(Mandatory=$true,position=2)][string] $scriptsDir,
		[parameter(Mandatory=$true,position=3)][string] $connectionString,
		[parameter(Mandatory=$true,position=4)][string] $outputDir
		
	)
	Write-Verbose "Invoking DbDeploy with scripts directory $scriptsDir"
	$dbDeploy = "$dbDeployPackageDir\content\dbdeploy\DatabaseDeploy.exe"
	$timeStamp = Get-Date -Format FileDateTime
	$scriptFileName = "$($databaseName)_delta_$timeStamp.sql"
	$scriptFilePath = "$outputDir\$scriptFileName"
	$undoScriptFileName = "$($databaseName)_undo_$timeStamp.sql"
	$undoScriptFilePath = "$outputDir\$undoScriptFileName"
	$generatedUndoSQLScript = "$outputDir\$($databaseName)_undo_$timeStamp.sql"
	try {
		Push-Location $dbDeployPackageDir\content\dbdeploy
		Exec { .\DatabaseDeploy.exe -c $connectionString -o $scriptsDir -f $scriptFilePath -l "$outputDir\scripts_$timeStamp.txt" -u $undoScriptFilePath -w *.sql -s dbo -d mssql -r $false -t $false }
	} finally {
		Pop-Location
	}
	Write-Verbose "Finished generating delta script: $scriptFilePath"
	Write-Output @{
		'scriptFileName' = $scriptFileName
		'scriptFilePath' = $scriptFilePath
		'undoScriptFileName' = $undoScriptFileName
		'undoScriptFilePath' = $undoScriptFilePath
		
	}
}
