@echo off

for %%i in ("%~dp0\..\") do set DIR_VIM=%%~dpi
set DIR_DOT=%APPS_HOME%\dotvim
:: set InitFile=init.lua
set InitFile=init.vim

echo DIR_VIM: %DIR_VIM%
echo DIR_DOT: %DIR_DOT%
echo Init file: %InitFile%

:: check APPS_HOME
if not defined APPS_HOME (
    echo ERROR: "APPS_HOME" is not set
    pause
    exit
)

:: check DIR_VIM
if not exist %DIR_VIM%\.vim (
    echo ERROR: "%DIR_VIM%\.vim" is not existed
    pause
    exit
)
if not exist %DIR_VIM%\nvim\%InitFile% (
    echo ERROR: "%DIR_VIM%\nvim\%InitFile%" is not existed
    pause
    exit
)

:: copy .vim
if not exist %DIR_DOT% (
    md %DIR_DOT%
)
xcopy %DIR_VIM%\.vim %DIR_DOT%\ /E /R /Y

:: copy nvim
if not exist %LOCALAPPDATA%\nvim (
    md %LOCALAPPDATA%\nvim
)
copy %DIR_VIM%\nvim\%InitFile%  %LOCALAPPDATA%\nvim\

echo Dotvim setup was completed!
pause
