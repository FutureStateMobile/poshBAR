$appcmd = "$env:windir\system32\inetsrv\appcmd.exe"
<#
    .DESCRIPTION
        Will register a mimetype for a file extension.

    .EXAMPLE
        Add-IISMimeType "foo.example.com" "json" "application/json"

    .PARAMETER siteName
        The name of the IIS site.

    .PARAMETER fileExtension
        The file extension to map to the mime type.

    .PARAMETER mimeType
        The mime type name.

    .SYNOPSIS
        Will add a mapping for the file extension to the mime type on the named IIS site.
#>

function Add-IISMimeType
{
    [CmdletBinding()]
    param(
        [parameter( Mandatory=$true, position=0 )] [string] $siteName,
        [parameter( Mandatory=$true, position=1 )] [string] $fileExtension,
        [parameter( Mandatory=$true, position=2 )] [string] $mimeType
    )

    $ErrorActionPreference = "Stop"
    Write-Host ($msgs.msg_add_mime_type -f $mimeType, $fileExtension, $siteName) -NoNewLine

    Exec { "$appcmd set config $siteName /section:staticContent /-`"[fileExtension='.$fileExtension']`""} -retry 10 | Out-Null
    Exec { "$appcmd set config $siteName /section:staticContent /+`"[fileExtension='.$fileExtension',mimeType='$mimeType']`""} -retry 10 | Out-Null
    
   Write-Host "`tDone" -f Green
}
