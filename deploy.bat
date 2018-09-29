@echo off
title Compiling PipView

call clean.bat

brcc32 resource.rc
brcc32 stringtable.rc
dcc32 pipview.dpr
reshacker -script pipview_rh.ini
REM upx --best --compress-icons=0 --crp-ms=999999 binaries\pipview.exe
REM hhc help\pipview.hhp
REM makensis nsis\pipview.nsi
