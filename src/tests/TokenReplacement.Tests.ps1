$ErrorActionPreference = 'Stop'

Describe 'TokenReplacement' { 
    
    BeforeAll {
        # Setup Mocks
        Mock Write-Host {} -ModuleName poshBar # just prevents verbose output during tests.
        Mock -moduleName poshBAR Get-WindowsFeatures {return @{'Fake-WindowsFeature' = 'disabled' }}
        Mock -moduleName poshBAR Invoke-ExternalCommand {}
    }
    
    Context 'Will replace a single token in single line file.' {

        $testFilePath = Join-Path $TestDrive 'testFileToReplace.txt'
        $testToken = "@@here is a token@@"
        $originalFileContents = "Here is some content and $testToken to be replaced"
        [io.file]::WriteAllText($testFilePath,$originalFileContents)
        $testOutputFile = Join-Path $TestDrive 'result.txt'
        $expectedTokenValue = "some value"
        $expectedOutput = "Here is some content and $expectedTokenValue to be replaced"
        
        # execute
        Write-TokenReplacedFile $testFilePath $testOutputFile @{ $testToken = $expectedTokenValue }
        
        # assert
        It 'Should have created output file' {
            (Test-Path $testOutputFile) | should be $true
        }
        
        It 'Should have created original file with original content' {            
            Get-Content -Raw $testFilePath | should be $originalFileContents
        }
        
        It 'Should have the expected tokens replaced in output file' {
            Get-Content -Raw $testOutputFile | should be $expectedOutput
        }                
    } 
    
    Context 'Will replace a multiple tokens in a multi line file.' {
        
        $testFilePath = Join-Path $TestDrive 'testFileToReplace.txt'
        $testToken = "@@here is a token@@"
        $testToken2 = "anotherToken for replacement"
        $originalFileContents = "Here is some content and $testToken to be replaced $(([Environment]::NewLine)) plus some more content $testToken2 to be replaced too"
        [io.file]::WriteAllText($testFilePath,$originalFileContents)
        $testOutputFile = Join-Path $TestDrive 'result.txt'
        $expectedTokenValue = "some value"
        $expectedTokenValue2 = "the next value 2"            
        $expectedOutput = "Here is some content and $expectedTokenValue to be replaced $(([Environment]::NewLine)) plus some more content $expectedTokenValue2 to be replaced too"
        
        # execute
        Write-TokenReplacedFile $testFilePath $testOutputFile @{ 
            $testToken = $expectedTokenValue;
            $testToken2 = $expectedTokenValue2;
        }
        
        # assert
        It 'Should have created output file' {
            (Test-Path $testOutputFile) | should be $true
        }
        
        It 'Should have created original file with original content' {            
            Get-Content -Raw $testFilePath | should be $originalFileContents
        }
        
        It 'Should have the expected tokens replaced in output file' {
            Get-Content -Raw $testOutputFile | should be $expectedOutput
        }                         
    } 

    Context 'Does not strip trailing newlines or whitespace.' {
        
        $testFilePath = Join-Path $TestDrive 'testFileToReplace.txt'
        $testToken = "@@here is a token@@"
        $testToken2 = "anotherToken for replacement"
        $originalFileContents = "Here is some content and $testToken to be replaced $(([Environment]::NewLine))   $(([Environment]::NewLine))"
        [io.file]::WriteAllText($testFilePath,$originalFileContents)
        $testOutputFile = Join-Path $TestDrive 'result.txt'
        $expectedTokenValue = "some value"
        $expectedTokenValue2 = "the next value 2"            
        $expectedOutput = "Here is some content and $expectedTokenValue to be replaced $(([Environment]::NewLine))   $(([Environment]::NewLine))"
        
        # execute
        Write-TokenReplacedFile $testFilePath $testOutputFile @{ 
            $testToken = $expectedTokenValue;
            $testToken2 = $expectedTokenValue2;
        }
        
        # assert
        It 'Should have created output file' {
            (Test-Path $testOutputFile) | should be $true
        }
        
        It 'Should have created original file with original content' {            
            Get-Content -Raw $testFilePath | should be $originalFileContents
        }
        
        It 'Should have the expected tokens replaced in output file' {
            Get-Content -Raw $testOutputFile | should be $expectedOutput
        }                         
    } 
    
    Context 'Works when no tokens are provided.' {
        
        $testFilePath = Join-Path $TestDrive 'testFileToReplace.txt'
        $testToken = "@@here is a token@@"
        $testToken2 = "anotherToken for replacement"
        $originalFileContents = "Here is some content and $testToken to be replaced $(([Environment]::NewLine)) plus some more content $testToken2 to be replaced too"
        [io.file]::WriteAllText($testFilePath,$originalFileContents)
        $testOutputFile = Join-Path $TestDrive 'result.txt'        
        
        # execute
        Write-TokenReplacedFile $testFilePath $testOutputFile @{}
        
        # assert
        It 'Should have created output file' {
            (Test-Path $testOutputFile) | should be $true
        }
        
        It 'Should have created original file with original content' {            
            Get-Content -Raw $testFilePath | should be $originalFileContents
        }
        
        It 'Should have the expected tokens replaced in output file' {
            Get-Content -Raw $testOutputFile | should be $originalFileContents
        }                         
    } 
               
    Context 'Updates the original file' {

        $testFilePath = Join-Path $TestDrive 'testFileToReplace.txt'
        $testToken = "@@here is a token@@"
        $originalFileContents = "Here is some content and $testToken to be replaced"
        [io.file]::WriteAllText($testFilePath,$originalFileContents)
        $expectedTokenValue = "some value"
        $expectedOutput = "Here is some content and $expectedTokenValue to be replaced"
        
        # execute
        Update-TokenReplacedFile -fileToTokenReplace $testFilePath  -tokenValues @{ $testToken = $expectedTokenValue }
        
        # assert
        It 'Should have updated the original file with replacments' {            
            Get-Content -Raw $testFilePath | should be $expectedOutput
        }
    }
}
