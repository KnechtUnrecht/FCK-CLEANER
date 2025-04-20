@echo off
chcp 65001 >nul
title [ F$CK ⚡ – File System Cleaner Kit v1.2 ]
color 0A
mode con: cols=100 lines=50

setlocal EnableDelayedExpansion
set "VERSION=1.2"
set "SCRIPT_PATH=%~f0"
set "SCRIPT_DIR=%~dp0"
set "LOG_FILE=%SCRIPT_DIR%F$CK_LOG.txt"
set "HISTORY_FILE=%SCRIPT_DIR%F$CK_HISTORY.log"
set "ARCHIVE_DIR=%APPDATA%\F$CK-Archive"
set /a FUP_COUNT=0
set "UPDATE_URL=https://raw.githubusercontent.com/KnechtUnrecht/FCK-CLEANER/main/F$CK.bat"
set "UPDATE_TEMP=%TEMP%\F$CK_UPDATE.bat"
set "QUICK=0"

:: ──────────────── QUICK MODE CHECK ────────────────
if /i "%1"=="/quick" set QUICK=1

:: ──────────────── ASCII HEADER ────────────────
echo.
echo.                             $$$$$                                               
echo.                             $:::$                                               
echo. FFFFFFFFFFFFFFFFFFFFFF   $$$$$:::$$$$$$         CCCCCCCCCCCCCKKKKKKKKK    KKKKKKK
echo. F::::::::::::::::::::F $$::::::::::::::$     CCC::::::::::::CK:::::::K    K:::::K
echo. F::::::::::::::::::::F$:::::$$$$$$$::::$   CC:::::::::::::::CK:::::::K    K:::::K
echo. FF::::::FFFFFFFFF::::F$::::$       $$$$$  C:::::CCCCCCCC::::CK:::::::K   K::::::K
echo.   F:::::F       FFFFFF$::::$             C:::::C       CCCCCCKK::::::K  K:::::KKK
echo.   F:::::F             $::::$            C:::::C                K:::::K K:::::K   
echo.   F::::::FFFFFFFFFF   $:::::$$$$$$$$$   C:::::C                K::::::K:::::K    
echo.   F:::::::::::::::F    $$::::::::::::$$ C:::::C                K:::::::::::K     
echo.   F:::::::::::::::F      $$$$$$$$$:::::$C:::::C                K:::::::::::K     
echo.   F::::::FFFFFFFFFF               $::::$C:::::C                K::::::K:::::K    
echo.   F:::::F                         $::::$C:::::C                K:::::K K:::::K   
echo.   F:::::F             $$$$$       $::::$ C:::::C       CCCCCCKK::::::K  K:::::KKK
echo. FF:::::::FF           $::::$$$$$$$:::::$  C:::::CCCCCCCC::::CK:::::::K   K::::::K
echo. F::::::::FF           $::::::::::::::$$    CC:::::::::::::::CK:::::::K    K:::::K
echo. F::::::::FF            $$$$$$:::$$$$$        CCC::::::::::::CK:::::::K    K:::::K
echo. FFFFFFFFFFF                 $:::$               CCCCCCCCCCCCCKKKKKKKKK    KKKKKKK
echo.                             $$$$$                                               
echo.
echo.               🧼 F$CK YOUR SYSTEM CLEAN v1.2 🧼
echo.

:: ──────────────── LOG INIT ────────────────
echo [%date% %time%] Session start. >> "%LOG_FILE%"
echo [%date% %time%] I am watching you, %USERNAME%. >> "%LOG_FILE%"

:: ──────────────── PROCESS KILL ────────────────
choice /m "Do you want to kill Chrome and Firefox to clean cache?"
if errorlevel 1 (
    for %%P in (chrome.exe firefox.exe msedge.exe) do (
        taskkill /f /im %%P >nul 2>&1
    )
)

