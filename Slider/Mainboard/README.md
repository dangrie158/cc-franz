###Electrical Engineering

#####BOM (What you need)

| Qty | Device                 | Package | Value  | Parts                                       | Description      |
|-----|------------------------|---------|--------|---------------------------------------------|------------------|
| 2   | A4988                  | DIP     | –      | U3, U4                                      |                  |
| 1   | ¼W Resistor            | 0207    | 100 kΩ | R15                                         |                  |
| 1   | Potentiometer          | CA9V    | 100 kΩ | R16                                         |                  |
| 8   | Ceramic Capacitor      | C050    | 100 nF | C1, C2, C4, C5, C6, E13, E14, E15           |                  |
| 2   | Electrolytic Capacitor | CA9V    | 100 µF | C4, C8                                      |                  |
| 5   | ¼W Resistor            | 0207    | 100 Ω  | R3, R4, R10, R11, R12                       |                  |
| 8   | ¼W Resistor            | 0207    | 10 kΩ  | R1, R2, R5, R6, R7, R8, R9, R14             |                  |
| 2   | Electrolytic Capacitor | CA9V    | 10 µF  | C3, C16                                     |                  |
| 1   | Power Check            | –       | –      | JP1                                         |                  |
| 1   | Crystal Oscillator     | HC49    | 16 MHz | Q1                                          |                  |
| 1   | Diode                  | DO41    | –      | D2                                          |                  |
| 4   | Electrolytic Capacitor | CA9V    | 1 µF   | C9, C10, C11, C12                           |                  |
| 2   | Ceramic Capacitor      | C050    | 22 pF  | C17, C18                                    |                  |
| 1   | LM33CV                 | TO22    | –      | IC2                                         |                  |
| 1   | 8705                   | TO22    | –      | IC1                                         |                  |
| 1   | Atmega328P             | DIL28   | –      | U1                                          |                  |
| 2   | BC337                  | TO92    | –      | T1, T2                                      | NPM Transistor   |
| 1   | 2 Pole Connector       | –       | –      | IROUT                                       |                  |
| 1   | 3 Pole Connector       | –       | –      | ENDSTOP                                     |                  |
| 3   | 4 Pole Connector       | –       | –      | MOT1, MOT2, RS232                           |                  |
| 1   | 2x3 Pin Header         | –       | –      | ICSP                                        |                  |
| 2   | 3 Channel DIP switch   | –       | –      | MSMOT1, MSMOT2                              |                  |
| 1   | ESP8266                | –       | –      | U5                                          |                  |
| 1   | LM358                  | DIL08   | –      | IC3                                         | jelly bean Opamp |
| 1   | MAX232                 | DIL16   | –      | U2                                          |                  |
| 1   | 5mm LED                | –       | –      | D1                                          |                  |
| 6   | Tactile Button         | –       | –      | HOMING, LEFT, RIGHT, TILTCCW, TILTCW, RESET |                  |

Total costs for electrical parts: <br />
**~ 39,33€ + shipping fees**

#####Schematic
<img src="https://raw.githubusercontent.com/dangrie158/cc-franz/develop/Docs/Images/schematic.png" alt="" style="width: 380px;"/> 

We designed the schematic modular to get a good overview of the whole system and work independently on single modules. 

######Microcontroller (not labeled, the part in the center)
For the brain of our slider we’ve chosen an ATMEGA 328 from Atmel. The reason for this simply was the huge amount of information and tutorials out there for this chip. This is the same chip you have on the Arduino Uno, the one you may have in your parts bin.  Just for kicks (and maybe also because this was a requirement by our lecturer) we did not use the Arduino bootloader or libraries and programmed the chip directly through the ISP interface. <br />
The chip has an whopping 32kB of Flash and 2kB of RAM.

######Powersupply
For the operation of the Camera Slider we need 3 different voltage rails: +12V for the motors, +5V for the microcontroller and as a main logic level and +3.3V as the WiFi module supply voltage.<br />
The +12V line is directly connected to the main power jack, which is supplied by an external plug pack. The +12V are only fed through a diode to protect the circuit from reverse polarization, which results in a small voltage drop of about the typical 0.7V.
For the +5V a linear 7805 voltage regulator was used, which turns any input voltage from +7V - +35V into a regulated +5V. The aforementioned is accomplished by burning all the extra energy and turning it into heat. During normal operation our slider consumes about 300mA on the +5V rail and therefore the energy of

<img src="https://raw.githubusercontent.com/dangrie158/cc-franz/develop/Docs/Images/formula_1.png" alt="" style="width: 60%"/> 

heat needs to be dissipated. For that reason we attached a small heatsink to the voltage regulator. <br />
The 3.3V rail is also regulated by a linear regulator, but this time with another output voltage. The input voltage comes from the +5V line, which means that the 7805 needs to supply the current for the +3.3V rail as well. However, directly attaching the regulator to the 12V would mean that it needs to dissipate all the power down to the 3.3V, wich would result in a drop voltage of 12V - 3.3V = 8.7V. This way, the heat is spread across the two regulators.

