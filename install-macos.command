#!/bin/bash

set -u

FV_CORE_ID="FullVision:stm32"
FV_CORE_VERSION="1.5.0"
FV_FULLVISION_INDEX="https://github.com/aj-morales99/FullVision-STM32V1.5/releases/download/v1.5.0/package_fullvision_index.json"
FV_STM32_INDEX="https://github.com/stm32duino/BoardManagerFiles/raw/main/package_stmicroelectronics_index.json"
FV_ARDUINO_DOWNLOAD="https://www.arduino.cc/en/software"
FV_CUBE_DOWNLOAD="https://www.st.com/en/development-tools/stm32cubeprog.html"
FV_CLI_VERSION="1.5.1"
FV_LOCAL_TOOLS="$HOME/Library/Application Support/FullVision/tools"
FV_TEMP_DIR=""
FV_ARDUINO_IDE=""
FV_ARDUINO_CLI=""
FV_CUBE_CLI=""

cleanup() {
  if [ -n "$FV_TEMP_DIR" ] && [ -d "$FV_TEMP_DIR" ]; then
    rm -rf -- "$FV_TEMP_DIR"
  fi
}

pause_if_interactive() {
  if [ -t 0 ]; then
    printf "Press Return to close this window..."
    read -r _fv_unused
  fi
}

fail() {
  printf "\nERROR: %s\n" "$1" >&2
  printf "FullVision setup was not completed.\n" >&2
  printf "The official STMicroelectronics STM32 package was not changed.\n\n" >&2
  pause_if_interactive
  exit 1
}

find_arduino_ide() {
  FV_ARDUINO_IDE=""
  for candidate in \
    "/Applications/Arduino IDE.app" \
    "$HOME/Applications/Arduino IDE.app"; do
    if [ -d "$candidate" ]; then
      FV_ARDUINO_IDE="$candidate"
      return 0
    fi
  done
  return 1
}

find_arduino_cli() {
  FV_ARDUINO_CLI=""

  if command -v arduino-cli >/dev/null 2>&1; then
    FV_ARDUINO_CLI="$(command -v arduino-cli)"
    return 0
  fi

  for candidate in \
    "/Applications/Arduino IDE.app/Contents/Resources/app/lib/backend/resources/arduino-cli" \
    "$HOME/Applications/Arduino IDE.app/Contents/Resources/app/lib/backend/resources/arduino-cli" \
    "$FV_LOCAL_TOOLS/arduino-cli/arduino-cli"; do
    if [ -x "$candidate" ]; then
      FV_ARDUINO_CLI="$candidate"
      return 0
    fi
  done
  return 1
}

install_arduino_cli() {
  local machine archive checksum url actual extract_dir target_dir
  machine="$(uname -m)"

  case "$machine" in
    arm64)
      archive="arduino-cli_${FV_CLI_VERSION}_macOS_ARM64.tar.gz"
      checksum="cb952e8c1621c95ef5f1d17831c945e3d0ec5973f89c557a7ec8feb9c4f7d4c9"
      ;;
    x86_64)
      archive="arduino-cli_${FV_CLI_VERSION}_macOS_64bit.tar.gz"
      checksum="c982e940027996bea9901050e95fae99c59c1dcfee54beedecaf28141e7bf2e7"
      ;;
    *)
      fail "Unsupported Mac architecture: $machine"
      ;;
  esac

  url="https://github.com/arduino/arduino-cli/releases/download/v${FV_CLI_VERSION}/${archive}"
  FV_TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/fullvision-cli.XXXXXX")" ||
    fail "Could not create a temporary directory."
  extract_dir="$FV_TEMP_DIR/extracted"
  target_dir="$FV_LOCAL_TOOLS/arduino-cli"
  mkdir -p "$extract_dir" "$target_dir" ||
    fail "Could not create the FullVision tools directory."

  printf "Downloading the official Arduino CLI %s for %s...\n" "$FV_CLI_VERSION" "$machine"
  curl --fail --location --progress-bar "$url" -o "$FV_TEMP_DIR/$archive" ||
    fail "Could not download Arduino CLI."

  actual="$(shasum -a 256 "$FV_TEMP_DIR/$archive" | awk '{print $1}')"
  if [ "$actual" != "$checksum" ]; then
    fail "Arduino CLI checksum verification failed."
  fi

  tar -xzf "$FV_TEMP_DIR/$archive" -C "$extract_dir" ||
    fail "Could not extract Arduino CLI."
  if [ ! -f "$extract_dir/arduino-cli" ]; then
    fail "The Arduino CLI archive did not contain the expected executable."
  fi

  cp "$extract_dir/arduino-cli" "$target_dir/arduino-cli" ||
    fail "Could not install Arduino CLI."
  chmod 755 "$target_dir/arduino-cli" ||
    fail "Could not make Arduino CLI executable."
  FV_ARDUINO_CLI="$target_dir/arduino-cli"
}