:: ──────────────── CLEANING PATHS ────────────────
set i=0
set paths[!i!]=%TEMP% & set /a i+=1
set paths[!i!]=%SystemRoot%\Temp & set /a i+=1
set paths[!i!]=%UserProfile%\AppData\Local\Temp & set /a i+=1
set paths[!i!]=%LocalAppData%\Google\Chrome\User Data\Default\Cache & set /a i+=1
set paths[!i!]=%AppData%\Mozilla\Firefox\Profiles\ & set /a i+=1
if !QUICK!==0 (
    set paths[!i!]=%UserProfile%\Downloads & set /a i+=1
    set paths[!i!]=%LocalAppData%\NVIDIA\DXCache & set /a i+=1
    set paths[!i!]=%LocalAppData%\NVIDIA\GLCache & set /a i+=1
    set paths[!i!]=%LocalAppData%\AMD\DxCache & set /a i+=1
    set paths[!i!]=C:\Windows\SoftwareDistribution\Download & set /a i+=1
)

:: ──────────────── CLEANING LOOP ────────────────
echo.
echo 💣 Scanning and wiping FUPOGs...
for /L %%x in (0,1,!i!) do (
    set "target=!paths[%%x]!"
    if defined target (
        echo 🧹 Cleaning: !target!
        if exist "!target!" (
            for /r "!target!" %%f in (*.*) do (
                rem -- skip protected system files
                echo %%~nxf | findstr /R ".*\.dll .*\.sys .*\.bat" >nul && (echo ⚠️ Skipped protected file: %%~nxf) || (
                    del /f /q "%%f" >nul 2>&1 && set /a FUP_COUNT+=1
                )
            )
            for /d %%D in ("!target!\*") do rd /s /q "%%D" >nul 2>&1
        )
    )
)

:: ──────────────── FANCY PROGRESS BAR ────────────────
set /a barMax=50
set /a step=!FUP_COUNT!/barMax
if !step! LSS 1 set /a step=1
set "bar="
for /L %%p in (1,1,!barMax!) do set "bar=!bar! "
for /L %%p in (1,1,!barMax!) do (
    set "barChar= "
    if %%p LEQ !FUP_COUNT!/!step! set "barChar=#"
    call set "bar=%%bar:~0,%%p-1%%!barChar!%%bar:~%%p%%"
)
echo.
echo 📊 FUPOGs Destroyed: !FUP_COUNT!
echo [!bar!]

:: ──────────────── ARCHIVE LOG ────────────────
if not exist "%ARCHIVE_DIR%" mkdir "%ARCHIVE_DIR%"
set "ZIPLOG=%ARCHIVE_DIR%\F$CK_%date:~0,4%-%date:~5,2%-%date:~8,2%_%time:~0,2%-%time:~3,2%.zip"
powershell -nologo -noprofile -command "Compress-Archive -Path '%LOG_FILE%' -DestinationPath '%ZIPLOG%'" >nul 2>&1

:: ──────────────── HISTORY LOG ────────────────
echo [%date% %time%] F$CK Run: !FUP_COUNT! FUPOGs cleaned. >> "%HISTORY_FILE%"

:: ──────────────── SELF-UPDATER ────────────────
curl -s -o "%UPDATE_TEMP%" "%UPDATE_URL%" >nul 2>&1
if exist "%UPDATE_TEMP%" (
    findstr /C:"set \"VERSION=" "%UPDATE_TEMP%" | findstr /V "!VERSION!" >nul
    if %errorlevel%==0 (
        echo 🔁 Update found. Replacing and restarting...
        timeout /t 1 >nul
        copy /y "%UPDATE_TEMP%" "%SCRIPT_PATH%" >nul
        start "" cmd /v:on /c "%SCRIPT_PATH%"
        del "%UPDATE_TEMP%" >nul
        exit /b
    ) else (
        del "%UPDATE_TEMP%" >nul
    )
)

:: ──────────────── DONE ────────────────
echo ✅ F$CK v1.2 completed. Log & history written.
timeout /t 5 >nul
exit /b
