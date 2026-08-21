@echo off
setlocal EnableExtensions

title Restore official STM32 Arduino core

set "FV_STM32_ROOT=%LOCALAPPDATA%\Arduino15\packages\STMicroelectronics\hardware\stm32"
set "FV_BACKUP_ROOT=%USERPROFILE%\Documents\FullVision-STM32-Backups"

set "FV_VERSION="
for /F "delims=" %%D in ('dir /B /AD /O-N "%FV_STM32_ROOT%" 2^>NUL') do (
  if exist "%FV_STM32_ROOT%\%%D\platform.txt" (
    findstr /B /C:"name=FullVision STM32" "%FV_STM32_ROOT%\%%D\platform.txt" >NUL
    if not errorlevel 1 if not defined FV_VERSION set "FV_VERSION=%%D"
  )
)

if not defined FV_VERSION (
  echo ERROR: No active FullVision STM32 core was detected.
  goto :failed
)

set "FV_TARGET=%FV_STM32_ROOT%\%FV_VERSION%"
set "FV_BACKUP=%FV_BACKUP_ROOT%\STM32-%FV_VERSION%-official"

echo.
echo Restore official STM32 core %FV_VERSION%
echo ==================================
echo.

tasklist /FI "IMAGENAME eq Arduino IDE.exe" 2>NUL | find /I "Arduino IDE.exe" >NUL
if not errorlevel 1 (
  echo ERROR: Arduino IDE is running. Close it completely and try again.
  goto :failed
)

if not exist "%FV_BACKUP%\platform.txt" (
  echo ERROR: Official-core backup was not found at:
  echo %FV_BACKUP%
  goto :failed
)

if not exist "%FV_TARGET%\platform.txt" (
  echo ERROR: The active STM32 core directory was not found at:
  echo %FV_TARGET%
  goto :failed
)

findstr /B /C:"name=FullVision STM32" "%FV_TARGET%\platform.txt" >NUL
if errorlevel 1 (
  echo ERROR: The active core is not identified as FullVision. Nothing was changed.
  goto :failed
)

choice /M "Remove the FullVision test core and restore the official STM32 core"
if errorlevel 2 goto :cancelled

rmdir /S /Q "%FV_TARGET%"
if exist "%FV_TARGET%" (
  echo ERROR: Could not remove the FullVision test core.
  goto :failed
)

move "%FV_BACKUP%" "%FV_TARGET%" >NUL
if errorlevel 1 (
  echo ERROR: Could not restore the official STM32 core.
  goto :failed
)

echo.
echo SUCCESS: Official STM32 core %FV_VERSION% was restored.
echo.
pause
exit /B 0

:cancelled
echo Restore cancelled. Nothing was changed.
pause
exit /B 0

:failed
echo.
echo Restore was not completed.
pause
exit /B 1
