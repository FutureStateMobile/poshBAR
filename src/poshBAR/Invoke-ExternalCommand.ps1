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

.PARAMETER retry
The number of times to retry the command before failing.
 
.EXAMPLE
  Invoke-ExternalCommand { svn info $repository_trunk } "Error executing SVN. Please verify SVN command-line client is installed"
#>
function Invoke-ExternalCommand
{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][scriptblock] $command,
        [Parameter(Position=1,Mandatory=0)][string] $errorMessage = ($msgs.error_bad_command -f $command),
        [Parameter(Mandatory=0)] [int] $retry = 0
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
                throw ($errorMessage)
            } else {
                $completed = $true
            }
        } catch {
            if ($retrycount -ge $retry) {
                Write-Verbose ("Command [{0}] failed after {1} retries." -f $command, $retrycount)
                throw ($errorMessage)
            } else {
                Write-Verbose ("Command [{0}] failed. Retrying..." -f $command, $secondsDelay)
                $retrycount++
            }
        }
    }
}
Set-Alias Exec Invoke-ExternalCommand