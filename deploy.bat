@echo off

REM %% Ruim alle bestanden van een oudere versie op
call clean.bat

REM %% Ga naar de directory met delphi-sources
cd .\source\delphi\

REM %% Compileer de resources
brcc32 resource.rc

REM %% Compileer PipView zelf
dcc32 pipview.dpr

REM %% Ga terug naar de homedirectory
cd .\..\..

REM %% Ruim overbodige resources op uit pipview.exe
reshacker -script pipview_rh.ini

REM %% Pak het programmabestand van PipView in
upx --best --compress-icons=0 --crp-ms=999999 .\binaries\pipview.exe

REM %% Compileer de html-files in een CHM-files
hhc .\source\help\pipview.hhp

REM %% Maak het installatieprogramma aan
makensis .\source\installer\pipview.nsi
