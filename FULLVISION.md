# FullVision STM32 V1.5

FullVision STM32 V1.5 is a hardware-specific derivative of the
[STM32duino Arduino_Core_STM32](https://github.com/stm32duino/Arduino_Core_STM32)
2.12.0 release. It retains the upstream Git history, copyright notices, license,
and source code while providing a focused profile for the STM32F103C8T6 Blue
Pill used by the FullVision board.

FullVision installs as the independent Arduino package `FullVision:stm32`. It
does not replace or downgrade `STMicroelectronics:stm32`, so users may keep the
latest official STM32 core installed beside FullVision.

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

1. Download `install-windows.bat` from the GitHub release.
2. Close Arduino IDE.
3. Run the installer and follow any prerequisite prompts.
4. Reopen Arduino IDE and select **FullVision-STM32 V1.5**.

The installer checks Arduino IDE 2, Arduino CLI, the exact tools required by
the STM32duino 2.12.0 base, and STM32CubeProgrammer. The tools are installed as
dependencies of `FullVision:stm32`; the official STM32 core version is left
unchanged. ST requires each user to obtain and accept the STM32CubeProgrammer
license themselves, so the installer opens ST's official page when needed.

## macOS installation

The macOS installer is in validation and is not currently attached to the
stable release. Apple Silicon compilation is verified. Public distribution
will follow a successful physical CH340G/UART upload using
STM32CubeProgrammer 2.23. Do not distribute the source-tree `.command` files as
a finished installer until that test passes.

The single board-part, upload-method, and USB-speed choices are fixed but may be
hidden by Arduino IDE. Menus with meaningful alternatives remain visible. Keep
these defaults for the FullVision board:

- USB support: **Native CDC (generic Serial supersedes UART)**
- U(S)ART support: **Enabled (generic Serial)**
- Optimize: **Smallest (-Os default)**
- Debug symbols and core logs: **None**
- C Runtime Library: **Newlib Nano (default)**

Use `restore-official-windows.bat` on Windows to uninstall only
`FullVision:stm32`. It does not modify the official STMicroelectronics STM32
package. A macOS remover will be included when the macOS installer is released.

## License and attribution

This fork is distributed under the same open-source terms as its upstream
files. See the upstream [License](License.md), the component-specific license
files, and the copyright notices retained in individual source files.
FullVision does not claim ownership of STM32duino or STMicroelectronics code.
