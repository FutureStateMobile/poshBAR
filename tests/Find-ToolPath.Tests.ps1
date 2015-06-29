$ErrorActionPreference = 'Stop'
$here = Split-Path $script:MyInvocation.MyCommand.Path
Describe 'Find-ToolPath' { 
    Context 'Handle a valid tool.'{
        # setup
        $toolName = 'mage'
       
        # execute
        $execute = {Find-ToolPath $toolName} 
        $result = & $execute
        
        # assert
        It 'Will not thow for a valid tool.' {
            $execute | should not throw
        }
        
        It 'Will execute the tool and not throw an exception.' {
           {. $toolName -h} | should not throw 
        }
    }
    
    Context 'Handle Mocked tool on PATH' { 
        # Setup 
        $orig = $env:PATH
        $toolName = 'mock'
        $mockToolPath = 'C:\Temp\Mock'
        $env:PATH += ";$mockToolPath"
             
        # execute
        $result = Find-ToolPath $toolName  
       
       # assert         
        It 'Will find a mock tool on the path and not throw.' {
            $result | should be $mockToolPath
        }
        
        # tear down
        $env:PATH = $orig
    }
    
    Context 'Handle an invalid tool.' {
        # setup
        $toolName = 'Foo'
            
        # execute
        $execute = {$badResult = Find-ToolPath $toolName}

        # assert
        It 'Will throw on an invalid tool.' {
            $execute | should throw
        }

        It 'Will throw an exception when attempting to execute an invalid tool.' {
            {. $toolName -h} | should throw 
        }
        
        It 'Will have an empty string on the result.' {
            $badResult | should be $null
        }
    }
}