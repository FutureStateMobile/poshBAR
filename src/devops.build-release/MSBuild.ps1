function Invoke-MSBuild {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)] [string] $outDir,
        [Parameter(Mandatory=$true, Position=1)] [string] $projectFile,
        [Parameter(Mandatory=$true, Position=2)] [string] $logFile,
        [Parameter(Mandatory=$false, Position=3)] [double] $VisualStudioVersion = 12.0
    )

        exec { msbuild /t:build /p:OutDir="$outDir\" $projectFile /p:"VisualStudioVersion=$("{0:N1}" -f $VisualStudioVersion)" /l:"FileLogger,Microsoft.Build.Engine;logfile=$logFile" } ($msgs.error_msbuild_compile -f $projectFile)
}

function Get-WarningsFromMSBuildLog {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)] [alias("f")] $FilePath,
        [parameter()] [alias("ro")] $rawOutputPath,
        [parameter()][alias("o")] $htmlOutputPath
    )
     
    $warnings = @(Get-Content -ErrorAction Stop $FilePath |       # Get the file content
                    Where {$_ -match '^.*warning CS.*$'} |        # Extract lines that match warnings
                    %{ $_.trim() -replace "^s*d+>",""  } |        # Strip out any project number and caret prefixes
                    sort-object | Get-Unique -asString)           # remove duplicates by sorting and filtering for unique strings
     
    $count = $warnings.Count
     
    # raw output
    Write-Host "MSBuild Warnings - $count warnings ==================================================="
    $warnings | % { Write-Host " * $_" }
     
    #TeamCity output
    $msgs.msg_teamcity_buildstatus -f "{build.status.text}, Build warnings: $count"
    $msgs.msg_teamcity_buildstatisticvalue -f 'buildWarnings', $count
     
    # file output
    if( $rawOutputPath ){
        $stream = [System.IO.StreamWriter] $RawOutputPath
        $stream.WriteLine("Build Warnings")
        $stream.WriteLine("====================================")
        $stream.WriteLine("")
        $warnings | % { $stream.WriteLine(" * $_")}
        $stream.Close()
    }
     
    # html report output
    if( $htmlOutputPath -and $rawOutputPath ){
        $stream = [System.IO.StreamWriter] $htmlOutputPath
        $stream.WriteLine(@"
<html>
    <head>
        <style>*{margin:0;padding:0;box-sizing:border-box}body{margin:auto 10px}table{color:#333;font-family:sans-serif;font-size:.9em;font-weight:300;text-align:left;line-height:40px;border-spacing:0;border:1px solid #428bca;width:100%;margin:20px auto}thead tr:first-child{background:#428bca;color:#fff;border:none}th{font-weight:700}td:first-child,th:first-child{padding:0 15px 0 20px}thead tr:last-child th{border-bottom:2px solid #ddd}tbody tr:hover{background-color:#f0fbff}tbody tr:last-child td{border:none}tbody td{border-bottom:1px solid #ddd}td:last-child{text-align:left;padding-left:10px}</style>
</head>
<body>
"@)
        $stream.WriteLine("<table>")
        $stream.WriteLine(@"
<thead>
    <tr>
        <th colspan="2">Build Warnings</th>
    </tr>
    <tr>
        <th>#</th>
        <th>Message</th>
    </tr>
</thead>
<tbody>
"@)
        $warnings | % {$i=1} { $stream.WriteLine("<tr><td>$i</td><td>$_</td></tr>"); $i++ }
        $stream.WriteLine("</tbody></table>")
        $stream.WriteLine("</body></html>")
        $stream.Close()
    }
}