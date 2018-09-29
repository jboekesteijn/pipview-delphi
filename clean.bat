@echo off

SET LIBPATH=F:\Program Files\Borland\Delphi7\Lib

REM %% Verwijder gecompileerde resource-bestanden, gecompileerde
REM %% source-files (dcu) en overbodige bestanden die door de
REM %% Delphi IDE kunnen zijn gemaakt (ddp)
if exist source\delphi\*.res del source\delphi\*.res
if exist source\delphi\*.dcu del source\delphi\*.dcu
if exist source\delphi\*.ddp del source\delphi\*.ddp

REM %% Verwijder het installatieprogramma en
REM %% het programmabestand + helpbestand
if exist binaries\*.exe del binaries\*.exe
if exist binaries\*.html del binaries\*.html
if exist binaries\pipview.chm del binaries\pipview.chm

REM %% Zorg er voor dat alle dcu-bestanden worden verwijderd zodat alle
REM %% code gegarandeerd is gecompileerd vanaf de nieuwe source-files
if exist "%LIBPATH%\Jwa\*.dcu"              del "%LIBPATH%\Jwa\*.dcu"
if exist "%LIBPATH%\Mime\*.dcu"             del "%LIBPATH%\Mime\*.dcu"
if exist "%LIBPATH%\NoScrollListview\*.dcu" del "%LIBPATH%\NoScrollListview\*.dcu"
if exist "%LIBPATH%\RegExpr\*.dcu"          del "%LIBPATH%\RegExpr\*.dcu"
if exist "%LIBPATH%\Cooltray\*.dcu"         del "%LIBPATH%\Cooltray\*.dcu"
if exist "%LIBPATH%\Balloon\*.dcu"          del "%LIBPATH%\Balloon\*.dcu"
