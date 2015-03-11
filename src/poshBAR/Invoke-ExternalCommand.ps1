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
 
.EXAMPLE
  Invoke-ExternalCommand { svn info $repository_trunk } "Error executing SVN. Please verify SVN command-line client is installed"
#>
function Invoke-ExternalCommand
{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][scriptblock] $command,
        [Parameter(Position=1,Mandatory=0)][string] $errorMessage = ($msgs.error_bad_command -f $command)
    )

    & $command
    
    if ($lastexitcode -ne 0) {
        throw ($errorMessage)
    }
}
Set-Alias Exec Invoke-ExternalCommand