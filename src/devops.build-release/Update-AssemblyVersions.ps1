<#
    .DESCRIPTION
        This will search for AssemblyInfo.cs files in the current directory and its sub directories, 
        and then updates the AssemblyVersion and AssemblyFileVersion.

    .EXAMPLE
        Update-AssemblyVersions '3.1.2', '233', '3.1.2 Beta 1'

    .PARAMETER Version
        A string containing the version of this dll.  This would be in the format of {Major}.{Minor}.{Revision}

    .PARAMETER BuildNumber
        An optional object (of any type) to be passed in to the scriptblock (available as $input)

    .PARAMETER AssemblyInformationalVersion
        A switch that enables powershell profile loading for the elevated command/block

    .SYNOPSIS
        Update all the AssemblyInfo.cs files in a solution so they are the same.

    .NOTES
        Nothing yet...
#> 
function Update-AssemblyVersions
{
    [CmdletBinding()]
    param( 
        [parameter(Mandatory=$true,position=0)] [ValidatePattern('^([0-9]{0,3}\.[0-9]{0,3}\.[0-9]{0,3})(\.[0-9]*?)?$')] [string] $Version,
        [parameter(Mandatory=$true,position=1)] [string] $BuildNumber,
        [parameter(Mandatory=$true,position=2)] [string] $AssemblyInformationalVersion,
        [parameter(Mandatory=$false,position=3)] [string] $projectRoot = "..\"
    )

    $ErrorActionPreference = "Stop"

    $assemblyVersionPattern = 'AssemblyVersion\(".*?"\)'
    $assenblyCopyrightPattern = 'AssemblyCopyright\(".*?"\)'
    $fileVersionPattern = 'AssemblyFileVersion\(".*?"\)'
    $informationalVersionPattern = 'AssemblyInformationalVersion\(".*?"\)'
    
    $assemblyVersion = 'AssemblyVersion("' + $Version + '")';
    $assemblyCopyright = 'AssemblyCopyright("Copyright © ' + $((Get-Date).year) + '")';
    $fileVersion = 'AssemblyFileVersion("' + $Version + '.' + $BuildNumber + '")';
    $informationalVersion = 'AssemblyInformationalVersion("' + $AssemblyInformationalVersion + '")';
    
    $msgs.msg_updating_assembly -f $version, $Version.$BuildNumber, $AssemblyInformationalVersion

    Push-Location "$projectRoot\Properties"

    Get-ChildItem -r -filter AssemblyInfo.cs | ForEach-Object {
        $filename = $_.Directory.ToString() + '\' + $_.Name
        
        # If you are using a source control that requires to check-out files before 
        # modifying them, make sure to check-out the file here.
        # For example, TFS will require the following command:
        # tf checkout $filename
    
        (Get-Content $filename) | ForEach-Object {
            % {$_ -replace $assemblyVersionPattern, $assemblyVersion } |
            % {$_ -replace $assenblyCopyrightPattern, $assemblyCopyright } |
            % {$_ -replace $fileVersionPattern, $fileVersion } |
            % {$_ -replace $informationalVersionPattern, $informationalVersion }
        } | Set-Content $filename

        Write-Host "$filename - Updated"
    }
    Pop-Location
}
