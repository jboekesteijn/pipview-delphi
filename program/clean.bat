@echo off

REM %% Verwijder gecompileerde resource-bestanden, gecompileerde
REM %% source-files (dcu) en overbodige bestanden die door de
REM %% Delphi IDE kunnen zijn gemaakt
if exist src\*.res del src\*.res
if exist src\*.dcu del src\*.dcu
if exist src\*.identcache del src\*.identcache

REM %% Verwijder het programmabestand
if exist bin\pipview.exe del bin\pipview.exe
