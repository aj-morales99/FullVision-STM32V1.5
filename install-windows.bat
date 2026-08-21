@echo off
setlocal EnableExtensions

title FullVision STM32 V1.5 Windows Setup

rem FullVision is deliberately pinned to STM32duino 2.12.0 for the proven
rem F103C8 flash footprint. Do not silently upgrade this to 3.x.
set "FV_STM32_VERSION=2.12.0"
set "FV_STM32_INDEX=https://github.com/stm32duino/BoardManagerFiles/raw/main/package_stmicroelectronics_index.json"
set "FV_ARDUINO_DOWNLOAD=https://www.arduino.cc/en/software"
set "FV_CLI_DOWNLOAD=https://github.com/arduino/arduino-cli/releases/download/v1.5.1/arduino-cli_1.5.1_Windows_64bit.zip"
set "FV_CLI_SHA256=fabe42e0eb04d00e776a66178299ff95a46c623dbc260f997e58fd514853dd40"
set "FV_CUBE_DOWNLOAD=https://www.st.com/en/development-tools/stm32cubeprog.html"

rem %~dp0 ends with a backslash. Appending a dot prevents Robocopy from
rem misreading a quoted source path whose final character is a backslash.
set "FV_SOURCE=%~dp0."
set "FV_ARDUINO_DATA=%LOCALAPPDATA%\Arduino15"
set "FV_STM32_ROOT=%FV_ARDUINO_DATA%\packages\STMicroelectronics\hardware\stm32"
set "FV_TARGET=%FV_STM32_ROOT%\%FV_STM32_VERSION%"
set "FV_BACKUP_ROOT=%USERPROFILE%\Documents\FullVision-STM32-Backups"
set "FV_BACKUP=%FV_BACKUP_ROOT%\STM32-%FV_STM32_VERSION%-official"
set "FV_LOG=%TEMP%\FullVision-STM32-install.log"
set "FV_NEW_INSTALL=0"

echo.
echo FullVision STM32 V1.5 Windows setup
echo ===================================
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

if not exist "%FV_SOURCE%\boards.txt" (
  echo ERROR: boards.txt was not found beside this installer.
  echo Extract the complete FullVision release ZIP before running this file.
  goto :failed
)

tasklist /FI "IMAGENAME eq Arduino IDE.exe" 2>NUL | find /I "Arduino IDE.exe" >NUL
if not errorlevel 1 (
  echo ERROR: Arduino IDE is running. Close it completely and run this setup again.
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
if errorlevel 1 (
  echo ERROR: Arduino CLI was found but could not run.
  goto :failed
)
echo.

echo [3/5] Checking STM32 Boards Manager core %FV_STM32_VERSION%...
call :ensure_stm32_core
if errorlevel 1 goto :failed
echo STM32 core and required compiler/CMSIS tools are ready.
echo.

echo [4/5] Checking STM32CubeProgrammer...
call :detect_cube_programmer
if not defined FV_CUBE_CLI call :request_cube_programmer
if errorlevel 1 goto :failed
echo Found STM32CubeProgrammer: %FV_CUBE_CLI%
echo.

echo [5/5] Installing FullVision board files...
call :install_fullvision
if errorlevel 1 goto :failed

echo.
echo SUCCESS: FullVision STM32 V1.5 is installed.
echo Official-core backup: %FV_BACKUP%
echo.
echo Open Arduino IDE and select:
echo   FullVision-STM32 V1.5 ^(STM32duino 2.12.0^)
echo.
echo Fixed automatically for this board:
echo   MCU: STM32F103C8T6 Blue Pill ^(64 KB flash^)
echo   Upload: STM32CubeProgrammer ^(Serial through CH340G^)
echo   USB speed: Low/Full Speed ^(when native USB is enabled^)
echo.
echo Recommended Tools settings ^(selected by default^):
echo   USB support: Native CDC ^(generic Serial supersedes UART^)
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
if errorlevel 2 (
  echo Arduino IDE installation was declined.
  exit /B 1
)
where winget.exe >NUL 2>NUL
if not errorlevel 1 (
  echo Downloading and installing Arduino IDE 2 through Windows Package Manager...
  winget install --id ArduinoSA.IDE.stable --exact --source winget --accept-package-agreements --accept-source-agreements --silent
  if errorlevel 1 echo Windows Package Manager could not complete the Arduino IDE installation.
)

call :detect_arduino_ide
if defined FV_ARDUINO_IDE exit /B 0

echo.
echo Arduino IDE still needs to be installed manually from the official page:
echo %FV_ARDUINO_DOWNLOAD%
start "" "%FV_ARDUINO_DOWNLOAD%"
echo Install Arduino IDE 2, then return to this window.
pause
call :detect_arduino_ide
if not defined FV_ARDUINO_IDE (
  echo ERROR: Arduino IDE 2 was not detected after the installation step.
  exit /B 1
)
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
  echo Installing the official Arduino CLI through Windows Package Manager...
  winget install --id ArduinoSA.CLI --exact --source winget --accept-package-agreements --accept-source-agreements --silent
  if errorlevel 1 echo Windows Package Manager could not complete the Arduino CLI installation.
)

call :detect_arduino_cli
if defined FV_ARDUINO_CLI exit /B 0

