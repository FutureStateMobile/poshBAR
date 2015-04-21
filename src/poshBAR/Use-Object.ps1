<#
    .DESCRIPTION
        This will allow you to wrap a disposable object in a using statement (akin to C#), and it will dispose of that object when the 
        scriptblock is finished executing.
        
    .EXAMPLE
        Use-Object ($foo = new-object System.Some.Disposable.Object) {
            $foo.DoSomething
        }
        
    .PARAMETER InputObject
        A disposable object

    .PARAMETER ScriptBlock
        The script block that  you need to dispose of.

    .SYNOPSIS
        Wrap a disposable object in this method, and after the scriptblock executes, it will dispose of the object.

    .NOTES
        Nothing yet...
#> 
function Use-Object
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowEmptyCollection()] [AllowNull()] [Object] $InputObject,
        [Parameter(Mandatory = $true)] [scriptblock] $ScriptBlock
    )
 
    try
    {
        . $ScriptBlock
    }
    finally
    {
        if ($null -ne $InputObject -and $InputObject -is [System.IDisposable])
        {
            $InputObject.Dispose()
        }
    }
}
Set-Alias psUsing Use-Object