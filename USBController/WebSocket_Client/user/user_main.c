#include "espmissingincludes.h"
#include "ets_sys.h"
#include "osapi.h"
#include "os_type.h"
#include "uart.h"
#include "websocketd.h"

#define RX_PRIO 0
#define RX_QUEUE_LEN 1
#define COMMAND_MAXLEN 1024

os_event_t user_procTaskQueue[RX_QUEUE_LEN];
static char *statusCommand = "STATUS:";
static uint8_t commandMatcher = 0;
static uint8_t commandMatched = FALSE;
static char command[COMMAND_MAXLEN];
static uint32_t commandPosition = 0;
static bool TCPconnected = false;
static bool WSconnected = false;

void onWSConnection()
{
	WSconnected = true;
	os_printf("\nCC-Franz: WebSocket Messages active!\n");
}

void onWSDisconnection()
{
	WSconnected = false;
	TCPconnected = false;
	os_printf("\nCC-Franz: Disconnected from TCP and WS.\n");
}

void onWSReconnection(int err)
{
	TCPconnected = false;
	WSconnected = false;
	os_printf("\nCC-Franz: Reconnected to TCP. Error = %d\n", err);
}

void os_delay(uint8_t ms)
{
	os_delay_us(ms * 1000);
}

//Main code function
static void ICACHE_FLASH_ATTR rxLoop(os_event_t *events) {
	
	if(TCPconnected && WSconnected)
	{
		char c = uart0_rx_one_char();
		if (c != -1)
		{
			if (commandMatched == TRUE)
			{
				if (c == '\n' || c == '\r')
				{
					sendWsMessage(command[0], command[1], command[2], command[3]);
					commandMatched = FALSE;
					commandPosition = 0;
					commandMatcher = 0;
				}
				else
				{
					command[commandPosition++] = c;
				}

				if (commandPosition == COMMAND_MAXLEN)
				{
					commandMatched = FALSE;
					commandPosition = 0;
					commandMatcher = 0;
				}
			}
			else
			{
				if (statusCommand[commandMatcher] == c)
				{
					commandMatcher++;
					if (commandMatcher == strlen(statusCommand))
					{
						commandMatched = TRUE;
					}
				}
				else
				{
				commandMatcher = 0;
				}
			}
		}
	}
	else if(!TCPconnected && !WSconnected)
	{	
		int8_t connected;
		connected = websocketdInit(8080, &onWSConnection, &onWSDisconnection, &onWSReconnection);
		if(connected == 0)
		{
			TCPconnected = true;
		}
		else
		{
			os_delay(100);
		}
	}
	system_os_post(RX_PRIO, 0, 0 );	
}


//Main routine. Initialize stdout, the I/O and the webserver and we're done.
void user_init(void) {
	uart_init();
	uint8_t connectStatus = 99;
	// Station Mode = 0x01, StationAP Mode = 0x03
	wifi_set_opmode(0x01);

	// Set SSID and Password of network to connect
	struct station_config wifiConfig = {
	.ssid = "CameraControl",
	.password = ""
	};

	wifi_station_set_config(&wifiConfig);
	wifi_station_disconnect();
	wifi_station_connect();
	connectStatus = wifi_station_get_connect_status();
	os_printf("\nCC-Franz: WIFI Status =  %d\n", connectStatus);

	//Start os task
	system_os_task(rxLoop, RX_PRIO, user_procTaskQueue, RX_QUEUE_LEN);
	system_os_post(RX_PRIO, 0, 0 );
	
}
