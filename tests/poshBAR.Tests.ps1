$ErrorActionPreference = 'Stop'

Describe 'poshBAR module tests' {

    Context 'Will ensure the version and build number were properly updated during the build.' {
        # setup
        # execute
        # assert
        It 'Should have a matching version number' {
            $poshBAR.version | should be $version
        }
        
        It 'Should have a matching build number' {
            $poshBAR.buildNumber | should be $buildNumber
        }
    }

    Context 'Will export messages for external use (IE: tests).' {
        # setup
        $testMessage = 'This is a test.'
            
        # execute
        # assert
        It 'Should not have a null message object.' {
            $poshBAR.msgs | should not be $null
        }
        
        It 'Should have a "Test Message" string, proving that the $msgs object is working as expected.' {
            $poshBAR.msgs.test_message | should be $testMessage
        }
    }
} 