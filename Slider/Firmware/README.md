###Microcontroller

#####Setup
When the microcontroller boots up, it sets up its GPIO pins as input or output and writes the initial values to them.<br />
After that the hardware UART is configured to async receive mode at 9600 baud. This is the UART that is connected to the WiFi module.<br />
Following along, the 16 bit Timer 1 is set up to fire an interrupt at 1kHz.

#####Main Loop
In the main loop are basically 4 tasks happening:
* check the UI buttons and handle them if they are pressed
* check if the UART received a whole line and parse it
* handle the hard coded script if it was previously started by the UI
* check if the position of the slider has changed and send an update via UART if needed

#####Communication Protocol
The whole protocol is based on WebSockets. Clients can send masked payload to the server. Control messages have the following format:

```
<axis><direction><speed>
```

where:

* `axis is either 'M' or 'R' as single char
* `direction` is either '+', '-' or '0' where '0' stands for STOP
* `speed` is an integer 00-FF which is sent as hex

Examples:
* `M+75` – move slider with speed 75 to the right
* `R+65` – pan slider with speed 65 clockwise
* `R0` – stop the panning
* `M-10` – move the slider slowly to the left

To avoid heavy parsing each message should only contain the specified letters and no spaces or other characters whatsoever. Each message is followed by a single `\n` newline (no `\r`)

Further special messages that can be sent are 
* `ZM` or `ZR` – set the axis current position as 0 reference (movement and rotation)
* `HM` or `HR` – tell the slider to automatically move to its 0 reference (homing)

Last but not least, the slider is not only able to receive messages from an iPad, but send them to it. This way it is possible to tell the iPad the current position of the linear and angular axis via the following messages:
* `PMFFFF` - With FFFF being a hexadecimal position
* `PRFFFF` - With FFFF being a hexadecimal position

#####Message Parsing
The messages are sent by the WiFi module over UART and are parsed by the microcontroller. The parsing routine is rather simple:
* Read the first byte from the message
* Is it a M, R, Z or H, take a look at the next byte, else just drop the message
* Parse the second byte with respect to the previous byte 
* If the first byte was a M or R, and the second byte was not a 0, use the strtol with a base of 16 to parse the hexadecimal number that should be there. Since the string that is parsed is null terminated explicitly while reading the uart buffer, this is a save function even if strtol has no maximum length parameter like strncpy.

The parsing of the message is done in every cycle of the main loop if the UART has read a line.

#####Reading lines from the UART
The UART is, as already mentioned, configured in asny receive mode, which means it triggers an interrupt every time a byte is read. We don’t really care about single bytes, we want the whole line. For this reason we moved all the UART functions to its own files `uart.c` and `uart.h`. In these files we handle the interrupt and save the newly received byte in a line buffer of a maximum length of 100 bytes. This limit is more than enough for our simple message format. If the limit is reached before the end of the line is detected (CR or LF), the buffer is cleaned. This protects the system from a buffer overflow while reading the string. If the received buffer is either a `\n` or `\r` character, the line is considered complete and the string buffer is terminated with a `\0`. Since this all happens within the interrupt context of the hardware uart, we simply set a flag to indicate that the string is now ready for consumption. This flag is checked in the main loop while parsing the messages. If the main loop is ready parsing the message, it clears the flag and therefore indicates that the string is ready to be overwritten.<br />
Since both, the string buffer and the flag, are used in an interrupt and a main context, these variables need to be defined volatile or else the compiler may would optimize the access to them. By declaring them volatile we tell the compiler that it can not know when or if the variable will change.

#####UI and Motor Control
Performing a step with either motor means setting the STEP pin for the controller high for at least 1ms, then setting it low for at least 1ms before performing another step. The 1ms is used to set the maximum speed of the motors. We noticed that this is a good compromise between speed and stability, because if you drive the motors too fast, they may miss some steps.<br />
Each pass of the main loop, all buttons of the UI are checked. If any button is detected to be pressed (reads a high value), a step in the corresponding direction is performed.

#####Timer
As said, Timer 1 is used to fire an interrupt at 1kHz. This static interval is necessary because we need a way to calculate if we have to perform a step into any direction within this loop. Let’s say we receive and parse a message that states we should drive to the right with a speed of 15%. Since our main loop runs at no fixed interval, there is no way we could decide if we should perform a step within this run. If the user presses a button, the main loop automatically needs 2ms longer to perform the motor step. By using the timer we have a fixed interval to calculate if we need to perform a step each n-th interval to get the desired speed.<br />
Since our Timer runs an interrupt, and you should never wait or do any long running task in an interrupt context, we cannot simply do the toggle-wait-toggle-wait routine like we do when handling the UI. Instead we just use a counting variable which we increment every time we run the function to check if we waited long enough to perform the next step.

#####Software UART
To debug the Firmware, it is always nice to have a simpler way than toggling an LED. Text, for example, is great for this purpose. You can send values of variables, markers where you are in the execution and so on. <br />
For this purpose we added a second serial port to our project. Sadly, the ATMEGA only offers one hardware UART. Therefore, we needed to emulate one. Since we did not need to receive anything from the port, the task was rather simple. Receiving is kind of hard, because RS232 is asynchronous and has no clock. For this reason, it is critical to notice when a byte starts and then check the logic levels on the line every 1/BAUD_RATE seconds. You can do this with pin change interrupts and a timer, but it gets rather complicated. For sending you can just bit bang the byte synchronously with delays. 

<img src="https://raw.githubusercontent.com/dangrie158/cc-franz/develop/Docs/Images/bits.png.png" alt="" style="width: 380px;"/>

You start to transmit a bit by pulling the line low for a bittime. After that, you start transmitting the byte bitwise starting with the least significant bit and waiting a bit time before the next bit. After transmitting the most significant bit, you pull the line high again for the stop bit. After that, you can transmit the next byte by sending a start bit first.

<img src="https://raw.githubusercontent.com/dangrie158/cc-franz/develop/Docs/Images/formula_9.png" alt="" style="width: 50%"/> is is the bit time and is equal to

<img src="https://raw.githubusercontent.com/dangrie158/cc-franz/develop/Docs/Images/formula_10.png" alt="" style="width: 50%"/>

This method can be easily implemented using the `avrlib __delay_us()` function and simple I/O which we did in `debugSendByte()`.







