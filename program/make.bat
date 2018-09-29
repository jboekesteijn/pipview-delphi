@echo off

REM %% Ga naar de directory met delphi-sources
cd src\

REM %% Compileer de resources
brcc32 -foResource.res Resource.rc

REM %% Compileer PipView zelf
dcc32 pipview.dpr

REM %% Terug naar homedirectory
cd ..

REM %% Ruim overbodige resources op uit pipview.exe
reshacker -script pipview_rh.ini
