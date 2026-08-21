# FullVision STM32 core notes

This repository is a fork of [STM32Duino Arduino_Core_STM32](https://github.com/stm32duino/Arduino_Core_STM32).
The original licensing terms remain in [License.md](License.md) and in the upstream source-file headers.

## FullVision change: SoftwareSerial timer

The Blue Pill and Black Pill STM32F103C8/CB variants share
`variants/STM32F1xx/F103C8T_F103CB(T-U)/variant_PILL_F103Cx.h`.

FullVision reserves `TIM1` for `SoftwareSerial` by defining:

```cpp
#define TIMER_SERIAL TIM1
```

The upstream `SoftwareSerial` implementation continues to use
`HardwareTimer SoftwareSerial::timer(TIMER_SERIAL);`; the override is therefore
limited to these board variants rather than changing timer selection for every
STM32 family.

### Timer allocation

| Timer | FullVision role |
| --- | --- |
| TIM1 | SoftwareSerial (Bluetooth, RC receiver, or IR input) |
| TIM2-TIM4 | Motor PWM / custom frequency control |

Do not allocate `TIM1` to PWM, Servo, Tone, or a separate `HardwareTimer` in a
FullVision sketch that uses `SoftwareSerial`.

## Supported target for the first release

- STM32F103C8T6 with the guaranteed 64 KB flash limit
- FullVision Blue Pill layout

The release is based on the upstream STM32duino 2.12.0 tag because that is the
version already proven with the FullVision application. Other board selections
are removed from `boards.txt`, while dependency source files remain intact so
the Arduino platform continues to compile correctly.
