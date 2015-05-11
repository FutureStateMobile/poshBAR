[array]$poshBAR.TotalWarnings = @()

<#
    .SYNOPSIS
        Compiles a solution or project against MSBuild
    
    .EXAMPLE
        Invoke-MSBuild $buildOutputDir $solutionFile
        Standard build against the defaults

    .EXAMPLE
        Invoke-MSBuild $buildOutputDir $solutionFile -DotNetVersion 4.0
        Builds the $solutionFile against a different version of the .NET framework.

    .PARAMETER outDir
        The output directory for your compilation

    .PARAMETER projectFile
        The path to your project (.csproj) or solution (.sln) file

    .PARAMETER logPath
        The directory where your logs should end up

    .PARAMETER namespace
        Used when generating build warnings.

    .PARAMETER VisualStudioVersion
        The version of Visual Studio that the solution or project was built against

    .PARAMETER dotNetVersion
        The version of the .NET framework that the solution or project targets

    .PARAMETER maxCpuCount
        Maximum number of CPU's to use during the compilation
        
    .PARAMETER verbosity
        Sets the MSBuild verbosity
        - [q] = quiet
        - [m] - minimal
        - [n] = normal
        - [d] = detailed
        - [diag] = diagnostic
#>
function Invoke-MSBuild {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)] [string] $outDir,
        [Parameter(Mandatory=$true, Position=1)] [string] $projectFile,
        [Parameter(Mandatory=$false, Position=2)] [string] $logPath,
        [Parameter(Mandatory=$false, Position=3)] [string] $namespace,
        [Parameter(Mandatory=$false, Position=4)] [AllowNull()] [double] $VisualStudioVersion = $null,
        [Parameter(Mandatory=$false, Position=5)] [AllowNull()] [double] $dotNetVersion = $null,
        [Parameter(Mandatory=$false, Position=6)] [AllowNull()] [int] $maxCpuCount = $null,
        [Parameter(Mandatory=$false, Position=7)] [string] [ValidateSet('q', 'm', 'n','d','diag')] $verbosity = 'm'
    )

    if($namespace){
        if(-not (Test-Path "$logPath\MSBuild")) {
            mkdir "$logPath\MSBuild"
        }

        $logFileParam = "logfile=$logPath\MSBuild\Raw.$namespace.txt"
    }
    
    $params = @(
        '/t:build', 
        "/p:OutDir=$outDir", 
        "/verbosity:$verbosity"
        $projectFile, 
        '/p:ResolveAssemblyWarnOrErrorOnTargetArchitectureMismatch=false',
        "/l:FileLogger,Microsoft.Build.Engine;$logFileParam") 
    
    if($visualStudioVersion){ $params += ("/p:VisualStudioVersion=$("{0:N1}" -f $VisualStudioVersion)") }
    if($dotNetVersion){ $params += ("/p:ToolsVersion=$("{0:N1}" -f $dotNetVersion)") }
    if($maxCpuCount) {$params += ("/m:$maxCpuCount")}
    
    exec { msbuild.exe $params } ($msgs.error_msbuild_compile -f $projectFile)

    if($namespace){
        New-WarningsFromMSBuildLog $logPath $namespace
    }
}
Set-Alias msbuild Invoke-MSBuild
Set-Alias compile Invoke-MSBuild

function Invoke-CleanMSBuild {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)] [string] $solutionFile
    )
    
    exec { msbuild.exe @($solutionFile, 
                     '/t:clean', 
                     '/v:q', 
                     '/nologo') } "Error cleaning the solution."
}

function New-WarningsFromMSBuildLog {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)] [string] $logPath,
        [parameter(Mandatory=$true)] [string] $namespace
    )

    $FilePath       = "$logPath\MSBuild\Raw.$namespace.txt"
    $txtOutputPath  = "$logPath\MSBuild\Wrn.$namespace.txt"
    $htmlOutputPath = "$logPath\MSBuild\Wrn.$namespace.html"
    
    $warnings = @(cat -ea Stop $FilePath |      # Get the file content
        ? { $_ -match '^.*warning CS.*$' } |    # Extract lines that match warnings
        % { $_.trim() -replace "^s*d+>",""  } | # Strip out any project number and caret prefixes
        sort | gu -asString)                    # remove duplicates by sorting and filtering for unique strings
     
    [int]$count = $warnings.Count
    if($count -eq 0) {return}

    # Merge current warnings with the existing ones, and ensure there are no duplicates.
    $poshBAR.TotalWarnings = @($poshBAR.TotalWarnings + $warnings | sort -unique)

    # this is the warning count for teamcity.
    $TeamCityWrnCount = $poshBAR.TotalWarnings.Count
    $msgs.msg_teamcity_buildstatus -f "{build.status.text}, Build warnings: $($TeamCityWrnCount)"
    $msgs.msg_teamcity_buildstatisticvalue -f 'buildWarnings', $TeamCityWrnCount
    
    # raw output
    Write-Host "MSBuild Warnings - $count warnings ==================================================="
    $warnings | % { Write-Host " * $_" }
     
    # file output
    if( $txtOutputPath ){
        $stream = [System.IO.StreamWriter] $txtOutputPath
        $stream.WriteLine("Build Warnings")
        $stream.WriteLine("====================================")
        $stream.WriteLine("")
        $warnings | % { $stream.WriteLine(" * $_")}
        $stream.Close()
    }
     
    # html report output
    if( $htmlOutputPath -and $txtOutputPath ){
        $stream = [System.IO.StreamWriter] $htmlOutputPath
        $stream.WriteLine(
@'
<html>
    <head>
        <style>*{margin:0;padding:0;box-sizing:border-box}body{margin:auto 10px}table{color:#333;font-family:sans-serif;font-size:.9em;font-weight:300;text-align:left;line-height:40px;border-spacing:0;border:1px solid #428bca;width:100%;margin:20px auto}thead tr:first-child{background:#428bca;color:#fff;border:none}th{font-weight:700}td:first-child,th:first-child{padding:0 15px 0 20px}thead tr:last-child th{border-bottom:2px solid #ddd}tbody tr:hover{background-color:#f0fbff}tbody tr:last-child td{border:none}tbody td{border-bottom:1px solid #ddd}td:last-child{text-align:left;padding-left:10px}</style>
</head>
<body>
'@)
        $stream.WriteLine('<table>')
        $stream.WriteLine(
@'
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
'@)
        $warnings | % {$i=1} { $stream.WriteLine("<tr><td>$i</td><td>$_</td></tr>"); $i++ }
        $stream.WriteLine('</tbody></table>')
        $stream.WriteLine('</body></html>')
        $stream.Close()
    }
}
