<#
    .DESCRIPTION
        Write out the build variables in a formatted table

    .EXAMPLE
        Write-BuildInformation (get-variable -scope 0)

    .PARAMETER variables
        The array of variables from the global scope

    .SYNOPSIS

    .NOTES
        Nothing yet...
#>
function Write-BuildInformation {
    param(
            [parameter(Mandatory=$true)] [array] $variables 
        )

    "-" * 70
    "Build Information"
    "-" * 70
    
    $req = @("Version", 
             "buildEnvironment", 
             "buildNumber", 
             "informationalVersion",
             "includeCoverage")

    $variables | 
    where-object {$req -contains $_.Name} |
    ft -autosize -property Name, Value | 
    out-string -stream | 
    where-object { $_ }
}