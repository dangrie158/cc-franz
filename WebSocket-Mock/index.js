/* 
This is part of the CC-Franz project at HdM Stuttgart 2015 
in the class "Embedded Systems" from Thomas Maier. 

This file starts a websocket server with help
of the JSON framework, listening to connections
on Port 8080. When a connection through websocket
is established, a connected information is printed
to the console, also when a message is received,
the message content is printed and the message sent back.
This server is not necessary for the final project
and used for test purposes and development of 
the web socket client, which can be found in
//cc-franz/USBController/WebSocket_Client/
Stefan Seibert - Summer 2015 - ss388@hdm-stuttgart.de
*/

var WebSocketServer = require('ws').Server
  , wss = new WebSocketServer({ port: 8080 });

wss.on('connection', function connection(ws) {
  ws.on('message', function incoming(message) {
	console.log("Message! >> " + message);
	ws.send(message);
  });
  console.log("connected");
  ws.send('server hello');
});

console.log("init");