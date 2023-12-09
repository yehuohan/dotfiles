@echo off

REM Usage:
REM     cmd /k vcpkg_xscript.bat {url} {dst}

set url=%1
set dst=%2
set sha512=%3
echo X-Script.url:    %url%
echo X-Script.dst:    %dst%
echo X-Script.sha512: %sha512%

set url=%url:https://github.com=https://<mirror>%
curl --progress-bar -L %url% --create-dirs --output %dst%
