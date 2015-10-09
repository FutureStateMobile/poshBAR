[array]$poshBAR.TotalWarnings = @()

<#
    .SYNOPSIS
        Compiles a solution or project against MSBuild
    
    .EXAMPLE
        Invoke-MSBuild $buildOutputDir $solutionFile
        Standard build against the defaults
        
    .EXAMPLE
        Invoke-MSBuild $buildOutputDir $solutionFile -customParameters @('/property:SomeProperty=value')
        Standard build with additional parameters.

    .EXAMPLE
        Invoke-MSBuild $buildOutputDir $solutionFile -target 'clean' -logPath 'c:\logs' -namespace 'My.App.Namespace' -visualStudioVersion 11.0 -toolsVersion 4.0 -maxCpuCount 8 -verbosity 'normal' -warnOnArchitectureMismatch $true 
        Builds the $solutionFile with all command parameters

    .PARAMETER outDir
        The output directory for your compilation

    .PARAMETER target
        Build the specified targets in the project. Specify each target separately, or use a semicolon or comma to separate multiple targets

    .PARAMETER projectFile
        The path to your project (.csproj) or solution (.sln) file

    .PARAMETER logPath
        The directory where your logs should end up

    .PARAMETER namespace
        Used when generating build warnings.

    .PARAMETER visualStudioVersion
        The version of Visual Studio that the solution or project was built against

    .PARAMETER toolsVersion
        The version of the .NET framework that the solution or project targets

    .PARAMETER maxCpuCount
        Maximum number of CPU's to use during the compilation

    .PARAMETER warnOnArchitectureMismatch
        Show warnings for architecture missmatch (x86 and x64) [MSB3270]
        
    .PARAMETER customParameters
        Additional msbuild parameters in array  format. 
        
    .PARAMETER verbosity
        Sets the MSBuild verbosity
        - [q]uiet
        - [m]inimal
        - [n]ormal
        - [d]etailed
        - [diag]nostic

    .NOTES
        The toolset version isn't the same as the target framework, which is the version of the .NET Framework on which a project is built to run. 

    .LINK
        https://msdn.microsoft.com/en-us/library/ms164311.aspx
#>
function Invoke-MSBuild {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)] [string] $outDir,
        [Parameter(Mandatory=$true, Position=1)] [string] $projectFile,
        [Parameter(Mandatory=$false)] [string] [alias('t')]$target = 'build',
        [Parameter(Mandatory=$false)] [string] $logPath,
        [Parameter(Mandatory=$false)] [string] $namespace,
        [Parameter(Mandatory=$false)] [double] $visualStudioVersion = 12.0,
        [Parameter(Mandatory=$false)] [string] [alias('tv')]$toolsVersion = 4.0,
        [Parameter(Mandatory=$false)] [int] [alias('m')]$maxCpuCount = 1,
        [Parameter(Mandatory=$false)] [string] [alias('v','loglevel')] [ValidateSet('q', 'quiet', 'm', 'minimal', 'n', 'normal','d', 'detailed','diag', 'diagnostic')] $verbosity = 'minimal',
        [Parameter(Mandatory=$false)] [bool] $warnOnArchitectureMismatch = $false,
        [Parameter(Mandatory=$false)] [string[]] $customParameters
    )

    # make sure the output directory has a trailing slash
    if(!$outDir.EndsWith('\')) { $outDir += '\' }

    # Due to a quirk with MSBuild's OutDir property, make sure that paths with spaces end with two backslashes.
    if($outDir.Contains(' ') -and !$outDir.EndsWith('\\')) { $outDir += '\' }

    if(-not (Test-Path "$logPath\MSBuild")) {
        mkdir "$logPath\MSBuild" | out-null
    }

    $logFileParam = "logfile=$logPath\MSBuild\" + $(if($namespace){"Raw.$namespace.txt" } else { 'msbuild.txt' })
    
    $culture = New-Object System.Globalization.CultureInfo("en-US")
    $culturedVSVersion = $VisualStudioVersion.ToString('0.0', $culture)
    $params = @(
        "/target:$target", 
        "/verbosity:$verbosity",
        "/logger:FileLogger,Microsoft.Build.Engine;$logFileParam",
        "/property:OutDir=$outDir", 
        "/property:VisualStudioVersion=$culturedVSVersion",
        "/property:ToolsVersion=$("{0:N1}" -f $toolsVersion)",
        "/property:ResolveAssemblyWarnOrErrorOnTargetArchitectureMismatch=$warnOnArchitectureMismatch",
        "/maxcpucount:$maxCpuCount") 
 
    if($customParameters){ $params += $customParameters }
 
    Write-Host "Invoking: `nmsbuild.exe $projectFile $params `n"
    try {
        exec { msbuild.exe $projectFile $params } ($msgs.error_msbuild_compile -f $projectFile)
    } finally {
        if($namespace){
            New-WarningsFromMSBuildLog $logPath $namespace
        }
    }
}
Set-Alias msbuild Invoke-MSBuild
Set-Alias compile Invoke-MSBuild

<#
    .SYNOPSIS
        Cleans the project/solution
    
    .EXAMPLE
        Invoke-CleanMSBuild $buildOutputDir 
        Cleans the solution quietly
        
    .EXAMPLE
        Invoke-CleanMSBuild $buildOutputDir -verbosity n
        Cleans the solution with the normal msbuild output

    .PARAMETER projectFile
        The path to your project (.csproj) or solution (.sln) file
        
    .PARAMETER verbosity
        Sets the MSBuild verbosity
        - [q] = quiet
        - [m] - minimal
        - [n] = normal
        - [d] = detailed
        - [diag] = diagnostic
#>
function Invoke-CleanMSBuild {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)] [string] $projectFile,
        [Parameter(Mandatory=$false, Position=1)] [string] [ValidateSet('q', 'm', 'n','d','diag')] $verbosity = 'q'
    )
    
    exec { msbuild.exe @($projectFile, 
                     '/t:clean', 
                     "/v:$verbosity", 
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
