#ifndef WEBSOCKETD_H
#define WEBSOCKETD_H
#include <c_types.h>
#include <ip_addr.h>
#include <espconn.h>

#define WS_KEY_IDENTIFIER "Sec-WebSocket-Key: "
#define WS_GUID "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
#define WS_RESPONSE "HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: %s\r\nSec-WebSocket-Protocol: chat\r\n\r\n"
#define HTML_HEADER_LINEEND "\r\n"


//we normally dont need that many connection, however a single 
//connection only allocates a WSConnection struct and is therefore really small
#define WS_MAXCONN 4
#define CONN_TIMEOUT 60*60*12

/* from IEEE RFC6455 sec 5.2
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

#define FLAGS_MASK ((uint8_t)0xF0)
#define OPCODE_MASK ((uint8_t)0x0F)
#define IS_MASKED ((uint8_t)(1<<7))
#define PAYLOAD_MASK ((uint8_t)0x7F)

#define STATUS_OPEN 0
#define STATUS_CLOSED 1
#define STATUS_UNINITIALISED 2

#define CLOSE_MESSAGE {FLAG_FIN | OPCODE_CLOSE, IS_MASKED /* + payload = 0*/, 0 /* + masking key*/}
#define CLOSE_MESSAGE_LENGTH 3

typedef struct WSFrame WSFrame;
typedef struct WSConnection WSConnection;

typedef void (* WSOnMessage)(WSConnection *,const WSFrame* );
typedef void (* WSOnConnection)(WSConnection *connection);

struct WSFrame {
	uint8_t flags;
	uint8_t opcode;
	uint8_t isMasked;
	uint64_t payloadLength;
	uint32_t maskingKey;
	char* payloadData;
};

struct WSConnection {
	uint8_t status;
	struct espconn* connection;
	WSOnMessage onMessage;
};

void ICACHE_FLASH_ATTR websocketdInit(int port, WSOnConnection onConnection);
void ICACHE_FLASH_ATTR sendWsMessage(WSConnection* connection, const char* payload, uint64_t payloadLength, uint8_t options);
void ICACHE_FLASH_ATTR broadcastWsMessage(const char* payload, uint64_t payloadLength, uint8_t options);

#endif //WEBSOCKETD_H