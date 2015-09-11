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
#>
function Expand-ZipFile
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,position=0)] [alias('name')]  [string] $zipFileName,
        [parameter(Mandatory=$true,position=1)] [alias('to', 'dest')]  [string] $destinationFolder
    )

    $ErrorActionPreference = "Stop"
    $guid = [guid]::NewGuid()
    $tempDir = "$($env:TEMP)\$guid"
    md $tempDir | Out-null

    if (!(Test-Path $destinationFolder)) {
        md $destinationFolder | Out-Null
    } else {
        Remove-Item "$destinationFolder\*" -recurse -Force -ea silentlyContinue
    }

    try {
        [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFileName, $tempDir)

        Get-ChildItem -Path $tempDir | % { 
          Copy-Item $_.fullname "$destinationFolder" -Recurse -ea silentlyContinue
        }

        rm -r $tempDir
    } catch {
        Write-Host "Using the slower Shell Application method for unzipping"
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
    } finally {
        if ($archive) {
            $archive.Dispose()
        }
    }
}