<#
.SYNOPSIS
  This is a helper function that runs a scriptblock and checks the PS variable $lastexitcode
  to see if an error occcured. If an error is detected then an exception is thrown.
  This function allows you to run command-line programs without having to
  explicitly check the $lastexitcode variable.

.DESCRIPTION
This executes a scriptblock and checks the PS variable $lastexitcode for errors.

.PARAMETER command
The command in the form of a script block that you want to execute.

.PARAMETER errorMessage
The message you'd like to display on failure of the command.
Defaults to thrown exception if left blank.

.PARAMETER retry
The number of times to retry the command before failing.

.PARAMETER msDelay
The number of milliseconds to delay between retries. (only applies when $retry -gt 0)
 
.EXAMPLE
Exec { git st } "Error getting GIT status. Please verify GIT command-line client is installed"
 
.EXAMPLE
Invoke-ExternalCommand {get st} "Error getting GIT status. Please verify GIT command-line client is installed" -retry 10 -msDelay 1000
In this example, we retry the `git st` command 10 times with a 1 second delay in between. 
#>
function Invoke-ExternalCommand
{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true)][scriptblock] $command,
        [Parameter(Position=1,Mandatory=$false)][string] $errorMessage,
        [Parameter(Mandatory=$false)] [int] $retry = 0,
        [Parameter(Mandatory=$false)] [int] $msDelay = 250
    )
 
    # Setting ErrorAction to Stop is important. This ensures any errors that occur in the command are 
    # treated as terminating errors, and will be caught by the catch block.
    $ErrorAction = "Stop"
    
    $retrycount = 0
    $completed = $false

    while (-not $completed) {
        try {
            & $command

            if ($lastexitcode -ne 0) {
                $e = if($errorMessage){$errorMessage} else {($error[0] | out-string)} 
                throw $e
            } else {
                $completed = $true
            }
        } catch {
            if ($retrycount -ge $retry) {
                Write-Verbose ("Command [{0}] failed after {1} retries." -f $command, $retrycount)
                throw $_.Exception
            } else {
                Write-Verbose ("Command [{0}] failed. Retrying in {1}ms" -f $command, $msDelay)
                Write-Verbose $_
                Start-Sleep -m $msDelay
                $retrycount++
            }
        $lastexitcode = 0
        }
    }
}
Set-Alias Exec Invoke-ExternalCommand
Set-Alias Execute Invoke-ExternalCommand