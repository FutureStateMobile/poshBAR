function Test-PathExtended {
    param(
        [parameter(Mandatory=$true,position=1)] [string] $path
    )

    $paths = $env:Path -split ";"
    $found = (Test-Path $path)

    if(-not $found){
        $paths | % {
            $_ = $($_.Replace(";",""))
            if(Test-Path "$_\$path"){
                $found = $true
            }
        }
    }

    return $found
}