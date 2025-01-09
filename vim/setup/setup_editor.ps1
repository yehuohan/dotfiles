
$dir_vim = Get-Location
$dir_vim = Split-Path -Path $dir_vim -Parent
echo "dir_vim = $dir_vim"

### Setup editor
$dot_apps = Get-ItemPropertyValue -Path HKCU:\Environment -Name DOT_APPS -ErrorAction SilentlyContinue
if (!$dot_apps) {
    write-host "Require DOT_APPS"
    pause
    exit
}

$ws_shell = New-Object -ComObject ("WScript.Shell")
$sc_neovide = $ws_shell.CreateShortcut("$dir_vim/setup/Neovide.lnk")
$sc_neovide.TargetPath = "$dot_apps\_packs\apps\neovide\current\neovide.exe"
$sc_neovide.IconLocation = "$dot_apps\_packs\apps\neovide\current\neovide.exe"
$sc_neovide.Arguments = "--grid=70x20"
$sc_neovide.WorkingDirectory = "$dot_apps\_packs\apps\neovide"
$sc_neovide.Save()
$sc_nvy = $ws_shell.CreateShortcut("$dir_vim/setup/Nvy.lnk")
$sc_nvy.TargetPath = "$dot_apps\_packs\apps\nvy\current\Nvy.exe"
$sc_nvy.IconLocation = "$dot_apps\_packs\apps\nvy\current\Nvy.exe"
$sc_nvy.Arguments = "--position=500,200 --geometry=70x20"
$sc_nvy.WorkingDirectory = "$dot_apps\_packs\apps\nvy"
$sc_nvy.Save()

$dot_apps = $dot_apps -replace '\\', '\\'
$editors = @(
    @{
        Name = 'edit_with_neovim.reg';
        Text = @'
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\*\Shell\Neovim]
@="Edit with &Neovim"
"Icon"="\"{0}\\_packs\\apps\\neovim-qt\\current\\bin\\nvim-qt.exe\""

[HKEY_CLASSES_ROOT\*\Shell\Neovim\command]
@="\"{0}\\_packs\\apps\\neovim-qt\\current\\bin\\nvim-qt.exe\" \"%1\""
'@ -f $dot_apps;
    },
    @{
        Name = 'edit_with_neovim.del.reg';
        Text = @'
Windows Registry Editor Version 5.00

[-HKEY_CLASSES_ROOT\*\Shell\Neovim]
'@
    },
    @{
        Name = 'edit_with_neovide.reg';
        Text = @'
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\*\Shell\Neovide]
@="Edit with &Neovide"
"Icon"="\"{0}\\_packs\\apps\\neovide\\current\\neovide.exe\""

[HKEY_CLASSES_ROOT\*\Shell\Neovide\command]
@="\"{0}\\_packs\\apps\\neovide\\current\\neovide.exe\" --grid=70x20 \"%1\""
'@ -f $dot_apps;
    },
    @{
        Name = 'edit_with_neovide.del.reg';
        Text = @'
Windows Registry Editor Version 5.00

[-HKEY_CLASSES_ROOT\*\Shell\Neovide]
'@
    }
    @{
        Name = 'edit_with_nvy.reg';
        Text = @'
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\*\Shell\Nvy]
@="Edit with &Nvy"
"Icon"="\"{0}\\_packs\\apps\\nvy\\current\\Nvy.exe\""

[HKEY_CLASSES_ROOT\*\Shell\Nvy\command]
@="\"{0}\\_packs\\apps\\nvy\\current\\Nvy.exe\" --position=500,200 --geometry=70x20 \"%1\""
'@ -f $dot_apps;
    },
    @{
        Name = 'edit_with_nvy.del.reg';
        Text = @'
Windows Registry Editor Version 5.00

[-HKEY_CLASSES_ROOT\*\Shell\Nvy]
'@
    }
)

foreach ($editor in $editors) {
    echo ('Generated ' + $editor.Name)
    $editor.Text | Out-File -FilePath ("$dir_vim/setup/" + $editor.Name)
}
