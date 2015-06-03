<#
    .SYNOPSIS
        Execute block with with token replaced file
        
    .PARAMETER fileToTokenReplace
        File to perform token replacement on
        
    .PARAMETER tokenValues
        Hashtable of key value pairs to replaced in file

    .PARAMETER blockToAcceptTokenReplacedFile
        Block to execute with token replaced file. The block must accept the token replaced file path as the first parameter.
        
    .EXAMPLE
        Invoke-BlockWithTokenReplacedFile "somePath\someFile.txt" @{ 'token1Key' = 'token1Value'; 'token2Key' = 'token2Value' } {
            param($tokenReplacedFile) DoSomethingWithFile $tokenReplacedFile
        }
        
    .NOTES
        The file is token replaced and the contents stored in a file called "someFile.txt_tokenreplaced" (for example). This file is path is what is passed to the block. The file is automatically removed after the block is executed.
#>
function Invoke-BlockWithTokenReplacedFile {
    param(
        [parameter(Position=0)][string] $fileToTokenReplace,
        [parameter(position=1)][hashtable] $tokenValues,
        [parameter(position=2)][scriptblock] $blockToAcceptTokenReplacedFile
    )    
    $ErrorActionPreference = "Stop"
    $tokenReplacedFile = "$($fileToTokenReplace)_tokenreplaced"
    try {        
        $fileContents = Get-Content $fileToTokenReplace
        foreach ($token in $tokenValues.GetEnumerator()) {        
            $fileContents = $fileContents -replace $token.Name, $token.Value
        }
        Set-Content -Path $tokenReplacedFile -Value $fileContents                       
        Invoke-Command $blockToAcceptTokenReplacedFile -ArgumentList $tokenReplacedFile               
    } finally {
        Remove-Item $tokenReplacedFile -force
    }
    if($result -ne 0){$result}
}