echo Downloading the official 64-bit Arduino CLI fallback package...
set "FV_CLI_ZIP=%TEMP%\FullVision-arduino-cli.zip"
set "FV_CLI_DIR=%LOCALAPPDATA%\FullVision\tools\arduino-cli"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -UseBasicParsing -Uri $env:FV_CLI_DOWNLOAD -OutFile $env:FV_CLI_ZIP; $actual=(Get-FileHash -Algorithm SHA256 -LiteralPath $env:FV_CLI_ZIP).Hash.ToLowerInvariant(); if ($actual -ne $env:FV_CLI_SHA256) { throw 'Arduino CLI checksum verification failed' }; New-Item -ItemType Directory -Force -Path $env:FV_CLI_DIR ^| Out-Null; Expand-Archive -LiteralPath $env:FV_CLI_ZIP -DestinationPath $env:FV_CLI_DIR -Force"
if errorlevel 1 (
  echo ERROR: Could not download or extract Arduino CLI from the official Arduino server.
  exit /B 1
)
if exist "%FV_CLI_ZIP%" del /Q "%FV_CLI_ZIP%"

call :detect_arduino_cli
if not defined FV_ARDUINO_CLI (
  echo ERROR: Arduino CLI was not detected after installation.
  exit /B 1
)
exit /B 0


:ensure_stm32_core
set "FV_CORE_READY=0"
if exist "%FV_TARGET%\platform.txt" if exist "%FV_ARDUINO_DATA%\packages\STMicroelectronics\tools\CMSIS\6.2.0\CMSIS\Core\Include\core_cm3.h" if exist "%FV_ARDUINO_DATA%\packages\STMicroelectronics\tools\xpack-arm-none-eabi-gcc\14.2.1-1.1\bin\arm-none-eabi-g++.exe" set "FV_CORE_READY=1"
if "%FV_CORE_READY%"=="1" findstr /B /C:"name=FullVision STM32" "%FV_TARGET%\platform.txt" >NUL 2>NUL
if "%FV_CORE_READY%"=="1" if not errorlevel 1 exit /B 0

echo Downloading the official STM32 Boards Manager index...
"%FV_ARDUINO_CLI%" core update-index --additional-urls "%FV_STM32_INDEX%"
if errorlevel 1 (
  echo ERROR: Arduino CLI could not download the STM32 Boards Manager index.
  exit /B 1
)

echo Installing STM32 MCU based boards %FV_STM32_VERSION% and its required tools...
"%FV_ARDUINO_CLI%" core install "STMicroelectronics:stm32@%FV_STM32_VERSION%" --additional-urls "%FV_STM32_INDEX%"
if errorlevel 1 (
  echo ERROR: Arduino CLI could not install the STM32 Boards Manager core.
  exit /B 1
)

if not exist "%FV_TARGET%\platform.txt" (
  echo ERROR: STM32 core %FV_STM32_VERSION% was not created at:
  echo %FV_TARGET%
  exit /B 1
)
if not exist "%FV_ARDUINO_DATA%\packages\STMicroelectronics\tools\CMSIS\6.2.0\CMSIS\Core\Include\core_cm3.h" (
  echo ERROR: Required CMSIS 6.2.0 files were not installed.
  exit /B 1
)
if not exist "%FV_ARDUINO_DATA%\packages\STMicroelectronics\tools\xpack-arm-none-eabi-gcc\14.2.1-1.1\bin\arm-none-eabi-g++.exe" (
  echo ERROR: Required GNU Arm toolchain 14.2.1-1.1 was not installed.
  exit /B 1
)
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
echo.
echo ST provides it free of charge, but every user must obtain it from ST and
echo accept ST's license and export-control terms. FullVision does not download
echo or redistribute the proprietary installer from Google Drive.
echo.
echo Opening the official STM32CubeProgrammer page:
echo %FV_CUBE_DOWNLOAD%
start "" "%FV_CUBE_DOWNLOAD%"
echo.
echo Download and install STM32CubeProgrammer, then return to this window.
pause
call :detect_cube_programmer
if not defined FV_CUBE_CLI (
  echo ERROR: STM32CubeProgrammer was not detected.
  echo Finish its installation and run this FullVision setup again.
  exit /B 1
)
exit /B 0


:install_fullvision
if not exist "%FV_STM32_ROOT%" mkdir "%FV_STM32_ROOT%"

findstr /B /C:"name=FullVision STM32" "%FV_TARGET%\platform.txt" >NUL 2>NUL
if errorlevel 1 (
  if exist "%FV_BACKUP%" (
    echo ERROR: A previous official-core backup already exists at:
    echo %FV_BACKUP%
    echo Restore or move that backup before starting a fresh installation.
    exit /B 1
  )

  if not exist "%FV_BACKUP_ROOT%" mkdir "%FV_BACKUP_ROOT%"
  move "%FV_TARGET%" "%FV_BACKUP%" >NUL
  if errorlevel 1 (
    echo ERROR: Could not back up the official STM32 core.
    exit /B 1
  )
  set "FV_NEW_INSTALL=1"
  mkdir "%FV_TARGET%" >NUL
) else (
  echo Existing FullVision installation detected; updating it.
)

robocopy "%FV_SOURCE%" "%FV_TARGET%" /E /COPY:DAT /DCOPY:DAT /R:2 /W:1 /XD ".git" /LOG:"%FV_LOG%"
set "FV_COPY_RESULT=%ERRORLEVEL%"
if %FV_COPY_RESULT% GEQ 8 (
  echo ERROR: Copying the FullVision core failed with Robocopy code %FV_COPY_RESULT%.
  echo.
  echo Robocopy details:
  type "%FV_LOG%"
  echo.
  if "%FV_NEW_INSTALL%"=="1" (
    rmdir /S /Q "%FV_TARGET%"
    move "%FV_BACKUP%" "%FV_TARGET%" >NUL
    echo The official STM32 core was restored.
  )
  exit /B 1
)
exit /B 0


:failed
echo.
echo FullVision setup was not completed.
echo It is safe to fix the reported requirement and run this file again.
pause
exit /B 1
