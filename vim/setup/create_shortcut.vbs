Set WshShell = CreateObject("WScript.Shell")
Set Shortcut = WshShell.CreateShortcut("./Neovide.lnk")
Shortcut.TargetPath = "%APPS_HOME%\_packs\apps\neovide\current\neovide.exe"
Shortcut.IconLocation = "%APPS_HOME%\_packs\apps\neovide\current\neovide.exe"
Shortcut.Arguments = "--geometry=70x20"
Shortcut.WorkingDirectory = "%APPS_HOME%\_packs\apps\neovide"
ShortCut.Save
