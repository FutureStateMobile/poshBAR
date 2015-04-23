param(
    [parameter(Mandatory=$true, Position=0)]$moduleName, 
    [parameter(Mandatory=$false, Position=1)]$outputDir = './help', 
    [parameter(Mandatory=$false, Position=2)]$fileName = 'default.html'
)

function FixString {
    param($in = '')
    if ($in -eq $null) {
        return
    }
    return $in.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('`n', '<br>').Replace('`t', '&nbsp;&nbsp;&nbsp;&nbsp;').Trim()
}

function Update-Progress($name, $action){
    Write-Progress -Activity "Rendering $action for $name" -CurrentOperation "Completed $progress of $totalCommands." -PercentComplete $(($progress/$totalCommands)*100)
}

$commandsHelp = (Get-Command -module $moduleName) | get-help -full

$totalCommands = $commandsHelp.Count

$template = Get-Content 'C:\Dev\poshBAR\build\out-html-template.ps1' -raw -force

Invoke-Expression $template > "$outputDir\$fileName"
