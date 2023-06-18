Set WshShell = CreateObject("WScript.Shell")
Set Shortcut = WshShell.CreateShortcut("./Neovide.lnk")
Shortcut.TargetPath = "%APPS_HOME%\_packs\apps\neovide\current\neovide.exe"
Shortcut.IconLocation = "%APPS_HOME%\_packs\apps\neovide\current\neovide.exe"
Shortcut.Arguments = "--geometry=90x25"
Shortcut.WorkingDirectory = "%APPS_HOME%\_packs\apps\neovide"
ShortCut.Save
