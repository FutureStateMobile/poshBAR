param($installPath, $toolsPath, $package, $project)

$rootDir = Resolve-Path "$installPath\..\.."

Get-Childitem "$toolsPath\templates" -recurse | % {
    if($($_.Directory) -ne $null){
        $subPath = $_.DirectoryName.replace("$toolsPath\templates", "")
        $copyPath = Join-Path $rootDir $subPath
        
        if(-not (Test-Path $copyPath)) {
            New-Item -path $copyPath -itemtype Directory
        }
        
        if(-not (Test-Path "$copyPath\$($_.Name)")){
            Write-Host "Copying $($_.Name) to $copyPath"
            Copy-Item $_.FullName $copyPath -force
        }
    }
 }

$deployFile = "deploy.ps1"
if(Test-Path "$rootDir\$deployFile"){
        Get-Content "$rootDir\$deployFile" | ForEach-Object { $_ -replace "fsm\.buildrelease\.((\d+)\.(\d+)\.(\d+)\.*(\d*))", "$package" } | Set-Content ($deployFile+".tmp")
    Remove-Item $deployFile
    Rename-Item ($deployFile+".tmp") $deployFile
}