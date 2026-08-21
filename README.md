# FullVision STM32 V1.5

FullVision STM32 V1.5 is an Arduino board package for the FullVision controller
and compatible **STM32F103C8T6 Blue Pill or Black Pill boards**.

It is a focused community fork of
[STM32duino Arduino_Core_STM32](https://github.com/stm32duino/Arduino_Core_STM32),
based on the upstream **2.12.0** release. The main FullVision change assigns
**TIM1 to SoftwareSerial**, leaving TIM2, TIM3, and TIM4 available for the
project's custom motor PWM frequencies.

> [!IMPORTANT]
> This project is not an official STMicroelectronics or STM32duino release.
> STM32duino remains the original upstream project. Its Git history, copyright
> notices, source notices, and applicable open-source licenses are retained.

## Why this package exists

The FullVision controller uses several timers at the same time:

| Timer | FullVision purpose |
| --- | --- |
| TIM1 | SoftwareSerial timing |
| TIM2-TIM4 | Custom-frequency motor PWM |

The upstream STM32duino core can select a timer that conflicts with the motor
PWM arrangement. This package provides a repeatable board setup so every user
does not have to modify their locally installed STM32 core by hand.

## Supported hardware

- FullVision STM32 V1.5 controller
- STM32F103C8T6
- Blue Pill and compatible Black Pill layouts using the F103C8 profile
- 64 KB flash and 20 KB RAM
- USB-to-serial programming, including CH340G-based interfaces

The package deliberately builds for the guaranteed **64 KB** capacity of the
STM32F103C8T6. Some individual chips may appear to provide more flash, but this
release does not depend on undocumented extra capacity.

Other STM32 families and general-purpose STM32 board profiles are not supported
by this FullVision release. Use the
[official STM32duino package](https://github.com/stm32duino/Arduino_Core_STM32)
for those boards.

## Included configuration

- Base core: STM32duino 2.12.0
- Board: Blue Pill F103C8
- MCU profile: STM32F103C8T6, 64 KB flash
- Upload method: STM32CubeProgrammer (Serial)
- USB support: Native CDC, generic `Serial`
- U(S)ART support: Enabled, generic `Serial`
- USB speed: Low/Full Speed
- Optimization: Smallest (`-Os`)
- Debug symbols and core logs: None
- C runtime library: Newlib Nano
- SoftwareSerial timer: TIM1

Arduino IDE may hide options that have only one permitted choice. This is
normal; the fixed value is still applied by the board package.

## Recommended Windows installation

1. Open the
   [latest FullVision release](https://github.com/aj-morales99/FullVision-STM32V1.5/releases/latest).
2. Download `install-windows.bat`.
3. Close Arduino IDE.
4. Run the downloaded installer and follow its prompts.
5. Reopen Arduino IDE.
6. Select **FullVision-STM32 V1.5 (STM32duino 2.12.0)** as the board.
7. Select the COM port for the controller and upload the sketch.

The installer can check Arduino IDE 2, install the Arduino CLI when required,
install `FullVision:stm32@1.5.0`, and check for STM32CubeProgrammer. If
STM32CubeProgrammer is missing, the installer directs the user to ST's official
download because ST requires each user to accept its license.

## Manual Boards Manager installation

Advanced users can add these two URLs to **File > Preferences > Additional
Boards Manager URLs** in Arduino IDE 2:

```text
https://github.com/aj-morales99/FullVision-STM32V1.5/releases/download/v1.5.0/package_fullvision_index.json
https://github.com/stm32duino/BoardManagerFiles/raw/main/package_stmicroelectronics_index.json
```

Then open Boards Manager, search for **FullVision**, and install version 1.5.0.
The STM32duino index is also required because it supplies the official compiler
and supporting tool definitions used by the 2.12.0-based package.

## Coexistence with official STM32duino

FullVision installs as the independent package `FullVision:stm32`. It does
**not** replace, patch, upgrade, or downgrade the official
`STMicroelectronics:stm32` package. For example, official STM32duino 3.0.0 can
remain installed beside FullVision 1.5.0:

- Select a **FullVision** board to compile with the FullVision 2.12.0-based core.
- Select an **STMicroelectronics** board to compile with the official core.
- Updating the official core does not update FullVision.
- Uninstalling FullVision does not uninstall the official core.

The release also includes `restore-official-windows.bat`, which removes only
the FullVision package. Despite the legacy filename, it does not modify the
official STM32duino installation.

## Uploading through USB-to-serial

For STM32CubeProgrammer serial upload, place the board in its serial bootloader
mode before uploading. On boards with BOOT0 and reset controls, the usual flow
is:

1. Set or hold BOOT0 high.
2. Reset or power-cycle the controller.
3. Confirm that the correct COM port is selected.
4. Start the upload.
5. Return BOOT0 low and reset the controller to run the uploaded program.

The exact button sequence can differ between FullVision controller revisions.
An unreliable connection is commonly caused by the wrong COM port, incorrect
BOOT0 state, another program holding the port, wiring, power, or a missing
CH340G driver—not by the optimization setting.

## SoftwareSerial note

Do not allocate TIM1 to another feature in sketches that use SoftwareSerial.
TIM2, TIM3, and TIM4 are intentionally left for the FullVision motor-control
implementation. Application code must still avoid assigning two independent
features to the same timer.

When reading one byte from SoftwareSerial into an Arduino `String`, use an
explicit character conversion or append operation rather than assigning the
integer returned by `read()` directly. For example:

```cpp
while (Bluetooth.available()) {
  response += static_cast<char>(Bluetooth.read());
}
```

## Releases and documentation

- [Download FullVision STM32 V1.5.0](https://github.com/aj-morales99/FullVision-STM32V1.5/releases/tag/v1.5.0)
- [FullVision technical notes](FULLVISION.md)
- [Upstream STM32duino project](https://github.com/stm32duino/Arduino_Core_STM32)
- [Upstream STM32duino documentation](https://github.com/stm32duino/Arduino_Core_STM32/wiki)

## Fork attribution and licensing

This repository is derived from STM32duino `Arduino_Core_STM32` 2.12.0. The
FullVision-specific configuration is maintained by the FullVision project; the
underlying Arduino STM32 core and bundled components remain attributable to
their respective upstream authors and copyright holders.

The repository contains components under several open-source licenses. See
[License.md](License.md), the license files in the relevant component folders,
and the notices retained in individual source files. FullVision does not claim
ownership of STM32duino, STMicroelectronics, Arduino, Arm, or third-party code
included from upstream.

STM32 and STMicroelectronics are trademarks of STMicroelectronics. Arduino is a
trademark of Arduino SA. Their names are used only to describe compatibility
and upstream origin.