######ICSP & Reset Circuit
The ICSP connector is needed to program the ATMEGA microcontroller. It is a simple SPI bus with power supply and a connection to the RESET pin of the controller. To flash the controller, the programmer needs to set the RESET pin low and therefore keeps the microcontroller in its reset state during the flashing process. To start the microcontroller, one needs to keep the RESET pin high. For this reason the RESET pin is connected to the 5V rail with a 10kΩ pull-up resistor. <br />
For manually resetting the controller, we also added a switch to pull the pin low. 

######Motor Controller (x2)
To drive the motors, we used 2 A4988 motor drivers. They handle all the complex driving and enable us to microstep the motors, which results in an up to 16x higher resolution to drive the motor. <br />
The microstepping setting is not subject to change during operation. However, to be able to set the bits manually we simply added a 3 pole DIP switch to each driver which allows us to change the setting after laying out the board.<br />
One could also hard-wire the setting in the same board layout by not populating the switches, but solder in the connections directly.
The microcontroller can make the motor step (or microstep) by toggling the STEP pin of the controller for at least 1µs. The changing edge (HIGH to LOW or LOW to HIGH) doesn’t matter. The direction of the motor is controlled by setting the DIR pin HIGH or LOW.

######Endstop Amplifier
Designing the mechanical construction, we realized that it would be nice to detect a special position of the linear axis to have a known reference point we could align the axis reference system to. Of course, the simplest way to implement such a feature would be a simple switch with a small lever which gets pressed when the axis moves past a threshold at the end of the axis. However, the simplest solution always is the most boring solution, and since this is a project where we wanted to learn something, we have chosen a more sophisticated and nicer way instead.
The solution should be opto electrical by using a photocell to detect the threshold position. The output of the photocell is analog and we quickly realized that photocells are not very stable in variable lighting conditions, and since we wanted to be able to use the slider during day- and nighttime we needed a way to amplify the cells return value. <br />
To convert the analog signal into a digital, binary one, we could have used a schmitt trigger with a matching threshold voltage, but back then we did not know what this threshold voltage would be. For this reason we implemented the schmitt trigger using an opamp and a precision 10 turn resistor to set the threshold.

<img src="https://raw.githubusercontent.com/dangrie158/cc-franz/develop/Docs/Images/opamp_standart_config.png" alt="" style="width: 380px;"/>

The LM358 is used in inverting amplification mode. While the voltage at the negative (inverting) input of the opamp is lower than the voltage at the positive (non-inverting)  input, the opamp drives its output high. <br />
R1 is the feedback resistor that mixes the output signal back into the non-inverting input. R2 and the variable resistor R5 form a voltage divider which sets the voltage of the non inverting input (ignoring the feedback for a moment). The voltage at the input of the opamp 

<img src="https://raw.githubusercontent.com/dangrie158/cc-franz/develop/Docs/Images/formula_2.png" alt="" style="width: 40%"/>.

If we now assume that the variable resistor is set to e.g. 10kΩ, we can calculate an input voltage of

<img src="https://raw.githubusercontent.com/dangrie158/cc-franz/develop/Docs/Images/formula_3.png" alt="" style="width: 50%"/>.

That’s our basic threshold. Now we assume that the voltage at the inverting input (this is the output of the photo cell) is lower than this threshold, let’s say 1V. The opamp now drives its output high. <br />
Now we basically have a voltage of 5V at the output of the opamp. We can simplify the circuit in this state into the following one:

<img src="https://raw.githubusercontent.com/dangrie158/cc-franz/develop/Docs/Images/opamp_high.png" alt="" style="width: 380px;"/>

As one can see, we simply connected R1 directly to 5V instead of the output. When you look closely , we have R5 and R1 now in parallel, we can see this more clearly if we move R1 next to R5:

<img src="https://raw.githubusercontent.com/dangrie158/cc-franz/develop/Docs/Images/opamp_high_replace.png" alt="" style="width: 380px;"/>

Since R5 and R1 are now in parallel, we can simply replace them by a single resistor (assuming R5 would still be set at 10kΩ) with the value:

<img src="https://raw.githubusercontent.com/dangrie158/cc-franz/develop/Docs/Images/formula_4.png" alt="" style="width: 35%"/>.

This changes the threshold because the ratio between the two resistors changed. The threshold is now at

<img src="https://raw.githubusercontent.com/dangrie158/cc-franz/develop/Docs/Images/formula_5.png" alt="" style="width: 50%"/>.

As we can see, our threshold voltage was raised, which means our trigger actually triggers at 2.62V. <br />
Now, let’s assume the voltage at the inverting input to our amplifier is raised above those 2.62V. The opamp instantly drives the output low. We, once again, can present this state as an equivalent circuit diagram:

<img src="https://raw.githubusercontent.com/dangrie158/cc-franz/develop/Docs/Images/opamp_low.png" alt="" style="width: 380px;"/>

