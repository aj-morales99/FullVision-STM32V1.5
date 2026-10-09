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

## Recommended macOS installation

1. Open the
   [latest FullVision release](https://github.com/aj-morales99/FullVision-STM32V1.5/releases/latest).
2. Download `FullVision-macOS-1.5.0-installer.zip` and extract it.
3. Close Arduino IDE.
4. Double-click `install-macos.command` and follow its prompts.
5. If macOS blocks the first launch, Control-click the file, choose **Open**,
   and confirm **Open**.
6. Reopen Arduino IDE and select
   **FullVision-STM32 V1.5 (STM32duino 2.12.0)**.
7. Select the serial port for the controller and upload the sketch.

The macOS installer supports Apple Silicon and 64-bit Intel Macs. It checks
Arduino IDE 2, installs a private copy of the official Arduino CLI when no CLI
is available, installs `FullVision:stm32@1.5.0`, and checks the default macOS
location for STM32CubeProgrammer. It does not use Homebrew or require `sudo`.

## Obtaining and installing STM32CubeProgrammer

STM32CubeProgrammer is STMicroelectronics' programming application. FullVision
uses its command-line component to upload a compiled sketch through the STM32
UART bootloader. It is free to download, but it is proprietary ST software and
is therefore not bundled or redistributed by FullVision.

### Download from STMicroelectronics

1. Open the official
   [STM32CubeProgrammer download page](https://www.st.com/en/development-tools/stm32cubeprog.html).
2. Find the **Get Software** or installer section and choose the current package
   for your operating system. On Windows, normally choose **Windows 64-bit**.
   On a Mac, choose ST's macOS package for Apple Silicon/ARM64 or Intel when ST
   presents separate downloads.
3. Sign in to a free **myST** account, or create one, if the ST website asks.
4. Complete any required download details and accept ST's software-license and
   export-control terms.
5. Download the STM32CubeProgrammer ZIP package when ST makes it available.

The wording and current version number on ST's website can change. Always use
the latest compatible installer offered on the official page; FullVision does
not require the STM32CubeProgrammer version number to match STM32duino 2.12.0.

### Install on Windows

1. Open the downloaded ZIP and extract all of its contents to a normal folder.
   Do not run the installer from inside the ZIP preview.
2. Close Arduino IDE.
3. Run the included `SetupSTM32CubeProgrammer-...exe` installer. Approve the
   Windows administrator prompt if one appears.
4. Accept ST's license and keep the default installation location unless there
   is a specific reason to change it.
5. Make sure the main STM32CubeProgrammer application and its command-line
   tools are installed. The optional Trusted Package Creator is not required
   for normal FullVision uploads.
6. Finish the installer. Restart Windows only if the installer requests it.

### Install on macOS

1. Extract the complete STM32CubeProgrammer ZIP package downloaded from ST.
2. Close Arduino IDE.
3. Double-click the included `SetupSTM32CubeProgrammer-...app` installer.
4. Approve the macOS administrator prompt, accept ST's license, and keep the
   default installation location.
5. Install the main application and command-line tools. The optional Trusted
   Package Creator is not required for normal FullVision uploads.
6. If double-clicking the installer fails, follow ST's documented workaround:
   Control-click the installer, choose **Show Package Contents**, open
   `Contents/MacOS`, and launch the installer executable located there.
7. Finish the installer, then return to `install-macos.command` and press
   Return so it can check the installation.

ST's complete platform-specific procedure is available in the currently
published
[official STM32CubeProgrammer installation guide](https://dev.st.com/stm32cube-docs/prog/2.23.0/en/docs/markup/CubeProg_How_To_Start/CubeProg_Installation.html).

### Confirm that Windows can find it

The normal 64-bit Windows installation contains this file:

```text
C:\Program Files\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe
```

After installation:

1. Run `install-windows.bat` again.
2. Confirm that it prints **Found STM32CubeProgrammer** followed by a path.
3. Reopen Arduino IDE and select the FullVision board and the controller's COM
   port.

If the installer still cannot find STM32CubeProgrammer, confirm that
`STM32_Programmer_CLI.exe` exists in the folder above. Reinstall using ST's
default location if it is missing. If it was intentionally installed elsewhere,
add its `bin` folder to the Windows `PATH`, close the existing Command Prompt,
and rerun the FullVision installer from a new window.

### Confirm that macOS can find it

The normal macOS installation contains this file:

```text
/Applications/STMicroelectronics/STM32Cube/STM32CubeProgrammer/STM32CubeProgrammer.app/Contents/MacOs/bin/STM32_Programmer_CLI
```

After installation, return to the open Mac installer and press Return. It
should print **Found STM32CubeProgrammer** followed by the path above. If it
does not, reinstall STM32CubeProgrammer using ST's default location and run
`install-macos.command` again.

### CH340G and driver clarification

The FullVision board uploads through a CH340G-style USB-to-serial connection.
Open **Windows Device Manager > Ports (COM & LPT)** and confirm that connecting
the board creates a COM port. If no port appears, resolve the CH340G driver,
USB-cable, USB-port, or board-power issue before trying Arduino again.

On macOS, check **Arduino IDE > Tools > Port**. A CH340G adapter commonly
appears with a name beginning `/dev/cu.usbserial` or `/dev/cu.wchusbserial`.
If no new port appears when the board is connected, try a known data-capable
USB cable and another USB port before installing any additional driver.

The STM32CubeProgrammer **USB DFU** and **ST-LINK** drivers are not required for
this CH340G/UART upload method. They are only needed when using their respective
USB DFU or ST-LINK interfaces. The Arduino **Native CDC** setting controls the
sketch's runtime `Serial` interface; it does not replace the CH340G bootloader
COM port used during programming.

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

The release also includes `restore-official-windows.bat` for Windows and
`remove-fullvision-macos.command` for macOS. Each removes only the FullVision
package and does not modify the official STM32duino installation.

## Uploading through USB-to-serial

For STM32CubeProgrammer serial upload, place the board in its serial bootloader
mode before uploading. On boards with BOOT0 and reset controls, the usual flow
is:

1. Set or hold BOOT0 high.
2. Reset or power-cycle the controller.
3. Confirm that the correct COM or macOS serial port is selected.
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
- [macOS installation guide](MACOS_INSTALL.md)
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
