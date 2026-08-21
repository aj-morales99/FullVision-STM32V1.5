# FullVision STM32 V1.5 test core

FullVision STM32 V1.5 is a hardware-specific derivative of the
[STM32duino Arduino_Core_STM32](https://github.com/stm32duino/Arduino_Core_STM32)
2.12.0 release. It retains the upstream Git history, copyright notices, license,
and source code while providing a focused profile for the STM32F103C8T6 Blue
Pill used by the FullVision board.

This remains a hardware-test release. Validate compilation, upload, native USB
serial, Bluetooth SoftwareSerial, receiver input, and motor PWM on the physical
board before distributing it to clients as a stable release.

## FullVision changes

- Only the `FullVision-STM32 V1.5` / BluePill F103C8 board profile is exposed.
- The genuine STM32F103C8 limit of 64 KB flash and 20 KB RAM is enforced.
- SoftwareSerial uses TIM1; FullVision motor PWM can use TIM2, TIM3, and TIM4.
- STM32CubeProgrammer serial upload is fixed for the board profile.
- Native USB CDC supplies generic `Serial` by default.
- Hardware UART support remains enabled.
- Full-Speed USB, no debug/core logs, and Newlib Nano are the defaults.
- Size optimization uses the proven STM32duino 2.12.0 `-Os` default.

## Windows installation

1. Download the complete release ZIP from GitHub Releases. Do not use GitHub's
   automatically generated **Source code (zip)** download.
2. Extract the ZIP completely.
3. Close Arduino IDE.
4. Run `install-windows.bat` from the extracted folder.
5. Reopen Arduino IDE and select **FullVision-STM32 V1.5**.

The installer checks Arduino IDE 2, Arduino CLI, STM32duino 2.12.0 and its tools,
and STM32CubeProgrammer. ST requires each user to download and accept the
STM32CubeProgrammer license themselves, so the installer opens ST's official
page when that application is missing.

The single board-part, upload-method, and USB-speed choices are fixed but may be
hidden by Arduino IDE. Menus with meaningful alternatives remain visible. Keep
these defaults for the FullVision board:

- USB support: **Native CDC (generic Serial supersedes UART)**
- U(S)ART support: **Enabled (generic Serial)**
- Optimize: **Smallest (-Os default)**
- Debug symbols and core logs: **None**
- C Runtime Library: **Newlib Nano (default)**

Use `restore-official-windows.bat` to restore the official STM32duino 2.12.0 core
backup made by the installer.

## License and attribution

This fork is distributed under the same open-source terms as its upstream
files. See the upstream [License](License.md), the component-specific license
files, and the copyright notices retained in individual source files.
FullVision does not claim ownership of STM32duino or STMicroelectronics code.
