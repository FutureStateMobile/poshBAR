$ErrorActionPreference = 'Stop'

Describe "Merge-Hashtables" { 

    function Assert-HashtablesAreEqual 
    {
        param(
            [hashtable] $First,
            [hashtable] $Second,
            [scriptblock] $Assertion = { $args[0] | Should BeExactly $args[1] }
        )

        if ($null -eq $First) { $First = @{}}
        if ($null -eq $Second) { $Second = @{}}

        $First.Count | Should Be $Second.Count

        $First.Keys | % {
            & $Assertion $First[$_] $Second[$_]
        }
    }

    Context "Merges 2 hashtables"  {
        # Setup 
        $first = @{ "one" = "1";"two" = "2"}
        $second = @{ "three" = "3"}

        # Execute 
        $result = ($first, $second | Merge-Hashtables)

        It "should merge 2 hashtables" {
            Assert-HashtablesAreEqual @{"one" = "1"; "two" = "2"; "three" = "3"} $result
        }
    } 

    Context "Merges 2 hashtables with duplicates"  {
        # Setup 
        $first = @{ "one" = "1";"two" = "2"}
        $duplicateKeys = @{ "two" = "new value"; "three" = "3" }

        # Execute 
        $result = ($first, $duplicateKeys | Merge-Hashtables)

        It "should take the second value from the duplicate key" {
            Assert-HashtablesAreEqual @{"one" = "1"; "two" = "new value"; "three" = "3"} $result
        }
    } 

}
