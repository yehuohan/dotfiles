@echo off

set url=%1
set sha512=%2
set dst=%3
echo X-Script.url:    %url%
echo X-Script.dsr:    %sha512%
echo X-Script.sha512: %dst%

set url=%url:https://github.com=https://kkgithub.com%
curl --progress-bar -L %url% --create-dirs --output %dst%
