#include <osapi.h>
#include <string.h>
#include <inttypes.h>
#include "espmissingincludes.h"
#include "websocketd.h"

//websocket connection request
#define WS_REQUEST "GET / HTTP/1.1\r\nConnection: Upgrade\r\nUpgrade: websocket\r\nHost: localhost:3000\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Key: %s\r\n\r\n"
#define WS_REQUEST_KEY "MTMtMTQzMzc4MTMxNTIyNg=="
#define WS_ACCEPT_KEY "dybPMnKl2zysvxsk2k4nDvZXPMQ="

//masking key, necessary from the WebSocket Definition.
//All websocket messages need to be masked. The masking
//key can be choosen freely, so we use just a simple pattern
uint32_t MASKING_KEY = 0b01010101010101010101010101010101;
 
// Connection Structure and Connection Callbacks
static struct espconn wsConn;
static esp_tcp wsTcp;
static WSConnection wsServerConnection;
static WSOnConnection wsOnConnectionCallback;
static WSOnDisconnection wsOnDisconnectionCallback;
static WSOnReconnection wsOnReconnectionCallback;

// Getter for the WebSocket Connection Data
static WSConnection *ICACHE_FLASH_ATTR getWsConnection() {
	if (wsServerConnection.tcp_connected == true) 
	{
		return &wsServerConnection;
	}
	return NULL;
}

// This function masks given websocket message data with a masking key
static void ICACHE_FLASH_ATTR maskData(char* unmaskedData, uint8_t length, uint32_t maskingKey)
{
	// From IEEE RFC 6455 Section 5.3
	for (int i = 0; i < length; i++)
	{
		int j = i % 4;
		unmaskedData[i] = unmaskedData[i] ^ ((uint8_t *) &maskingKey)[j];
	}
}

// This function creates a valid WebSocket Message from
// 4 given chars by setting and copying all necessary flags and data.
void ICACHE_FLASH_ATTR sendWsMessage( char a, char b, char c, char d )
{
	WSConnection *wsConnection = getWsConnection();
	if (wsConnection == NULL) {
		// no valid connection to a server exists
		return;
	}

	uint8_t messageLength = 10;

	// FIN + OPCODE_BINARY
	uint8_t flags_opcode = 0b10000001;
	// MASK + LENGTH 4
	uint8_t mask_length = 0b10000100;
	uint32_t maskingKey = MASKING_KEY;

	char message[messageLength];

	maskData(&a, 1, maskingKey);
	maskData(&b, 1, maskingKey);
	maskData(&c, 1, maskingKey);
	maskData(&d, 1, maskingKey);
	
	// memcpy(dest, src, length)
	os_memcpy(message, &flags_opcode, sizeof(uint8_t));
	os_memcpy(message+1, &mask_length, sizeof(uint8_t));
	os_memcpy(message+2, &maskingKey, sizeof(uint32_t));
	os_memcpy(message+6, &a, sizeof(uint8_t));
	os_memcpy(message+7, &b, sizeof(uint8_t));
	os_memcpy(message+8, &c, sizeof(uint8_t));
	os_memcpy(message+9, &d, sizeof(uint8_t));
	espconn_sent(wsConnection->connection, (uint8_t*) message, sizeof(uint8_t) * messageLength);
}

// Closing a WebSocket connection gracefully
void ICACHE_FLASH_ATTR closeWsConnection(WSConnection* connection) {
	char closeMessage[CLOSE_MESSAGE_LENGTH] = CLOSE_MESSAGE;
	espconn_sent(connection->connection, (uint8_t *)closeMessage, sizeof(closeMessage));
	connection->status = STATUS_CLOSED;
	return;
}

