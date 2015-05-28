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
$i = 0
$commandsHelp = (Get-Command -module $moduleName) | get-help -full 

foreach ($h in $commandsHelp){
    $cmdHelp = (Get-Command $h.Name)

    # Get any aliases associated with the method
    $alias = get-alias -definition $h.Name -ErrorAction SilentlyContinue
    if($alias){ 
        $h | Add-Member Alias $alias
    }
    
    # Parse the related links and assign them to a links hashtable.
    if(($h.relatedLinks | Out-String).Trim().Length -gt 0) {
        $links = $h.relatedLinks.navigationLink | % {
            if($h.uri){ @{name = $h.uri; link = $h.uri; target='_blank'} } 
            if($h.linkText){ @{name = $h.linkText; link = "#$($h.linkText)"; cssClass = 'psLink'; target='_top'} }
        }
        $h.relatedLinks.linkText
        $h | Add-Member Links $links
    }

    foreach($p in $h.parameters.parameter ){
        $paramAliases = ($cmdHelp.parameters.values | where name -like $p.name | select aliases).Aliases
        if($paramAliases){
            $p | Add-Member Aliases "$($paramAliases -join ', ')" -Force
        }
    }
}

$totalCommands = $commandsHelp.Count
$template = Get-Content $template -raw -force
Invoke-Expression $template > "$outputDir\$fileName"