#ifndef WEBSOCKETD_H
#define WEBSOCKETD_H
#include <c_types.h>
#include <ip_addr.h>
#include <espconn.h>

#define WS_KEY_IDENTIFIER "Sec-WebSocket-Key: "
#define WS_GUID "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
#define HTML_HEADER_LINEEND "\r\n"

#define CONN_TIMEOUT 60*60*12

/* from IEEE RFC6455 sec 5.2, 
      0                   1                   2                   3
      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
     +-+-+-+-+-------+-+-------------+-------------------------------+
     |F|R|R|R| opcode|M| Payload len |    Extended payload length    |
     |I|S|S|S|  (4)  |A|     (7)     |             (16/64)           |
     |N|V|V|V|       |S|             |   (if payload len==126/127)   |
     | |1|2|3|       |K|             |                               |
     +-+-+-+-+-------+-+-------------+ - - - - - - - - - - - - - - - +
     |     Extended payload length continued, if payload len == 127  |
     + - - - - - - - - - - - - - - - +-------------------------------+
     |                               |Masking-key, if MASK set to 1  |
     +-------------------------------+-------------------------------+
     | Masking-key (continued)       |          Payload Data         |
     +-------------------------------- - - - - - - - - - - - - - - - +
     :                     Payload Data continued ...                :
     + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
     |                     Payload Data continued ...                |
     +---------------------------------------------------------------+
*/

#define FLAG_FIN (1 << 7)
#define FLAG_RSV1 (1 << 6)
#define FLAG_RSV2 (1 << 5)
#define FLAG_RSV3 (1 << 4)

#define OPCODE_CONTINUE 0x0
#define OPCODE_TEXT 0x1
#define OPCODE_BINARY 0x2
#define OPCODE_CLOSE 0x8
#define OPCODE_PING 0x9
#define OPCODE_PONG 0xA

#define FLAGS_MASK ((uint8_t) 0xF0)
#define OPCODE_MASK ((uint8_t) 0x0F)
#define IS_MASKED ((uint8_t) (1<<7))
#define PAYLOAD_MASK ((uint8_t) 0x7F)

#define STATUS_OPEN 0
#define STATUS_CLOSED 1
#define STATUS_UNINITIALISED 2

#define CLOSE_MESSAGE {FLAG_FIN | OPCODE_CLOSE, IS_MASKED /* + payload = 0*/, 0 /* + masking key*/}
#define CLOSE_MESSAGE_LENGTH 3

// All Data that define a connection for Websocket
// and also a reference to the basic http connection structure
typedef struct WSConnection WSConnection;
struct WSConnection {
    bool ws_connected;
    bool tcp_connected;
    uint8_t status;
    struct espconn* connection;
};

// WebSocket on Connection Callback
typedef void (*WSOnConnection) ();

// WebSocket on Disconnection Callback
typedef void (*WSOnDisconnection) ();

// Websocket on Reconnection Callback
typedef void (*WSOnReconnection) (int err);

// Init Function for WebSockets
int8_t ICACHE_FLASH_ATTR websocketdInit(int port, WSOnConnection onConnection, WSOnDisconnection onDisconnection, WSOnReconnection onReconnection);

// Function to send a WebSocket Message
void ICACHE_FLASH_ATTR sendWsMessage(char a, char b, char c, char d);

#endif //WEBSOCKETD_H
