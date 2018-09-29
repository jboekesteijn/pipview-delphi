@echo off

SET LIBPATH=F:\Program Files\Borland\Delphi7\Lib

if exist *.res del *.res
if exist *.dcu del *.dcu
if exist *.ddp del *.ddp

if exist nsis\binaries\*.exe del nsis\binaries\*.exe
if exist binaries\pipview.* del binaries\pipview.*
if exist binaries\*.html del binaries\*.html

if exist "%LIBPATH%\Jwa\*.dcu" del "%LIBPATH%\Jwa\*.dcu"
if exist "%LIBPATH%\Mime\*.dcu" del "%LIBPATH%\Mime\*.dcu"
if exist "%LIBPATH%\NoScrollListview\*.dcu" del "%LIBPATH%\NoScrollListview\*.dcu"
if exist "%LIBPATH%\RegExpr\*.dcu" del "%LIBPATH%\RegExpr\*.dcu"
if exist "%LIBPATH%\Cooltray\*.dcu" del "%LIBPATH%\Cooltray\*.dcu"
if exist "%LIBPATH%\Balloon\*.dcu" del "%LIBPATH%\Balloon\*.dcu"
