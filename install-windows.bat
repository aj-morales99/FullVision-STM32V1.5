@echo off
setlocal EnableExtensions

title FullVision STM32 V1.5 Windows Setup

set "FV_CORE_ID=FullVision:stm32"
set "FV_CORE_VERSION=1.5.0"
set "FV_FULLVISION_INDEX=https://github.com/aj-morales99/FullVision-STM32V1.5/releases/download/v1.5.0/package_fullvision_index.json"
set "FV_STM32_INDEX=https://github.com/stm32duino/BoardManagerFiles/raw/main/package_stmicroelectronics_index.json"
set "FV_ARDUINO_DOWNLOAD=https://www.arduino.cc/en/software"
set "FV_CLI_DOWNLOAD=https://github.com/arduino/arduino-cli/releases/download/v1.5.1/arduino-cli_1.5.1_Windows_64bit.zip"
set "FV_CLI_SHA256=fabe42e0eb04d00e776a66178299ff95a46c623dbc260f997e58fd514853dd40"
set "FV_CUBE_DOWNLOAD=https://www.st.com/en/development-tools/stm32cubeprog.html"

echo.
echo FullVision STM32 V1.5 Windows setup
echo ===================================
echo This installs FullVision as an independent Arduino package.
echo Official STMicroelectronics STM32 boards will not be replaced or downgraded.
echo.

if /I "%PROCESSOR_ARCHITECTURE%"=="x86" if not defined PROCESSOR_ARCHITEW6432 (
  echo ERROR: Arduino IDE 2 requires 64-bit Windows 10 or newer.
  goto :failed
)

set "FV_SUPPORTED_WINDOWS="
for /F "delims=" %%V in ('powershell.exe -NoProfile -Command "if ([Environment]::OSVersion.Version.Major -ge 10) { 'yes' }" 2^>NUL') do set "FV_SUPPORTED_WINDOWS=%%V"
if not "%FV_SUPPORTED_WINDOWS%"=="yes" (
  echo ERROR: Arduino IDE 2 requires Windows 10 or newer.
  goto :failed
)

tasklist /FI "IMAGENAME eq Arduino IDE.exe" 2>NUL | find /I "Arduino IDE.exe" >NUL
if not errorlevel 1 (
  echo ERROR: Close Arduino IDE completely and run this setup again.
  goto :failed
)

echo [1/5] Checking Arduino IDE 2...
call :detect_arduino_ide
if not defined FV_ARDUINO_IDE call :install_arduino_ide
if errorlevel 1 goto :failed
echo Found Arduino IDE: %FV_ARDUINO_IDE%
echo.

echo [2/5] Checking Arduino CLI...
call :detect_arduino_cli
if not defined FV_ARDUINO_CLI call :install_arduino_cli
if errorlevel 1 goto :failed
echo Found Arduino CLI: %FV_ARDUINO_CLI%
"%FV_ARDUINO_CLI%" version
if errorlevel 1 goto :failed
echo.

echo [3/5] Installing independent FullVision board package...
"%FV_ARDUINO_CLI%" core update-index --additional-urls "%FV_FULLVISION_INDEX%,%FV_STM32_INDEX%"
if errorlevel 1 (
  echo ERROR: Could not download the FullVision and STM32 tool indexes.
  goto :failed
)
"%FV_ARDUINO_CLI%" core install "%FV_CORE_ID%@%FV_CORE_VERSION%" --additional-urls "%FV_FULLVISION_INDEX%,%FV_STM32_INDEX%"
if errorlevel 1 (
  echo ERROR: Could not install the independent FullVision package.
  goto :failed
)
echo.

echo [4/5] Checking STM32CubeProgrammer...
call :detect_cube_programmer
if not defined FV_CUBE_CLI call :request_cube_programmer
if errorlevel 1 goto :failed
echo Found STM32CubeProgrammer: %FV_CUBE_CLI%
echo.

echo [5/5] Verifying installed board packages...
"%FV_ARDUINO_CLI%" core list
if errorlevel 1 goto :failed

echo.
echo SUCCESS: %FV_CORE_ID%@%FV_CORE_VERSION% is installed.
echo Official STMicroelectronics STM32 boards were not changed.
echo.
echo Open Arduino IDE and select:
echo   FullVision-STM32 V1.5 ^(STM32duino 2.12.0^)
echo.
echo Required defaults:
echo   MCU: STM32F103C8T6 Blue Pill ^(64 KB flash^)
echo   Upload: STM32CubeProgrammer ^(Serial^)
echo   USB support: CDC ^(generic Serial supersedes U^(S^)ART^)
echo   USB speed: Low/Full Speed
echo   U^(S^)ART support: Enabled ^(generic Serial^)
echo   Optimize: Smallest ^(-Os default^)
echo   Debug symbols and core logs: None
echo   C Runtime Library: Newlib Nano ^(default^)
echo.
pause
exit /B 0

