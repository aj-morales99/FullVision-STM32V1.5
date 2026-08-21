# Windows test installation

This self-contained release is for validating FullVision STM32F1 V1.5 before
the final Arduino Boards Manager package is published.

## What the setup checks

The Windows setup performs these steps in order:

1. Verifies that Windows is 64-bit. Arduino IDE 2 requires 64-bit Windows 10
   or newer.
2. Detects Arduino IDE 2. If it is missing, setup first tries the official
   Arduino package through Windows Package Manager (`winget`). If that is not
   available, setup opens Arduino's official download page and waits for the
   user to complete installation.
3. Detects Arduino CLI. If needed, setup installs it through `winget` or
   downloads the pinned official Arduino CLI 1.5.1 ZIP and verifies its SHA-256
   checksum before extraction.
4. Uses Arduino CLI to install **STM32 MCU based boards 2.12.0 by
   STMicroelectronics**, including the required compiler and CMSIS tools. Other
   installed board platforms are left untouched.
5. Detects STM32CubeProgrammer. If missing, setup opens ST's official download
   page and waits for the user to accept ST's license/export terms and install
   it. FullVision does not bundle or download STM32CubeProgrammer from Google
   Drive because it is proprietary software.
6. Backs up the official STM32 2.12.0 core and installs the FullVision overlay.

Close Arduino IDE completely before running setup.

## Install

1. Download the attached `FullVision-STM32F1-V1.5-test.zip` release asset. Do
   not use GitHub's automatically generated **Source code** ZIP.
2. Extract the complete ZIP to a normal directory such as Downloads.
3. Double-click `install-windows.bat` and follow any prerequisite prompts. An
   internet connection is required when Arduino IDE, Arduino CLI, the STM32
   core, or STM32CubeProgrammer still needs to be installed.
4. Reopen Arduino IDE and select:
   - **FullVision-STM32 V1.5 (STM32duino 2.12.0)**
   - **Board part number: BluePill F103C8**
   - **Upload method: STM32CubeProgrammer (Serial)**
   - **USB support: CDC (generic 'Serial' supersede U(S)ART)**
   - **USB speed: Low/Full Speed**
   - **U(S)ART support: Enabled (generic 'Serial')**
   - **Optimize: Smallest (-Os default)**
   - **Debug symbols and core logs: None**
   - **C Runtime Library: Newlib Nano (default)**

   The board part, upload method, and USB speed are fixed and Arduino IDE may
   hide those single-choice menus. USB, UART, optimization, debug, and runtime
   menus remain visible; the required settings above are their defaults.

The installer moves the official STM32 2.12.0 core to
`Documents\FullVision-STM32-Backups` and installs FullVision in its place. The
compiler and other dependencies remain managed by Arduino Boards Manager. If a
later Boards Manager operation replaces the FullVision overlay, close Arduino
IDE and rerun `install-windows.bat`.

## Restore

Close Arduino IDE, then double-click `restore-official-windows.bat` and confirm
the prompt. This removes the FullVision test core and restores the saved
official STM32 core.

## Timer allocation

| Timer | FullVision role |
| --- | --- |
| TIM1 | SoftwareSerial |
| TIM2-TIM4 | Motor PWM / custom frequency control |
