
### Setup home
$dir_disk = Get-Location
$dir_disk = Split-Path -Path $dir_disk -Parent
echo "dir_disk = $dir_disk"
echo "USERPROFILE = $env:USERPROFILE"
Copy-Item -Path "$dir_disk/home/*" -Destination "$env:USERPROFILE" -Recurse -Force

### Setup msys2
$dot_apps = Get-ItemPropertyValue -Path HKCU:\Environment -Name DOT_APPS -ErrorAction SilentlyContinue
if (!$dot_apps) {
    write-host "Require DOT_APPS"
    pause
    exit
}
$dot_apps = $dot_apps -replace '\\', '\\'

$cmd_add = @'
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\background\shell\Msys2]
@="Msys2 Here"
"Icon"="\"{0}\\msys64\\ucrt64.exe\""

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\background\shell\Msys2\command]
@="\"{0}\\msys64\\msys2_shell.cmd\" -ucrt64 -here"
'@ -f $dot_apps

$cmd_del = @'
Windows Registry Editor Version 5.00

[-HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\background\shell\Msys2]
'@

echo 'Generated msys2_here.reg'
[IO.File]::WriteAllText("$dir_disk/setup/msys2_here.reg", $cmd_add, [Text.Encoding]::UTF8)
echo 'Generated msys2_here.del.reg'
[IO.File]::WriteAllText("$dir_disk/setup/msys2_here.del.reg", $cmd_del, [Text.Encoding]::UTF8)
pause