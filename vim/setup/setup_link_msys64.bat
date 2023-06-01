@echo off

mklink /D %APPS_HOME%\msys64\home\%USERNAME%\.vim\autoload      %APPS_HOME%\dotvim\autoload
mklink /D %APPS_HOME%\msys64\home\%USERNAME%\.vim\bundle        %APPS_HOME%\dotvim\bundle
mklink /D %APPS_HOME%\msys64\home\%USERNAME%\.vim\init          %APPS_HOME%\dotvim\init
mklink /D %APPS_HOME%\msys64\home\%USERNAME%\.vim\snips         %APPS_HOME%\dotvim\snips
mklink /D %APPS_HOME%\msys64\home\%USERNAME%\.vim\misc          %APPS_HOME%\dotvim\misc
REM mklink /D %APPS_HOME%\msys64\home\%USERNAME%\.vim\pythonx       %APPS_HOME%\dotvim\pythonx
REM mklink /D %APPS_HOME%\msys64\home\%USERNAME%\.vim\rplugin       %APPS_HOME%\dotvim\rplugin

echo Dotvim link was made successful!
pause
