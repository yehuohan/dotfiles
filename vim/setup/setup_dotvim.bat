@echo off

for %%i in ("%~dp0\..\") do set DIR_VIM=%%~dpi
set DIR_DOT=%DOT_HOME%\dotvim
set InitFile=init.lua
REM set InitFile=init.vim

echo DIR_VIM: %DIR_VIM%
echo DIR_DOT: %DIR_DOT%
echo Init file: %InitFile%

REM check DOT_HOME
if not defined DOT_HOME (
    echo ERROR: "DOT_HOME" is not set
    pause
    exit
)

REM check DIR_VIM
if not exist %DIR_VIM%\dotvim (
    echo ERROR: "%DIR_VIM%\dotvim" is not existed
    pause
    exit
)
if not exist %DIR_VIM%\nvim\%InitFile% (
    echo ERROR: "%DIR_VIM%\nvim\%InitFile%" is not existed
    pause
    exit
)

REM copy dotvim
if not exist %DIR_DOT% (
    md %DIR_DOT%
)
xcopy %DIR_VIM%\dotvim              %DIR_DOT%\ /E /R /Y

REM copy nvim
if not exist %LOCALAPPDATA%\nvim (
    md %LOCALAPPDATA%\nvim
)
copy %DIR_VIM%\nvim\%InitFile%      %LOCALAPPDATA%\nvim\

echo Dotvim setup was completed!
pause
