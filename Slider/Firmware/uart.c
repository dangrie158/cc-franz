#include "stdbool.h"
#include "string.h"

#include <avr/interrupt.h>

#include "uart.h"

volatile uint8_t uartStringComplete = 0;     // 1 .. String komplett empfangen
volatile uint8_t uartStringCount = 0;
volatile char uartString[RX_BUFF + 1] = "";


// Configures baud rate
void uartInit(void)
{
	//set the baudrate 
    UBRR0H = UBRR_VAL >> 8;
	UBRR0L = UBRR_VAL & 0xFF;

	//start transmitting
	TX_START();
	//start reciebving
	RX_START();
	//put the reciever in async interrupt mode
	RX_INTEN();

	/*UCSR0C =
        // asyncrounous USART
        (0 << UMSEL01) |
        (0 << UMSEL00) |
        // one stop bit 
        (0 << USBS0) |
        // 8-bits of data
        (1 << UCSZ01) |
        (1 << UCSZ00);*/

}

// Returns a byte from the serial buffer
// 	Returns 0 on empty buffer
uint8_t uartGetByte(void)
{
	// Check to see if something was received
	while (!ISSET(UCSR0A, RXC0));
	return (uint8_t) UDR0;
}

uint8_t uartAvailable(){
	return uartStringComplete;
}

// Transmits a byte
// Blocks the serial port while TX completes
void uartPutByte(unsigned char data)
{
	// Stay here until data buffer is empty
	while (!ISSET(UCSR0A,UDRE0));
	UDR0 = data;

}

// Writes an ASCII string to the TX buffer
void uartWriteLine(char *str)
{
	while (*str != '\0')
	{
		uartPutByte(*str);
		++str;
	}
	uartPutByte('\r');
	uartPutByte('\n');
}

uint32_t uartReadLine(char* buffer)
{
	cli();
	uint32_t lineLenght = strlen(uartString);
	strncpy(buffer, uartString, lineLenght);
	buffer[lineLenght] = '\0';
	uartStringCount = 0;
	uartStringComplete = false;
	sei();
	return lineLenght;
}

//Interrupt vector for uart interrupt
ISR(USART_RX_vect,ISR_BLOCK)
{
	cli();
	unsigned char nextChar;
		
	//read data from the buffer
	nextChar = UDR0;
	if( uartStringComplete == false ) {	//if were not done reading in syncronous mode, ignore new chars
			
			// check if the buffer is full or the string ended with a NL or LF
			if( nextChar != '\n' &&
				 nextChar != '\r' &&
				 uartStringCount < RX_BUFF - 1 ) {
					uartString[uartStringCount] = nextChar; //save the current char in our buffer
					uartStringCount++; //increment the buffer pointer
			}
			else {
					uartString[uartStringCount] = '\0'; //end the string 
					uartStringComplete = true; //notify the listeners in syncronous mode
			}
	}
	sei();
}