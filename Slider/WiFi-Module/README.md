###ESP8266 WiFi Module
The ESP8266 is a Xtensa LX106 Microcontroller with an integrated 802.11x WiFi transceiver. It has an integrated TCP stack and therefore provides a good abstraction layer.<br />
With its standard Firmware, the communication happens over a simple AT Command interface over a serial UART. With this interface the use of the chip is very limited.

#####Why WebSockets
We wanted to use WebSockets as the communication protocol on top of TCP. This leaves us with the option to create a web based control interface for the slider, although this is not planned in the near future. There are also WebSocket libraries available for almost any language. Furthermore, websockets are fast and lightweight, so virtually perfect for the use in an embedded environment. Sadly, there is no ESP8266 firmware out there that supports WebSockets, but since we are both software developers this should be nothing to worry about.<br />
Basically we want the ESP8266 Chip to be responsible up until the WebSocket protocol. The communication should still happen over the UART interface. If the module receives a WebSocket message, it unpacks the payload and writes it out over UART. If it receives a line (terminated by CR&LF), it creates a new WebSocket frame and sends it to all its clients.<br />
The module also acts as a WebSocket server that opens a WLAN access point clients can connect to. This is important because it is impossible to create a WLAN with an iPad.

#####WebSocket protocol
The WebSocket protocol is rather simple: 
* The client sends a HTTP request to the server with the headers ‘Connection: upgrade’ and ‘Upgrade: websockets’ set. Furthermore, a random 32byte key, the ‘Sec-Websocket-Key’,’ is send within the headers.
* The Server calculates the answer to the ‘Sec-Websocket-Key’:
*  it concatenates the WebSocket GUID ‘258EAFA5-E914-47DA-95CA-C5AB0DC85B11’ to the original key
*  it calculates the SHA1 hash of the result
*  it Base64 encodes the hash
* The server sends the response with the status code ‘101 - Switching Protocols’ and the calculated key

After this sequence the TCP connection is ready to transmit WebSocket frames. This whole routine happens in the `wsRecvCb `callback in the code. The key is calculated in `createWsAcceptKey`. <br />
WebSocket frames are in a simple binary format that is described in the header file `websocketd.h`. The description is basically a copy of the [RFC 6455](https://tools.ietf.org/html/rfc6455). The parsing of the received frames and the sending happens in `parseWsFrame` and `sendWsMessage` respectively. <br />
The main loop happens in `user_main.c` which starts the WebSocket server, registers a callback for new messages and reads the UART.

