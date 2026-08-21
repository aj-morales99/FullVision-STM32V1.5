@echo off
setlocal EnableExtensions

title Remove FullVision STM32 board package
set "FV_CORE_ID=FullVision:stm32"

set "FV_ARDUINO_CLI="
for /F "delims=" %%F in ('where arduino-cli.exe 2^>NUL') do if not defined FV_ARDUINO_CLI set "FV_ARDUINO_CLI=%%F"
if not defined FV_ARDUINO_CLI if exist "%LOCALAPPDATA%\Microsoft\WinGet\Links\arduino-cli.exe" set "FV_ARDUINO_CLI=%LOCALAPPDATA%\Microsoft\WinGet\Links\arduino-cli.exe"
if not defined FV_ARDUINO_CLI if exist "%ProgramFiles%\Arduino IDE\resources\app\lib\backend\resources\arduino-cli.exe" set "FV_ARDUINO_CLI=%ProgramFiles%\Arduino IDE\resources\app\lib\backend\resources\arduino-cli.exe"
if not defined FV_ARDUINO_CLI if exist "%LOCALAPPDATA%\Programs\Arduino IDE\resources\app\lib\backend\resources\arduino-cli.exe" set "FV_ARDUINO_CLI=%LOCALAPPDATA%\Programs\Arduino IDE\resources\app\lib\backend\resources\arduino-cli.exe"
if not defined FV_ARDUINO_CLI if exist "%LOCALAPPDATA%\FullVision\tools\arduino-cli\arduino-cli.exe" set "FV_ARDUINO_CLI=%LOCALAPPDATA%\FullVision\tools\arduino-cli\arduino-cli.exe"

if not defined FV_ARDUINO_CLI (
  echo ERROR: Arduino CLI was not found.
  goto :failed
)

tasklist /FI "IMAGENAME eq Arduino IDE.exe" 2>NUL | find /I "Arduino IDE.exe" >NUL
if not errorlevel 1 (
  echo ERROR: Close Arduino IDE completely before removing FullVision.
  goto :failed
)

echo.
echo This removes only %FV_CORE_ID%.
echo Official STMicroelectronics STM32 boards will not be changed.
choice /M "Remove the FullVision STM32 board package"
if errorlevel 2 goto :cancelled

"%FV_ARDUINO_CLI%" core uninstall "%FV_CORE_ID%"
if errorlevel 1 goto :failed

echo.
echo SUCCESS: FullVision was removed. Official STM32 boards were untouched.
pause
exit /B 0

:cancelled
echo Removal cancelled. Nothing was changed.
pause
exit /B 0

:failed
echo.
echo FullVision removal was not completed.
pause
exit /B 1
