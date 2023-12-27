Set WshShell = CreateObject("WScript.Shell")

Set Neovide = WshShell.CreateShortcut("./Neovide.lnk")
Neovide.TargetPath = "%APPS_HOME%\_packs\apps\neovide\current\neovide.exe"
Neovide.IconLocation = "%APPS_HOME%\_packs\apps\neovide\current\neovide.exe"
Neovide.Arguments = "--grid=70x20"
Neovide.WorkingDirectory = "%APPS_HOME%\_packs\apps\neovide"
Neovide.Save

Set Nvy = WshShell.CreateShortcut("./Nvy.lnk")
Nvy.TargetPath = "%APPS_HOME%\_packs\apps\nvy\current\Nvy.exe"
Nvy.IconLocation = "%APPS_HOME%\_packs\apps\nvy\current\Nvy.exe"
Nvy.Arguments = "--position=500,200 --geometry=70x20"
Nvy.WorkingDirectory = "%APPS_HOME%\_packs\apps\nvy"
Nvy.Save
