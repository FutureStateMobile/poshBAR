$ErrorActionPreference = "Stop"
    
Describe "Find-ToolPath" {
    It "Will find the mage tool." {
        {Find-ToolPath 'mage'} | should not throw
    }
}


Describe "Find-ToolPath" {
    It "Will throw on invalid tool" {
        {Find-ToolPath 'Foo' | should throw}
    }
}