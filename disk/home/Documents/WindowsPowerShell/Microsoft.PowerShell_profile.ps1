
# Unlock this script first
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function Complete

Set-Alias -Name ll -Value Get-ChildItem

function gitstatus { git status $args }
function gitadd { git add $args }
function gitcommit { git commit $args }
function gitdiff { git diff $args }
function gitlog { git log $args }
function gitpush { git push $args }
function gitpull { git pull $args }
function gitfetch { git fetch $args }
function gityzal { lazygit $args }