:detect_arduino_ide
set "FV_ARDUINO_IDE="
if exist "%ProgramFiles%\Arduino IDE\Arduino IDE.exe" set "FV_ARDUINO_IDE=%ProgramFiles%\Arduino IDE\Arduino IDE.exe"
if not defined FV_ARDUINO_IDE if exist "%LOCALAPPDATA%\Programs\Arduino IDE\Arduino IDE.exe" set "FV_ARDUINO_IDE=%LOCALAPPDATA%\Programs\Arduino IDE\Arduino IDE.exe"
exit /B 0

:install_arduino_ide
echo Arduino IDE 2 was not found.
choice /M "Download and install Arduino IDE 2 now"
if errorlevel 2 exit /B 1
where winget.exe >NUL 2>NUL
if not errorlevel 1 (
  winget install --id ArduinoSA.IDE.stable --exact --source winget --accept-package-agreements --accept-source-agreements --silent
)
call :detect_arduino_ide
if defined FV_ARDUINO_IDE exit /B 0
start "" "%FV_ARDUINO_DOWNLOAD%"
echo Install Arduino IDE 2 from the official page, then return here.
pause
call :detect_arduino_ide
if not defined FV_ARDUINO_IDE exit /B 1
exit /B 0

:detect_arduino_cli
set "FV_ARDUINO_CLI="
for /F "delims=" %%F in ('where arduino-cli.exe 2^>NUL') do if not defined FV_ARDUINO_CLI set "FV_ARDUINO_CLI=%%F"
if not defined FV_ARDUINO_CLI if exist "%LOCALAPPDATA%\Microsoft\WinGet\Links\arduino-cli.exe" set "FV_ARDUINO_CLI=%LOCALAPPDATA%\Microsoft\WinGet\Links\arduino-cli.exe"
if not defined FV_ARDUINO_CLI if exist "%ProgramFiles%\Arduino IDE\resources\app\lib\backend\resources\arduino-cli.exe" set "FV_ARDUINO_CLI=%ProgramFiles%\Arduino IDE\resources\app\lib\backend\resources\arduino-cli.exe"
if not defined FV_ARDUINO_CLI if exist "%LOCALAPPDATA%\Programs\Arduino IDE\resources\app\lib\backend\resources\arduino-cli.exe" set "FV_ARDUINO_CLI=%LOCALAPPDATA%\Programs\Arduino IDE\resources\app\lib\backend\resources\arduino-cli.exe"
if not defined FV_ARDUINO_CLI if exist "%LOCALAPPDATA%\FullVision\tools\arduino-cli\arduino-cli.exe" set "FV_ARDUINO_CLI=%LOCALAPPDATA%\FullVision\tools\arduino-cli\arduino-cli.exe"
exit /B 0

:install_arduino_cli
where winget.exe >NUL 2>NUL
if not errorlevel 1 (
  winget install --id ArduinoSA.CLI --exact --source winget --accept-package-agreements --accept-source-agreements --silent
)
call :detect_arduino_cli
if defined FV_ARDUINO_CLI exit /B 0

set "FV_CLI_ZIP=%TEMP%\FullVision-arduino-cli.zip"
set "FV_CLI_DIR=%LOCALAPPDATA%\FullVision\tools\arduino-cli"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -UseBasicParsing -Uri $env:FV_CLI_DOWNLOAD -OutFile $env:FV_CLI_ZIP; $actual=(Get-FileHash -Algorithm SHA256 -LiteralPath $env:FV_CLI_ZIP).Hash.ToLowerInvariant(); if ($actual -ne $env:FV_CLI_SHA256) { throw 'Arduino CLI checksum verification failed' }; New-Item -ItemType Directory -Force -Path $env:FV_CLI_DIR ^| Out-Null; Expand-Archive -LiteralPath $env:FV_CLI_ZIP -DestinationPath $env:FV_CLI_DIR -Force"
if errorlevel 1 exit /B 1
if exist "%FV_CLI_ZIP%" del /Q "%FV_CLI_ZIP%"
call :detect_arduino_cli
if not defined FV_ARDUINO_CLI exit /B 1
exit /B 0

:detect_cube_programmer
set "FV_CUBE_CLI="
for /F "delims=" %%F in ('where STM32_Programmer_CLI.exe 2^>NUL') do if not defined FV_CUBE_CLI set "FV_CUBE_CLI=%%F"
if not defined FV_CUBE_CLI if exist "%ProgramW6432%\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe" set "FV_CUBE_CLI=%ProgramW6432%\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe"
if not defined FV_CUBE_CLI if exist "%ProgramFiles%\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe" set "FV_CUBE_CLI=%ProgramFiles%\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe"
if not defined FV_CUBE_CLI if exist "%ProgramFiles(x86)%\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe" set "FV_CUBE_CLI=%ProgramFiles(x86)%\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe"
exit /B 0

:request_cube_programmer
echo STM32CubeProgrammer is required for serial upload but was not found.
echo ST requires each user to accept its license and export-control terms.
start "" "%FV_CUBE_DOWNLOAD%"
echo Install STM32CubeProgrammer from ST's official page, then return here.
pause
call :detect_cube_programmer
if not defined FV_CUBE_CLI exit /B 1
exit /B 0

:failed
echo.
echo FullVision setup was not completed.
echo The official STMicroelectronics STM32 package was not intentionally changed.
pause
exit /B 1
