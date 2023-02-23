@echo off

mklink    %APPS_HOME%\msys64\home\%USERNAME%\.vim\.init.vim    %APPS_HOME%\dotvim\.init.vim
mklink /D %APPS_HOME%\msys64\home\%USERNAME%\.vim\autoload     %APPS_HOME%\dotvim\autoload
mklink /D %APPS_HOME%\msys64\home\%USERNAME%\.vim\viml         %APPS_HOME%\dotvim\viml
mklink /D %APPS_HOME%\msys64\home\%USERNAME%\.vim\bundle       %APPS_HOME%\dotvim\bundle
mklink /D %APPS_HOME%\msys64\home\%USERNAME%\.vim\snips        %APPS_HOME%\dotvim\snips
REM mklink /D %APPS_HOME%\msys64\home\%USERNAME%\.vim\pythonx      %APPS_HOME%\dotvim\pythonx
REM mklink /D %APPS_HOME%\msys64\home\%USERNAME%\.vim\rplugin      %APPS_HOME%\dotvim\rplugin

echo Dotvim link was made successful!
pause
