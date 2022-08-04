Set WshShell = CreateObject("WScript.Shell")
Set Shortcut = WshShell.CreateShortcut("./Neovide.lnk")
Shortcut.TargetPath = "%APPS_HOME%\Neovim\bin\neovide.exe"
Shortcut.IconLocation = "%APPS_HOME%\Neovim\bin\neovide.exe"
Shortcut.Arguments = "--geometry=90x25 --neovim-bin=%APPS_HOME%\Neovim\bin\nvim.exe"
Shortcut.WorkingDirectory = "%APPS_HOME%\Neovim\bin"
ShortCut.Save
