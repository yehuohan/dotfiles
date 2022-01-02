@echo off

if not %APPS_HOME%\dotconfigs\vim\setup == %cd% (
    echo Is NOT in %APPS_HOME%\dotconfigs\vim\setup
    pause
    exit
)

:: .vim
if not exist %APPS_HOME%\dotvim (
    md %APPS_HOME%\dotvim
)
xcopy %APPS_HOME%\dotconfigs\vim\.vim           %APPS_HOME%\dotvim\ /E /R /Y

:: nvim
if not exist %LOCALAPPDATA%\nvim (
    md %LOCALAPPDATA%\nvim
)
copy %APPS_HOME%\dotconfigs\vim\nvim\init.vim   %LOCALAPPDATA%\nvim\
REM copy %APPS_HOME%\dotconfigs\vim\nvim\init.lua   %LOCALAPPDATA%\nvim\

echo Dotvim setup was completed!
pause
