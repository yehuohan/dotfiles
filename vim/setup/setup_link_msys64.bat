@echo off

for %%i in ("%~dp0\..\") do set DIR_VIM=%%~dpi

echo DIR_VIM: %DIR_VIM%

copy %DIR_VIM%\gvim\.vimrc %APPS_HOME%\msys64\home\%USERNAME%\
md %APPS_HOME%\msys64\home\%USERNAME%\dotvim
mklink /D %APPS_HOME%\msys64\home\%USERNAME%\dotvim\autoload    %APPS_HOME%\dotvim\autoload
mklink /D %APPS_HOME%\msys64\home\%USERNAME%\dotvim\bundle      %APPS_HOME%\dotvim\bundle
mklink /D %APPS_HOME%\msys64\home\%USERNAME%\dotvim\init        %APPS_HOME%\dotvim\init
mklink /D %APPS_HOME%\msys64\home\%USERNAME%\dotvim\share       %APPS_HOME%\dotvim\share

echo Dotvim link was made successful!
pause
