param(
    [parameter(Mandatory=$true, Position=0)] [string] $moduleName, 
    [parameter(Mandatory=$false, Position=1)] [string] $template = "./out-html-template.ps1",
    [parameter(Mandatory=$false, Position=2)] [string] $outputDir = './help', 
    [parameter(Mandatory=$false, Position=3)] [string] $fileName = 'index.html'
)

function FixString ($in = '', [bool]$includeBreaks = $false){
    if ($in -eq $null) { return }
    
    $rtn = $in.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Trim()
    
    if($includeBreaks){
        $rtn = $rtn.Replace([Environment]::NewLine, '<br>')
    }
    return $rtn
}

function Update-Progress($name, $action){
    Write-Progress -Activity "Rendering $action for $name" -CurrentOperation "Completed $progress of $totalCommands." -PercentComplete $(($progress/$totalCommands)*100)
}

$commandsHelp = (Get-Command -module $moduleName) | get-help -full
$commandsHelp | % {
    $alias = get-alias -definition $_.Name   -ErrorAction SilentlyContinue
    if($alias){ 
        $_ | Add-Member Alias $alias
    }
    if(($_.relatedLinks | Out-String).Trim().Length -gt 0) {
        $links = $_.relatedLinks.navigationLink | % {
            if($_.uri){ @{name = $_.uri; link = $_.uri; target='_blank'} } 
            if($_.linkText){ @{name = $_.linkText; link = "#$($_.linkText)"; cssClass = 'psLink'} }
        }
        $_.relatedLinks.linkText #| % { "<a href='#'" }
        $_ | Add-Member Links $links
    }
}

$totalCommands = $commandsHelp.Count
$template = Get-Content $template -raw -force
Invoke-Expression $template > "$outputDir\$fileName"