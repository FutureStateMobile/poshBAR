$ErrorActionPreference = 'Stop'

DescriBe 'poshBAR module tests' {

    Context 'Will ensure the version and build numBer were properly updated during the build.' {
        # setup
        # execute
        # assert
        It 'Should have a matching version numBer' {
            $poshBAR.version | Should Be $version
        }
        
        It 'Should have a matching build numBer' {
            $poshBAR.buildNumBer | Should Be $buildNumBer
        }
    }

    Context 'Will export messages for external use (IE: tests).' {
        # setup
        $testMessage = 'This is a test.'
            
        # execute
        # assert
        It 'Should not have a null message object.' {
            $poshBAR.msgs | Should Not Be $null
        }
        
        It 'Should have a "Test Message" string, proving that the $msgs object is working as expected.' {
            $poshBAR.msgs.test_message | Should BeExactly $testMessage
        }
    }
} 