// Callback 
static void ICACHE_FLASH_ATTR wsSentCb(void *esp_connection) {
	WSConnection *wsConnection = getWsConnection();

	if (wsConnection == NULL) {
		// no valid connection to a server exists
		return;
	}

	if(wsConnection->status == STATUS_CLOSED){
		//Close message sent, now close the socket
		espconn_disconnect(wsConnection->connection);
		//free the slot
		wsConnection->connection = NULL;
                os_printf("\nCC-Franz: Status Closed, ending connection\n");
	}
}

static void ICACHE_FLASH_ATTR wsRecvCb(void *esp_connection, char *data, unsigned short len) {

	WSConnection *wsConnection = getWsConnection();
	if (wsConnection == NULL) {
		// no valid connection to a server exists
		return;
	}
	
        char* key;
        if(wsConnection->ws_connected == false)
        {
                key = os_strstr(data, WS_ACCEPT_KEY);
        }

        if(key != NULL && wsConnection->ws_connected == false)
        {
                wsConnection->ws_connected = true;
                os_printf("\nCC-Franz: WebSocket Connection established.\n");
		if(wsOnConnectionCallback != NULL)
		{
			wsOnConnectionCallback();
		}
        }
	key = NULL;	
}

// Callback is called when a Websocket Connection is established
static void ICACHE_FLASH_ATTR wsConnectCb(void *connection) {
	
	WSConnection wsConnection;
	wsConnection.tcp_connected = true;
	wsConnection.status = STATUS_UNINITIALISED;
	wsConnection.connection = connection;
	wsServerConnection = wsConnection;

	os_printf("\nCC-Franz: Connected to Server\n");
        
        char* webSocketKey = WS_REQUEST_KEY;
        char webSocketConnectMessage[strlen(WS_REQUEST)];
        os_sprintf(webSocketConnectMessage, WS_REQUEST, webSocketKey);
        int8_t result = espconn_sent(connection, (uint8_t*)webSocketConnectMessage, strlen(webSocketConnectMessage));
        os_printf("\nCC-Franz: Sending WebSocket Upgrade: %d\n",result);
}

// Callback is called when a Websocket Connection is reconnected
static void ICACHE_FLASH_ATTR wsReconnectCb(void *connection, int8 err) {

	if(wsOnReconnectionCallback != NULL)
	{
		wsOnReconnectionCallback(err);
	}
	os_printf("\nCC-Franz: Reconnected to Server\n");	
}

// Callback is called when a Websocket Connection is disconnected
static void ICACHE_FLASH_ATTR wsDisconnectCb(void *connection) {

	if(wsOnDisconnectionCallback != NULL)
	{
		wsOnDisconnectionCallback();
	}
	os_printf("\nCC-Franz: Disconnected from Server\n");	
}

// Initalizing of the WebSocket Server
int8_t ICACHE_FLASH_ATTR websocketdInit(int port, WSOnConnection onConnection, 
 						  WSOnDisconnection onDisconnection,
						  WSOnReconnection onReconnection) {

	wsOnConnectionCallback = onConnection;
	wsOnDisconnectionCallback = onDisconnection;
	wsOnReconnectionCallback = onReconnection;
	
	wsServerConnection.tcp_connected = false;
        wsServerConnection.ws_connected = false;

	wsConn.type = ESPCONN_TCP;
	wsConn.state = ESPCONN_NONE;

	wsTcp.local_port = espconn_port();
	wsTcp.remote_port = port;
	wsTcp.remote_ip[0] = 192;
	wsTcp.remote_ip[1] = 168;
	wsTcp.remote_ip[2] = 4;
	wsTcp.remote_ip[3] = 1;

	wsConn.proto.tcp = &wsTcp;
	espconn_regist_connectcb(&wsConn, wsConnectCb);
	espconn_regist_reconcb(&wsConn, wsReconnectCb);
	espconn_regist_disconcb(&wsConn, wsDisconnectCb);
    espconn_regist_recvcb(&wsConn, wsRecvCb);
	espconn_regist_sentcb(&wsConn, wsSentCb);
	
	int8_t connectResult = espconn_connect(&wsConn);
	
	return connectResult;
}
