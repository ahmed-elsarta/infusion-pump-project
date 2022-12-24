#include <Stepper.h>

const int stepsPerRevolution = 32;  
int motor_speed = 100;
int speed = 0;
Stepper myStepper(stepsPerRevolution, 8, 9, 10, 11);

void setup() {
  myStepper.setSpeed(motor_speed);
  Serial.begin(9600);
}

void loop() {
  // motor_speed = read_speed();
  // myStepper.setSpeed(motor_speed);

  // step one for one direction:
  Serial.println("clockwise");
  myStepper.step(stepsPerRevolution);
  delay(400);

  // step one for other direction:
  Serial.println("counterclockwise");
  myStepper.step(-stepsPerRevolution);
  delay(400);
}


