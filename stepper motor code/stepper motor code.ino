#include <Stepper.h>

const int stepsPerRevolution = 32;  
int motor_speed = 150;
int speed = 0;
int menuChoice=2;
int savedMenuChoice=40;
float Q = 0.000001;
float r = 0.005;
const float pi = 3.14;
Stepper myStepper(stepsPerRevolution, 8, 9, 10, 11);

void setup() {
  float velocity_in_mps= Q/(pi* r* r);
  float velocity_in_rpm= (60 * velocity_in_mps) / (2 * pi * r);
  velocity_in_rpm= int(velocity_in_rpm);
  // myStepper.setSpeed(velocity_in_rpm);
  Serial.begin(9600);
   Serial.println(velocity_in_rpm);
}

void loop() {
  // motor_speed = read_speed();
  // myStepper.setSpeed(motor_speed);

  //reading input, I guess

  if(Serial.available()!=0){
   menuChoice = Serial.parseInt();
   if(menuChoice!=0){
   savedMenuChoice= menuChoice;
   }
  }
  else{
    menuChoice= savedMenuChoice;
  }
  Serial.println(menuChoice);
  // step one for one direction:
  Serial.println("clockwise");
  if (menuChoice==0){
    menuChoice= savedMenuChoice;
  }
  myStepper.setSpeed(menuChoice);
  myStepper.step(stepsPerRevolution);
  delay(400);

  // step one for other direction:
  Serial.println("counterclockwise");
  myStepper.step(-stepsPerRevolution);
  delay(400);
}


