param($installPath, $toolsPath, $package, $project)

$rootDir = Resolve-Path "$installPath\..\.."
$solution = Get-ChildItem  "$path\*.sln" | select BaseName -First 1 | %{ $_.BaseName}

$tokenValues = @{
    '\[project\]' = $project
    '\[solution\]' = $solution
}

# copy the base build file
$baseBuildFile = "$toolsPath\templates\build.ps1"
if(-not (Test-Path "$rootDir\build.ps1")){
    Write-Host "Copying $baseBuildFile to $rootDir" -f Cyan
    Copy-Item $baseBuildFile $rootDir
}

#copy the base deploy file
$baseDeployFile = "$toolsPath\templates\deploy.ps1"
if(-not (Test-Path "$rootDir\deploy.ps1")){
    Write-Host "Copying $baseDeployFile to $rootDir" -f Cyan
    Copy-Item $baseDeployFile $rootDir
}

# iterate over everything else, and copy if the containing directory doesn't exist.
Get-Childitem "$toolsPath\templates" -recurse | % {
    if($($_.Directory) -ne $null){
        $subPath = $_.DirectoryName.replace("$toolsPath\templates", "")
        $copyPath = Join-Path $rootDir $subPath
      
        #if the templated (probably just `build` ) directory doesn't exists
        if(-not (Test-Path $copyPath)) {
            # create the templated directory
            New-Item -path $copyPath -itemtype Directory

            # and ALSO copy the contents over
            if(-not (Test-Path "$copyPath\$($_.Name)")){
                Write-Host "Copying $($_.Name) to $copyPath" -f Cyan
                Copy-Item $_.FullName $copyPath
                
                # token replace [project] with the $project name.
                $fileToTokenReplace = Join-Path $copyPath $_.Name
                $fileContents = Get-Content $fileToTokenReplace
                foreach ($token in $tokenValues.GetEnumerator()) {        
                    $fileContents = $fileContents -replace $token.Name, $token.Value
                }
                Set-Content -Path $fileToTokenReplace -Value $fileContents  
            }
        }
    }
 }