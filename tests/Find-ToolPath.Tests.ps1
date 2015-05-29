$ErrorActionPreference = "Stop"
    
Describe "Find-ToolPath" { 
    Context "Handle a valid tool."{
        # setup
        $toolName = 'mage'
            
        # assert
        It "Will not thow for a valid tool." {
            {Find-ToolPath $toolName} | should not throw
        }
        
        # assert
        It "Will execute the tool and not throw an exception." {
           {. $toolName -h} | should not throw 
        }
    }
    
    Context "Handle an invalid tool." {
        # setup
        $toolName = 'Foo'

        # assert
        It "Will throw on an invalid tool." {
            {Find-ToolPath $toolName} | should throw
        }

        # assert
        It "Will throw an exception when attempting to execute an invalid tool." {
            {. $toolName -h} | should throw 
        }
    }
}