find_cube_programmer() {
  FV_CUBE_CLI=""

  if command -v STM32_Programmer_CLI >/dev/null 2>&1; then
    FV_CUBE_CLI="$(command -v STM32_Programmer_CLI)"
    return 0
  fi

  for candidate in \
    "/Applications/STMicroelectronics/STM32Cube/STM32CubeProgrammer/STM32CubeProgrammer.app/Contents/MacOs/bin/STM32_Programmer_CLI" \
    "$HOME/Applications/STMicroelectronics/STM32Cube/STM32CubeProgrammer/STM32CubeProgrammer.app/Contents/MacOs/bin/STM32_Programmer_CLI"; do
    if [ -x "$candidate" ]; then
      FV_CUBE_CLI="$candidate"
      return 0
    fi
  done
  return 1
}

trap cleanup EXIT HUP INT TERM

printf "\nFullVision STM32 V1.5 macOS setup\n"
printf "=================================\n"
printf "This installs FullVision as an independent Arduino package.\n"
printf "Official STMicroelectronics STM32 boards will not be replaced or downgraded.\n\n"

case "$(uname -m)" in
  arm64|x86_64) ;;
  *) fail "This installer supports Apple Silicon and 64-bit Intel Macs only." ;;
esac

if pgrep -f "/Arduino IDE.app/" >/dev/null 2>&1 || pgrep -x "Arduino IDE" >/dev/null 2>&1; then
  fail "Close Arduino IDE completely and run this installer again."
fi

printf "[1/5] Checking Arduino IDE 2...\n"
if ! find_arduino_ide; then
  printf "Arduino IDE 2 was not found.\n"
  printf "The official Arduino download page will now open.\n"
  open "$FV_ARDUINO_DOWNLOAD" || fail "Could not open the Arduino download page."
  printf "Download Arduino IDE 2 for your Mac, open the DMG, and drag Arduino IDE to Applications.\n"
  printf "After installation, return to this Terminal window.\n"
  if [ -t 0 ]; then
    printf "Press Return after Arduino IDE 2 has been installed..."
    read -r _fv_unused
  fi
  find_arduino_ide || fail "Arduino IDE 2 is still not installed in Applications."
fi
printf "Found Arduino IDE: %s\n\n" "$FV_ARDUINO_IDE"

printf "[2/5] Checking Arduino CLI...\n"
if ! find_arduino_cli; then
  install_arduino_cli
fi
printf "Found Arduino CLI: %s\n" "$FV_ARDUINO_CLI"
"$FV_ARDUINO_CLI" version || fail "Arduino CLI could not run."
printf "\n"

printf "[3/5] Installing independent FullVision board package...\n"
"$FV_ARDUINO_CLI" core update-index \
  --additional-urls "$FV_FULLVISION_INDEX,$FV_STM32_INDEX" ||
  fail "Could not download the FullVision and STM32 tool indexes."
"$FV_ARDUINO_CLI" core install "$FV_CORE_ID@$FV_CORE_VERSION" \
  --additional-urls "$FV_FULLVISION_INDEX,$FV_STM32_INDEX" ||
  fail "Could not install the independent FullVision package."
printf "\n"

printf "[4/5] Checking STM32CubeProgrammer...\n"
if ! find_cube_programmer; then
  printf "STM32CubeProgrammer is required for serial upload but was not found.\n"
  printf "ST requires each user to accept its license and export-control terms.\n"
  printf "The official ST download page will now open.\n"
  open "$FV_CUBE_DOWNLOAD" || fail "Could not open the STM32CubeProgrammer page."
  printf "Download the macOS package, extract it, and run the included installer app.\n"
  printf "Keep the default installation location, then return to this Terminal window.\n"
  if [ -t 0 ]; then
    printf "Press Return after STM32CubeProgrammer has been installed..."
    read -r _fv_unused
  fi
  find_cube_programmer ||
    fail "STM32CubeProgrammer is still missing from its default Applications location."
fi
printf "Found STM32CubeProgrammer: %s\n\n" "$FV_CUBE_CLI"

printf "[5/5] Verifying installed board packages...\n"
"$FV_ARDUINO_CLI" core list || fail "Could not verify installed board packages."

printf "\nSUCCESS: %s@%s is installed.\n" "$FV_CORE_ID" "$FV_CORE_VERSION"
printf "Official STMicroelectronics STM32 boards were not changed.\n\n"
printf "Open Arduino IDE and select:\n"
printf "  FullVision-STM32 V1.5 (STM32duino 2.12.0)\n\n"
printf "Required defaults:\n"
printf "  MCU: STM32F103C8T6 Blue Pill (64 KB flash)\n"
printf "  Upload: STM32CubeProgrammer (Serial)\n"
printf "  USB support: CDC (generic Serial supersedes U(S)ART)\n"
printf "  USB speed: Low/Full Speed\n"
printf "  U(S)ART support: Enabled (generic Serial)\n"
printf "  Optimize: Smallest (-Os default)\n"
printf "  Debug symbols and core logs: None\n"
printf "  C Runtime Library: Newlib Nano (default)\n\n"
pause_if_interactive
exit 0
