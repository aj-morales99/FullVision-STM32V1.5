# FullVision STM32 V1.5 — macOS setup

## Install

1. Extract `FullVision-macOS-1.5.0-installer.zip`.
2. Close Arduino IDE completely.
3. Double-click `install-macos.command`.
4. Follow the Terminal prompts for Arduino IDE 2 and STM32CubeProgrammer if
   either application is missing.
5. Reopen Arduino IDE after the installer reports `SUCCESS`.
6. Select **FullVision-STM32 V1.5 (STM32duino 2.12.0)** and the controller's
   serial port.

If macOS blocks the script, Control-click `install-macos.command`, choose
**Open**, and confirm **Open**. Do not disable Gatekeeper globally.

## What the installer changes

- Installs the independent Arduino package `FullVision:stm32@1.5.0`.
- Downloads the official STM32duino tool dependencies declared by the package.
- Installs Arduino CLI under the user's Library only when no usable CLI exists.
- Does not replace, patch, upgrade, or downgrade `STMicroelectronics:stm32`.
- Does not use Homebrew and does not request `sudo`.

STM32CubeProgrammer is not redistributed. When it is missing, the installer
opens STMicroelectronics' official page so the user can download it and accept
its license.

## CH340G serial connection

After connecting the controller, check **Arduino IDE > Tools > Port**. A CH340G
adapter commonly appears as `/dev/cu.usbserial...` or
`/dev/cu.wchusbserial...`. If no new port appears:

1. Try a known data-capable USB cable.
2. Try a different USB port or adapter.
3. Disconnect and reconnect the board, then reopen the Port menu.
4. Confirm that the board is powered.
5. Install a CH340 driver only when required for that Mac and adapter.

## Remove FullVision

Close Arduino IDE, then double-click `remove-fullvision-macos.command`. It
removes only `FullVision:stm32`; the official STM32duino package and
STM32CubeProgrammer remain installed.
