/*
Name:		Arduino.ino
Created:	2018/4/15 3:35:08
Author:		snailium
*/

// Initialize the variables
int lightPin = 0; // Use A0
int lightLevel;

// the setup function runs once when you press reset or power the board
void setup() {
  // One-time setup. 9600 is a value that is called the "baud rate"
  Serial.begin(9600);
}

// the loop function runs over and over again until power down or reset
void loop() {
  // Collect a data point
  lightLevel=analogRead(lightPin);

  // Send the adjusted Light level result to Serial port
  Serial.println(lightLevel);

  // Slow down the transmission to keep the call-stack down. 500ms!
  delay(500);
}
