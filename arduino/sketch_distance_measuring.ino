#include <AltSoftSerial.h>
#include <NewPing.h>

// Left distance sensor pins
// Trigger sends an ultrasound wave and the distance can be measured by taking the duration of the HIGH impulse on echo pin
#define trigger_pin_l 2
#define echo_pin_l 3
#define trigger_pin_r 4
#define echo_pin_r 5
#define trigger_pin_cr 6
#define echo_pin_cr 7
#define trigger_pin_cl 10
#define echo_pin_cl 11

int distance_left;

// RX and TX pins for bluetooth module communication
AltSoftSerial BTserial(8, 9);

// 450 (cm) is the max distance the sensor can measure
NewPing sonar_l = NewPing(trigger_pin_l, echo_pin_l, 300);
NewPing sonar_cl = NewPing(trigger_pin_cl, echo_pin_cl, 300);
NewPing sonar_cr = NewPing(trigger_pin_cr, echo_pin_cr, 300);
NewPing sonar_r = NewPing(trigger_pin_r, echo_pin_r, 300);


void setup() { 
  Serial.begin(9600);
  BTserial.begin(9600); 
}
void loop() {
  distance_left = sonar_l.convert_cm(sonar_l.ping_median()); // Send a ping, returns the distance in centimeters or 0 (zero) if no ping echo within set distance limit (from docs)

  int distance_center_left = sonar_cl.convert_cm(sonar_cl.ping_median());

  int distance_center_right = sonar_cr.convert_cm(sonar_cr.ping_median());

  int distance_right = sonar_r.convert_cm(sonar_r.ping_median());



  char buffer[20];
  itoa(distance_left, buffer, 10);
  // Send measurement to BT module
  String distance_left_string = "";
  BTserial.write('l');
  BTserial.write(buffer);

  itoa(distance_center_left, buffer, 10);
  // Send measurement to BT module
  BTserial.write("cu");
  BTserial.write(buffer);

  itoa(distance_center_right, buffer, 10);
  // Send measurement to BT module
  BTserial.write("cd");
  BTserial.write(buffer);
  
  itoa(distance_right, buffer, 10);
  // Send measurement to BT module
  BTserial.write("r");
  BTserial.write(buffer);
 
}