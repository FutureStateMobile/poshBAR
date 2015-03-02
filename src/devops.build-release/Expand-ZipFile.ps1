<#
    .DESCRIPTION
        Expands any zip file and places the contents in the specified folder.

    .EXAMPLE
        Expand-ZipFile "something.pkg" "C:\temp\zipcontents"

    .PARAMETER zipFileName
        The full path to the zip file.

    .PARAMETER destinationFolder
        The full path to the desired unzip location.

    .SYNOPSIS
        Expands any zip file and places the contents in the specified folder.  This command uses the Windows Shell to do the unzip and as such the file 
        needs to end in ".zip" in order to work.  This module will temporarily rename the file to '.zip' extension if necessary in order to unzip it, 
        but it will rename it back when finished.

    .NOTES
        Nothing yet...
#>
function Expand-ZipFile
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [string] $zipFileName,
        [parameter(Mandatory=$true,position=1)] [string] $destinationFolder
    )

    $ErrorActionPreference = "Stop"

    if (!(Test-Path $destinationFolder)) {
        md $destinationFolder | Out-Null
    } else {
        Remove-Item "$destinationFolder\*" -recurse -Force
    }

    try {
        [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFileName, $destinationFolder)
    } catch {
    
        # This is slower, but is a good fallback if System.IO.Compression is not available
        $newZipFileName = $zipFileName + ".zip"
        Rename-Item $zipFileName $newZipFileName
        $shellApplication = new-object -com shell.application
        $zipPackage = $shellApplication.NameSpace($newZipFileName)
        $destination = $shellApplication.NameSpace($destinationFolder)
     
        ## CopyHere vOptions Flag # 4 - Do not display a progress dialog box.
        ## 16 - Respond with "Yes to All" for any dialog box that is displayed.
        $destination.CopyHere($zipPackage.Items(), 20)
        
        $zipfile = $newZipFileName
        $dst     = $destinationFolder

        Rename-Item $newZipFileName $zipFileName
    }
}