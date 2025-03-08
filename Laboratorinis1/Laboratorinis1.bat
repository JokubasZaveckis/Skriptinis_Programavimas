@echo off
setlocal

rem === Jei neduoti parametrai, ima user folderi ir .bat failus ===
if "%~1"=="" (
    set "folder=%USERPROFILE%"
) else (
    set "folder=%~1"
)
if "%~2"=="" (
    set "ext=.bat"
) else (
    set "ext=%~2"
)

rem === Nustatome, kur bus saugomas log failas ===
set "logfile=%~dp0filelist.log"

rem === Paraso laika ir data ===
echo %DATE% > "%logfile%"
echo %TIME% >> "%logfile%"

rem === Rekursiskai eina per visus failus ===
rem Paraso fisus path, kur randa tinkama faila
for /R "%folder%" %%F in (*%ext%) do (
    echo %%~nxF >> "%logfile%"
    echo %%~dpF >> "%logfile%"
)

rem === Atidaro nauja faila notepad ===
start notepad "%logfile%"

rem === Laukia betkokio user input ===
pause

rem === Kai gauna input, isjungia notepad ===
taskkill /IM notepad.exe /F

rem === Istrina nauja log file ===
del "%logfile%"

endlocal
exit
