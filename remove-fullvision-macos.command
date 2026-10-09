#!/bin/bash

set -u

FV_CORE_ID="FullVision:stm32"
FV_LOCAL_CLI="$HOME/Library/Application Support/FullVision/tools/arduino-cli/arduino-cli"
FV_ARDUINO_CLI=""

pause_if_interactive() {
  if [ -t 0 ]; then
    printf "Press Return to close this window..."
    read -r _fv_unused
  fi
}

fail() {
  printf "\nERROR: %s\n" "$1" >&2
  printf "FullVision removal was not completed.\n\n" >&2
  pause_if_interactive
  exit 1
}

find_arduino_cli() {
  if command -v arduino-cli >/dev/null 2>&1; then
    FV_ARDUINO_CLI="$(command -v arduino-cli)"
    return 0
  fi

  for candidate in \
    "/Applications/Arduino IDE.app/Contents/Resources/app/lib/backend/resources/arduino-cli" \
    "$HOME/Applications/Arduino IDE.app/Contents/Resources/app/lib/backend/resources/arduino-cli" \
    "$FV_LOCAL_CLI"; do
    if [ -x "$candidate" ]; then
      FV_ARDUINO_CLI="$candidate"
      return 0
    fi
  done
  return 1
}

printf "\nRemove FullVision STM32 from macOS\n"
printf "==================================\n"
printf "This removes only %s.\n" "$FV_CORE_ID"
printf "Official STMicroelectronics STM32 boards will not be changed.\n\n"

if pgrep -f "/Arduino IDE.app/" >/dev/null 2>&1 || pgrep -x "Arduino IDE" >/dev/null 2>&1; then
  fail "Close Arduino IDE completely before removing FullVision."
fi

find_arduino_cli || fail "Arduino CLI was not found."

if ! "$FV_ARDUINO_CLI" core list | awk 'NR > 1 {print $1}' | grep -Fx "$FV_CORE_ID" >/dev/null 2>&1; then
  printf "FullVision is not currently installed. Nothing was changed.\n\n"
  pause_if_interactive
  exit 0
fi

if [ -t 0 ]; then
  printf "Remove the FullVision STM32 board package? [y/N] "
  read -r answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *)
      printf "Removal cancelled. Nothing was changed.\n\n"
      pause_if_interactive
      exit 0
      ;;
  esac
fi

"$FV_ARDUINO_CLI" core uninstall "$FV_CORE_ID" ||
  fail "Arduino CLI could not uninstall FullVision."

printf "\nSUCCESS: FullVision was removed. Official STM32 boards were untouched.\n\n"
pause_if_interactive
exit 0
