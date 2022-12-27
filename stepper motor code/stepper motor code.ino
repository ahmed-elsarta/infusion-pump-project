#include <Stepper.h>
#include "SoftwareSerial.h"
#define USE_ARDUINO_INTERRUPTS true
SoftwareSerial bluetooth(0, 1);  // bluetooth(Tx, Rx)

const int stepsPerRevolution = 32;
int motor_speed = 80;
int saved_speed = 40;
// float Q = 0.000001;
// float r = 0.005;
Stepper myStepper(stepsPerRevolution, 8, 9, 10, 11);

void setup() {
  // float velocity_in_mps = Q / (Math.pi * r * r);
  // float velocity_in_rpm = (60 * velocity_in_mps) / (2 * pi * r);
  // velocity_in_rpm = int(velocity_in_rpm);
  // myStepper.setSpeed(velocity_in_rpm);
  //  Serial.println(velocity_in_rpm);
  Serial.begin(9600);
}

void loop() {
  transferBluetoothData();
  checkHeartRate();
  controlStepperMotor();
}

void transferBluetoothData(){
  // Bluetooth App to Arduino Terminal
  if (bluetooth.available()) Serial.write(bluetooth.read());
  //Arduino Termial to Bluetooth App
  if (Serial.available()) bluetooth.write(Serial.read());  
}

void controlStepperMotor() {
  Serial.println("Motor Speed:" + String(motor_speed));
  Serial.println("Saved Motor Speed:" + String(saved_speed));

  //reading input, I guess
  if (Serial.available() != 0) {
    motor_speed = Serial.parseInt();
    if (motor_speed != 0) {
      saved_speed = motor_speed;
    }
  } else {
    motor_speed = saved_speed;
  }

  if (motor_speed == 0) {
    motor_speed = saved_speed;
  }

  // Moving the motor forward
  myStepper.setSpeed(motor_speed);
  myStepper.step(-stepsPerRevolution);
}

void checkHeartRate() {
  // Heart Rate measured by the sensor
  int heartRate = (analogRead(0) / 8);

  // Print to send to the app
  Serial.println(heartRate);

  // Heart Rate cases
  if (heartRate < 50) {
    myStepper.setSpeed(100);
  }

  else if (heartRate > 120) {
    myStepper.setSpeed(80);
  }

  else {
    myStepper.setSpeed(40);
  }

  delay(200);
}