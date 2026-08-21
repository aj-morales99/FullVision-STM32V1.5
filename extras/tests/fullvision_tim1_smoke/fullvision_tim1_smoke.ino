#include <Arduino.h>
#include <HardwareTimer.h>
#include <SoftwareSerial.h>

// Compile smoke test for the FullVision timer allocation:
// TIM1 = SoftwareSerial, TIM2-TIM4 = motor PWM timers.
SoftwareSerial Bluetooth(PB7, PB6);
HardwareTimer MotorTimer2(TIM2);
HardwareTimer MotorTimer3(TIM3);
HardwareTimer MotorTimer4(TIM4);

void setup()
{
  Serial.begin(115200);
  Bluetooth.begin(9600);
}

void loop()
{
  while (Bluetooth.available()) {
    const int received = Bluetooth.read();
    if (received >= 0) {
      Serial.write(static_cast<uint8_t>(received));
    }
  }
}
