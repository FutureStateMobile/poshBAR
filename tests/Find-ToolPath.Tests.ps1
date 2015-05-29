$ErrorActionPreference = 'Stop'
    
Describe 'Find-ToolPath' { 
    Context 'Handle a valid tool.'{
        # setup
        $toolName = 'mage'
        
        
        # execute
        $execute = {$result = Find-ToolPath $toolName} 
            
        # assert
        It 'Will not thow for a valid tool.' {
            $execute | should not throw
        }
        
        It 'Will execute the tool and not throw an exception.' {
           {. $toolName -h} | should not throw 
        }
        
        It 'Will have a valid path on the result.' {
            $result | should not be ''
        }
    }
    
    Context 'Handle an invalid tool.' {
        # setup
        $toolName = 'Foo'
            
        # execute
        $execute = {$result = Find-ToolPath $toolName}

        # assert
        It 'Will throw on an invalid tool.' {
            $execute | should throw
        }

        It 'Will throw an exception when attempting to execute an invalid tool.' {
            {. $toolName -h} | should throw 
        }
        
        It 'Will have an empty string on the result.' {
            $result | should be $null
        }
    }
}