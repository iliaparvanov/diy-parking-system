#include <AltSoftSerial.h>
#include <NewPing.h>

// Left distance sensor pins
// Trigger sends an ultrasound wave and the distance can be measured by taking the duration of the HIGH impulse on echo pin
#define trigger_pin 2
#define echo_pin 3

int distance_left;

// RX and TX pins for bluetooth module communication
AltSoftSerial BTserial(8, 9);

// 450 (cm) is the max distance the sensor can measure
NewPing sonar = NewPing(trigger_pin, echo_pin, 450);

void setup() { 
  Serial.begin(9600);
  BTserial.begin(9600); 
}
void loop() {
  delay (50);
  distance_left = sonar.convert_cm(sonar.ping_median()); // Send a ping, returns the distance in centimeters or 0 (zero) if no ping echo within set distance limit (from docs)

  char buffer[20];
  itoa(distance_left, buffer, 10);
  // Send measurement to BT module
  BTserial.write("l");
  BTserial.write(buffer);
  
  // Send measurement to serial monitor
  Serial.print("DLeft distance = ");
  Serial.print(distance_left);
  Serial.println(" cm");
}
