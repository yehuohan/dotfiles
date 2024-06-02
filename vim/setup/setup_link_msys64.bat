@echo off

for %%i in ("%~dp0\..\") do set DIR_VIM=%%~dpi

echo DIR_VIM: %DIR_VIM%

copy %DIR_VIM%\gvim\.vimrc %DOT_APPS%\msys64\home\%USERNAME%\
md %DOT_APPS%\msys64\home\%USERNAME%\dotvim
mklink /D %DOT_APPS%\msys64\home\%USERNAME%\dotvim\autoload    %DOT_HOME%\dotvim\autoload
mklink /D %DOT_APPS%\msys64\home\%USERNAME%\dotvim\bundle      %DOT_HOME%\dotvim\bundle
mklink /D %DOT_APPS%\msys64\home\%USERNAME%\dotvim\init        %DOT_HOME%\dotvim\init
mklink /D %DOT_APPS%\msys64\home\%USERNAME%\dotvim\share       %DOT_HOME%\dotvim\share

echo Dotvim link was made successful!
pause
