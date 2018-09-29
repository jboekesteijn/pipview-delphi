@echo off

REM %% Compileer de installer
makensis src\pipview.nsi

REM cd bin
REM 7z a -mx=9 setup.7z setup.exe
REM copy /b 7zSD.sfx + setup.7z pipview-10-setup.exe
REM cd ..
