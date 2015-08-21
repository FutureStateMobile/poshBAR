<#
    .DESCRIPTION
        This will search for AssemblyInfo.cs files in the current directory and its sub directories, 
        and then updates the AssemblyVersion and AssemblyFileVersion.

    .EXAMPLE
        Update-AssemblyVersions '3.1.2', '233', '3.1.2 Beta 1'

    .PARAMETER Version
        A string containing the version of this dll.  This would be in the format of {Major}.{Minor}.{Revision}

    .PARAMETER BuildNumber
        The build number of the assembly.

    .PARAMETER AssemblyInformationalVersion
        A string value indicating some info about the assembly
        
    .PARAMETER ProjectRoot
        Where to begin recursion when searching for the AssemblyInfo.cs files to be updated.
        
    .PARAMETER copyrightFormatString
        The string to use when setting the assembly's copyright info. This parameter includes a single position format option [ {0} ] that is replaced with the current year.

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
        [parameter(Mandatory=$false,position=3)] [string] $projectRoot = "..\",
        [parameter(Mandatory=$false,position=4)] [string] [alias('copyright')]$copyrightFormatString
    )

    $ErrorActionPreference = "Stop"

    $assemblyVersionPattern = 'AssemblyVersion(Attribute)?\(".*?"\)'
    $assenblyCopyrightPattern = 'AssemblyCopyright(Attribute)?\(".*?"\)'
    $fileVersionPattern = 'AssemblyFileVersion(Attribute)?\(".*?"\)'
    $informationalVersionPattern = 'AssemblyInformationalVersion(Attribute)?\(".*?"\)'
   
    $assemblyVersion = 'AssemblyVersion("' + $Version + '.' + $BuildNumber + '")';
    $assemblyCopyright = 'AssemblyCopyright("' + ($copyright -f $((Get-Date).year)) + '")';
    $fileVersion = 'AssemblyFileVersion("' + $Version + '.' + $BuildNumber + '")';
    $informationalVersion = 'AssemblyInformationalVersion("' + $AssemblyInformationalVersion + '")';
    
    $msgs.msg_updating_assembly -f $Version, "$Version.$BuildNumber", $AssemblyInformationalVersion

    Push-Location "$projectRoot"

    ls -r -filter AssemblyInfo.cs | % {
        $filename = $_.Directory.ToString() + '\' + $_.Name
        #ni "$filename.temp" -type file
        # If you are using a source control that requires to check-out files before 
        # modifying them, make sure to check-out the file here.
        # For example, TFS will require the following command:
        # tf checkout $filename
        try {
            (cat $filename) | % {
                % {$_ -replace $assemblyVersionPattern, $assemblyVersion } |
                % {if($copyright) {$_ -replace $assenblyCopyrightPattern, $assemblyCopyright} } |
                % {$_ -replace $fileVersionPattern, $fileVersion } |
                % {$_ -replace $informationalVersionPattern, $informationalVersion }
            } | sc "$filename.temp"   
            rm $filename -force 
        } finally {
            ren "$filename.temp" $filename    
        }
        "$filename - Updated"
    }
    Pop-Location
}
