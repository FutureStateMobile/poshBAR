$ErrorActionPreference = 'Stop'

Describe 'Find Tool Path' { 
    
    $testPath = "C:\temp\mock"
    # Setup
    BeforeEach {
        $originalPath = $env:PATH
        if (Test-Path $testPath){
            Remove-Item -Path $testPath -ErrorAction SilentlyContinue
        }
    }
    
    # Teardown
    AfterEach {
        $env:PATH = $originalPath
        if (Test-Path $testPath){
            Remove-Item -Path $testPath
        }
    }

    Context 'Will handle a valid tool.'{
        # setup
        $toolName = 'mage.exe'
       
        # execute
        $execute = Find-ToolPath $toolName 
       
        # assert
        It 'Should execute the tool and not throw an exception.' {
           {. $toolName -h} | should not throw 
        }
    }

    Context 'Will include an path' { 
        # Setup 
        $toolName = 'mock'
        mkdir $testPath
        $env:PATH += ";$testPath"
             
        # execute
        $result = Find-ToolPath $toolName  
       
       # assert         
        It 'Should find a mock tool on the path and not throw.' {
            $result | should be $testPath
        }
    }
    
    Context 'Will not include a non-exist path' { 
        # Setup 
        $toolName = 'mock'
        $env:PATH += ";$testPath"
             
        # execute
        $execute = {$badResult = Find-ToolPath $toolName}

        It 'Should throw on an invalid tool.' {
            $execute | should throw
        }
    }
   
    Context 'Will handle tool with exe extension on PATH' { 
        # Setup 
        $toolName = 'mock.exe'
        mkdir $testPath
        $env:PATH += ";$testPath"
             
        # execute
        $result = Find-ToolPath $toolName  
       
       # assert         
        It 'Should find a mock.exe tool on the path and not throw.' {
            $result | should be $testPath
        }
    }

    Context 'Will handle an invalid tool.' {
        # setup
        $toolName = 'Foo'
            
        # execute
        $execute = {$badResult = Find-ToolPath $toolName}

        # assert
        It 'Should throw on an invalid tool.' {
            $execute | should throw
        }

        It 'Should throw an exception when attempting to execute an invalid tool.' {
            {. $toolName -h} | should throw 
        }
        
        It 'Should have an empty string on the result.' {
            $badResult | should be $null
        }
    }
}
