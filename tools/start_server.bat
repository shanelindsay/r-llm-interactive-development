@echo off
rem Simple batch file to start the R server
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0rserver.ps1" start
pause 