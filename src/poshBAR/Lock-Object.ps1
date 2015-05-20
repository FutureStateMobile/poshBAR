<#
    .Synopsis
       Locks an object to prevent simultaneous access from another thread.
       
    .DESCRIPTION
       PowerShell implementation of C#'s "lock" statement.  Code executed in the script block does not have to worry about simultaneous modification of the object by code in another thread.
       
    .PARAMETER InputObject
       The object which is to be locked.  This does not necessarily need to be the actual object you want to access; it's common for an object to expose a property which is used for this purpose, such as the ICollection.SyncRoot property.
       
    .PARAMETER ScriptBlock
       The script block that is to be executed while you have a lock on the object.
       Note:  This script block is "dot-sourced" to run in the same scope as the caller.  This allows you to assign variables inside the script block and have them be available to your script or function after the end of the lock block, if desired.
       
    .EXAMPLE
       $hashTable = @{}; lock ($hashTable.SyncRoot) {  $hashTable.Add("Key", "Value") }
       This is an example of using the "lock" alias to Lock-Object, in a manner that most closely resembles the similar C# syntax with positional parameters.
       
    .EXAMPLE
       $hashTable = @{}; Lock-Object -InputObject $hashTable.SyncRoot -ScriptBlock { $hashTable.Add("Key", "Value")}
       This is the same as Example 1, but using the full PowerShell command and parameter names.
       
    .INPUTS
       None.  This command does not accept pipeline input.
       
    .OUTPUTS
       System.Object (depends on what's in the script block.)
       
    .NOTES
        Most of the time, PowerShell code runs in a single thread.  You have to go through several steps to create a situation in which multiple threads can try to access the same .NET object.  In the Links section of this help topic, there is a blog post by Boe Prox which demonstrates this.
        
    .LINK
        https://davewyatt.wordpress.com/2014/04/06/thread-synchronization-in-powershell/
        
    .LINK
       http://learn-powershell.net/2013/04/19/sharing-variables-and-live-objects-between-powershell-runspaces/
#>
function Lock-Object
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [object]
        $InputObject,
 
        [Parameter(Mandatory = $true, Position = 1)]
        [scriptblock]
        $ScriptBlock
    )
 
    if ($InputObject.GetType().IsValueType)
    {
        $params = @{
            Message      = "Lock object cannot be a value type."
            TargetObject = $InputObject
            Category     = [System.Management.Automation.ErrorCategory]::InvalidArgument
            ErrorId      = 'CannotLockValueType'
        }
 
        Write-Error @params
        return
    }
 
    $lockTaken = $false
 
    try
    {
        [System.Threading.Monitor]::Enter($InputObject)
        $lockTaken = $true
        . $ScriptBlock
    }
    catch
    {
        $params = @{
            Exception    = $_.Exception
            Category     = [System.Management.Automation.ErrorCategory]::OperationStopped
            ErrorId      = 'InvokeWithLockError'
            TargetObject = New-Object psobject -Property @{
                ScriptBlock  = $ScriptBlock
                ArgumentList = $ArgumentList
                InputObject  = $InputObject
                LockProperty = $LockProperty
            }
        }
 
        Write-Error @params
        return
    }
    finally
    {
        if ($lockTaken)
        {
            [System.Threading.Monitor]::Exit($InputObject)
        }
    }
}
 
Set-Alias -Name Lock -Value Lock-Object