You can clearly see that R1 and R2 are now in parallel. We can calculate the resistance they have as

<img src="https://raw.githubusercontent.com/dangrie158/cc-franz/develop/Docs/Images/formula_6.png" alt="" style="width: 40%"/>.
That’s of course the same value we calculated for the other state. The interesting thing, however, is that we now have another threshold voltage. We can calculate it as

<img src="https://raw.githubusercontent.com/dangrie158/cc-franz/develop/Docs/Images/formula_7.png" alt="" style="width: 50%"/>.

This means we have a hysteresis area of

<img src="https://raw.githubusercontent.com/dangrie158/cc-franz/develop/Docs/Images/formula_8.png" alt="" style="width: 50%"/>.

This means the amplifier outputs a high signal as soon as the input signal reaches at least 2.62V, but only goes low again, if the input drops lower than 2.38V. Without this hysteresis through the feedback resistor R1, the amplifier could oscillate if you apply exactly 2.5V to the input. <br />
Since R5 is a variable resistor, the threshold voltage of the amplifier can be set to almost anything between 0 and 5V, even after the board is assembled. You can do the math for any other value of R5 now.

######WiFi Module
The WiFi Module we used is the ESP8266 Chip on a breakout board. This chip has received a lot of attention already, because it is available for ~3€ each. This is ~86€ cheaper than the [official arduino wifi shield](http://www.amazon.de/Arduino-WiFi-Shield-Smart-Projects/dp/3645651985). With the shipped firmware, this chip is controllable over an AT command set over a serial RS232 connection. However we later changed the firmware with our custom one. To communicate with the main ATMEGA, however, we still used a RS232 connection.

######RS232 Debug Port
To debug the firmware we wanted a serial port just to write debug messages and states. Since the ATMEGA only has one hardware serial port we just connected the debug module of the schematic to two random pins and used the hardware serial port for the communication with the ESP8266. <br />
Today, everybody uses the RS232 protocol at TTL levels (0V-5V) with dupont wire. However, the original standard uses a [DB-9 connector](http://www.electronicsplanet.ch/Anschl/seriell.html) and logic levels of -/+15V. We wanted to stick with the original standard and for that reason, we needed to convert the TTL signal to the full +/-15V swing. The chip that accomplishes that is the [MAX232](http://www.ti.com/lit/ds/symlink/max232.pdf). The nice thing about it, is that it does not need a positive and negative 15V rail to generate the signals. It instead uses a charge-pump and is therefore lucky with a supply of 5V. If you can’t get bothered to use the old standard and do not plan to connect the controller to the com port of an old computer, you can simply not populate the capacitors C9-C12 and the MAX232 chip U2. The simply bridge the pins from the micro directly to the debug connector.

######IR Transmitter Driver
Most cameras have the ability to control the shutter over a simple infrared camera. Although most vendors sell the remote control as a separate product, the IR codes for most cameras are readily available in the internet. Just to be able to control the shutter, we added a jelly bean BC337 NPN transistor to drive the LED. The transistor to drive the LED is probably not necessary because the ATMEGA can source ~20mA and sink ~40mA from its I/O ports which should be more than enough for most modern LEDs. However, it would be to drive the LED directly and transistors are not that expensive. Again, if you don’t want the driver, you can simply not populate it.

######User Interface
For test reasons, and to be able to control the slider without having an iPad at hand, we implemented a user interface with five buttons. These buttons allow you to control the angular and linear axis of the slider. The fifth button did not have any meaning back then, but is now used to start a predefined script. Furthermore, every button can be used to toggle the LED for feedback purposes. <br />
We used external pulldown resistors although the ATMEGA has internal ones for all I/O pins. We’ve decided to use external ones because it is easy to lay traces underneath them. It would also be possible to replace the resistors R5-R9 with simple copper wire and use the internal pulldowns.

######Layout
The board should be milled on the CNC machine we also used for the aluminum parts. For this reason we tried to lay out the board single sided just because it is much easier for home production. We ended up using 18 jumper wires, which is a pretty good end result. The general layout uses the same modular setup we designed into our schematic. Since we do not need any high speed data transmission lines, the board is rather simple and there were not many potential problems. However, some things we kept in mind include:

######Local regulation and power traces
You should avoid running your power traces across the whole board, just because the copper also has a resistance. This resistance is higher, the narrower and longer the trace is. For this reason, the high current +12V power traces for the motor supply are 50 mil wide and are kept as short as possible, thus the power jack is quite close to the motor controllers. <br />
Another problem is that a higher trace resistance means a higher current for the rail because the resistance needs to be overcome. For this reason, the regulation should always happen as close to the device as possible. This also reduces ripple on the trace from coupling with other digital I/O lines. Our 5V rail is needed all over the board, so there is not much we can do to optimize in this respect. The 3.3V rails, however, is only needed for the ESP8266 WiFi Module and thus the LM33CV regulator is placed right next to it.
