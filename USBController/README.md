# cc-franz
This is part of the CC-Franz Project

Implemented by Stefan Seibert at Stuttgart Media University in Summer 2015
as part of the class "Embedded Systems" from Thomas Maier.

You will find two subfolders:

/USB-Shield
This subfolder contains the AVR based project code to use the
USB Host Shield with MAX3421 chip in combination with a AVR
ATmega328p without the need of the Arduino Development Framework.
The Code can be compiled with AVR-GCC by using the provided makefile.
It is configured to send the Input Data of a HID Gamecontroller via UART

Files in USB_Shield originated or extended from Stefan Seibert, comments in files also:
/utils.h + /utils.c - For sending data or debug information via UART
/usb_wifi.cpp - main file, for initiation of USB Protocol and sending commands
/hidjoystickrptparser.h + /hidjoystickrptparser.cpp - modified and extended to handle input correctly

/WebSocket_Client
this is the firmware for a websocket client for the ESP8266 WIFI module
It needs the esp_open_sdk (https://github.com/pfalcon/esp-open-sdk) 
for being compiled correctly. It can be compiled to flash the ESP8266.
It is configured to send the via UART received USB Control Data 
as WebSocket Messages.

Files in WebSocket_Client originated from Stefan Seibert, comments in files also:
/user/user_main.c - firmware main file for creating a HTTP Server in ESP8266
/user/websocketd.h + /user/websocketd.c - For creating a Websocket Connection as Server extended
from a old version from Daniel Grießhaber where WebSocket worked as client not as server.


HID Based Game Controller
=====================

Used Data for Events:

X = 1 A = 2 B = 3 Y = 4  L = 5 R = 6 Select = 9 Start = 10
Kreuz Links: Z2 = 0 Kreuz Rechts: Z2 = 255 
Kreuz Oben: Rz = 0 Kreuz Unten: Rz = 255
Start = Rotation und Move auf 0 
Kreuz links/rechts = Move -/+ 
Kreuz hoch/runter = Rotation -/+  

A = Move Speed 255/8
B = Move Speed 255/2
Y = Rotate Speed 255/8
X = Rotate Speed 255

L = Speed -2 R = Speed +2  

