<#
    .DESCRIPTION
        Merges 2 hashtables.  If any duplicate keys, the value of the last hastable is taken
    .EXAMPLE
        $a, $b | Merge-Hashtables 

    .EXAMPLE
        $a | Merge-Hashtables $b $c

    .PARAMETER hashtable

    .NOTES
#>
function Merge-Hashtables {
    $output = @{}
    foreach ($hashtable in ($Input + $Args)) {
        if ($hashtable -is [Hashtable]){
            foreach ($key in $hashtable.Keys) {
                $output.$Key = $hashtable.$key
            }
        }
    }
    $output
}
