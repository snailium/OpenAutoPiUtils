# Utilities for Open (Android) Auto on Raspberry Pi

My goal is to improve my Raspberry Pi headunit. Here are scripts and tweaks I used.

## Additional Hardware Requirement

+ **Arduino board**: I'm using a third-party Arduino Uno compatible board.
+ **Photoresistor**: I'm using [SeeedStudio expension board + photoresistor](https://www.seeedstudio.com/Grove-Starter-Kit-for-Arduino-p-1855.html), connected to A0.

### Arduino vs GrovePi+

SeeedStudio also provides an option to expend analog ports - [GrovePi+](https://www.seeedstudio.com/GrovePi%2B-p-2241.html). Basically, it is an Arduino board sitting on top of Raspberry Pi, and requires Arduino IDE installed. Personally, I have no luck with installing Java SDK (which is one of Arduino IDE's dependencies) on Crankshaft image. But if it works, GrovePi+ may be a better choice since its much smaller than an Arduino board plus shield.

## Utilities

### Automatically adjust screen brightness

Driving with full screen brightness at night is annoying and distracting. So I need the screen brightness adjusted based on light readings. Unfortunately, Raspberry Pi doesn't have an ADC, so I cannot use a photoresistor directly. That's why I added the Arduino to this project - to use its ADC and other shields.

In this setup, Arduino takes light reading, and output the value to Raspberry Pi. And the Pi sets screen brightness based on the reading. I also added some intelligence into the Pi script. Make it wait for Arduino connected before each reading.

## How to Use

Currently, I'm waiting for Huan to provide a generic place to put startup script. I'll update this section later.

### Arduino IDE or Visual Studio

It doesn't really matter. Both of them needs to be setup with Arduino/Genuino UNO board. Just compile and upload.

## Other Facts

+ I'm not a Python user. So don't expect any Python script. I'm also avoiding any expension board with only Python code provided.
+ I'm slowly updating scripts and adding more features. I don't have much spare time at this moment.
+ I'm releasing these codes for free. No license attached at this moment. Probably I'll add MIT license at some point, when I have time.

## Thanks

+ [OpenAuto](https://forum.xda-developers.com/android-auto/android-auto-general/release-openauto-source-androidautotm-t3748563?nocache=1) by Michal Szwaj (f1xpl). [GitHub](https://github.com/f1xpl/openauto)
+ [Crankshaft](http://getcrankshaft.com/) by Huan Truong (htruong). [GitHub](https://github.com/htruong/crankshaft)
