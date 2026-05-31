
# Unlock this script first
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Chord Alt+j -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord Alt+k -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Chord Alt+n -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord Alt+m -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function Complete

Set-PSReadLineKeyHandler -Chord Alt+l -Function ForwardChar
Set-PSReadLineKeyHandler -Chord Alt+h -Function BackwardChar
Set-PSReadLineKeyHandler -Chord Alt+o -Function ForwardWord
Set-PSReadLineKeyHandler -Chord Alt+i -Function BackwardWord
Set-PSReadLineKeyHandler -Chord Alt+u -Function BeginningOfLine
Set-PSReadLineKeyHandler -Chord Alt+p -Function EndOfLine

Set-PSReadLineKeyHandler -Chord Alt+g -Function DeleteChar
Set-PSReadLineKeyHandler -Chord Alt+s -Function BackwardDeleteChar
Set-PSReadLineKeyHandler -Chord Alt+f -Function KillWord
Set-PSReadLineKeyHandler -Chord Alt+d -Function BackwardKillWord
Set-PSReadLineKeyHandler -Chord Alt+Backspace -Function BackwardKillWord

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
