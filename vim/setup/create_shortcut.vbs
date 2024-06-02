Set WshShell = CreateObject("WScript.Shell")

Set Neovide = WshShell.CreateShortcut("./Neovide.lnk")
Neovide.TargetPath = "%DOT_APPS%\_packs\apps\neovide\current\neovide.exe"
Neovide.IconLocation = "%DOT_APPS%\_packs\apps\neovide\current\neovide.exe"
Neovide.Arguments = "--grid=70x20"
Neovide.WorkingDirectory = "%DOT_APPS%\_packs\apps\neovide"
Neovide.Save

Set Nvy = WshShell.CreateShortcut("./Nvy.lnk")
Nvy.TargetPath = "%DOT_APPS%\_packs\apps\nvy\current\Nvy.exe"
Nvy.IconLocation = "%DOT_APPS%\_packs\apps\nvy\current\Nvy.exe"
Nvy.Arguments = "--position=500,200 --geometry=70x20"
Nvy.WorkingDirectory = "%DOT_APPS%\_packs\apps\nvy"
Nvy.Save
