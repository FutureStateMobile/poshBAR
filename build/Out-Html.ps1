param($moduleName, $outputDir = './help', $fileName = 'default.html')
function FixString {
    param($in = '')
    if ($in -eq $null) {
        $in = ''
    }
    return $in.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('`n', '<br>').Replace('`t', '&nbsp;&nbsp;&nbsp;&nbsp;').Trim()

}

$commandsHelp = (Get-Command -module $moduleName) | get-help -full
$template = Get-Content 'C:\Dev\poshBAR\build\out-html-template.txt' -raw -force

Invoke-Expression $template > "$outputDir\$fileName"
