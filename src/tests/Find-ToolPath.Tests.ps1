$ErrorActionPreference = 'Stop'

Describe 'Find Tool Path' { 
    
    # Setup
    BeforeEach {
        $originalPath = $env:PATH
    }
    
    # Teardown
    AfterEach {
        $env:PATH = $originalPath
    }
    
    Context 'Will handle a valid tool.'{
        # setup
        $toolName = 'mage'
       
        # execute
        $execute = {Find-ToolPath $toolName} 
        $result = & $execute
        
        # assert
        It 'Should not thow for a valid tool.' {
            $execute | should not throw
        }
        
        It 'Should execute the tool and not throw an exception.' {
           {. $toolName -h} | should not throw 
        }
    }
    
    Context 'Will handle Mocked tool on PATH' { 
        # Setup 
        $toolName = 'mock'
        $mockToolPath = 'C:\Temp\Mock'
        $env:PATH += ";$mockToolPath"
             
        # execute
        $result = Find-ToolPath $toolName  
       
       # assert         
        It 'Should find a mock tool on the path and not throw.' {
            $result | should be $mockToolPath
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