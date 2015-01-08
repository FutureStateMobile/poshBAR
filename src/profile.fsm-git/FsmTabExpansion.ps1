Copy Function:\TabExpansion Function:\OriginalTabExpansion
function TabExpansion($line, $lastWord) {
  $LineBlocks = [regex]::Split($line, '[|;]')
  $lastBlock = $LineBlocks[-1] 

  switch -regex ($lastBlock) {
    #Depends on Posh-Git
    "^$(Get-AliasPattern "mfb|mtb|rb|db|ub|urb|co|pull|diff") (.*)" { gitTabExpansion $lastBlock }
    default { if (Test-Path Function:\OriginalTabExpansion) { OriginalTabExpansion $line $lastWord } }
  }
}

function gitTabExpansion($lastBlock) {
     switch -regex ($lastBlock) {
 
        "^diff.* (?<files>\S*)$$" { gitDiffFiles $matches['files'] $false}
        "^(?:mfb|mtb|rb|db|ub|urb|co|pull).* (?<cmd>\S*)$" { gitBranches $matches['cmd'] $true }
    }   
}

# Gets local and remote branches
function script:gitBranches($filter, $includeHEAD = $false) {
    $prefix = $null
    if ($filter -match "^(?<from>\S*\.{2,3})(?<to>.*)") {
        $prefix = $matches['from']
        $filter = $matches['to']
    }
    $branches = @(git branch --no-color | % { if($_ -match "^\*?\s*(?<ref>.*)") { $matches['ref'] } }) +
                @(git branch --no-color -r | % { if($_ -match "^  (?<ref>\S+)(?: -> .+)?") { $matches['ref'] } }) +
                @(if ($includeHEAD) { 'HEAD','FETCH_HEAD','ORIG_HEAD','MERGE_HEAD' })
    $branches |
        where { $_ -ne '(no branch)' -and $_ -like "$filter*" } |
        % { $prefix + $_ }
}

# Gets local modified files (Working Unmerged, Working Modified, Index Modified)
function script:gitDiffFiles($filter, $staged) {
    if ($staged) {
        gitFiles $filter $GitStatus.Index.Modified
    } else {
        gitFiles $filter (@($GitStatus.Working.Unmerged) + @($GitStatus.Working.Modified) + @($GitStatus.Index.Modified))
    }
}











# ==================== [ Helpers ] ====================

# Helper for gitDiffFiles
function script:gitFiles($filter, $files) {
    $files | sort |
        where { $_ -like "$filter*" } |
        foreach { if($_ -like '* *') { "'$_'" } else { $_ } }
}