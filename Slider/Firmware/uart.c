/*
 * uart.c
 *
 * Asynchronous UART example tested on ATMega328P (16 MHz)
 *
 * Toolchain: avr-gcc (4.3.3)
 * Editor: Eclipse Kepler (4)
 * Usage:
 * 		Perform all settings in uart.h and enable by calling initUART(void)
 * 		Compile:
 * 				make all
 *
 * Functions:
 * 		- First call initUART() to set up Baud rate and frame format
 *		- initUART() calls macros TX_START() and RX_START() automatically
 *		- To enable interrupts on reception, call RX_INTEN() macros
 *		- Call functions getByte() and putByte(char) for character I/O
 *		- Call functions writeString(char*) and readString() for string I/O
 *
 *  Created on: 21-Jan-2014
 *      Author: Shrikant Giridhar
 */
#include "stdbool.h"
#include "string.h"
#include "uart.h"
#include "avr/interrupt.h"


volatile uint8_t uartStringComplete = 0;     // 1 .. String komplett empfangen
volatile uint8_t uartStringCount = 0;
volatile char uartString[RX_BUFF + 1] = "";


/*! \brief Configures baud rate (refer datasheet) */
void uartInit(void)
{
	// Not necessary; initialize anyway
	DDRD |= _BV(PD1);
	DDRD &= ~_BV(PD0);


    UBRR0H = UBRR_VAL >> 8;
	UBRR0L = UBRR_VAL & 0xFF;

	TX_START();
	RX_START();
	RX_INTEN();

	UCSR0C =
        /* asyncrounous USART */
        (0 << UMSEL01) |
        (0 << UMSEL00) |
        /* one stop bit */
        (0 << USBS0) |
        /* 8-bits of data */
        (1 << UCSZ01) |
        (1 << UCSZ00);

}

/*! \brief Returns a byte from the serial buffer
 * 	Use this function if the RX interrupt is not enabled.
 * 	Returns 0 on empty buffer
 */
uint8_t uartGetByte(void)
{
	// Check to see if something was received
	while (!(UCSR0A & _BV(RXC0)));
	return (uint8_t) UDR0;
}

uint8_t uartAvailable(){
	return uartStringComplete;
}

/*! \brief Transmits a byte
 * 	Use this function if the TX interrupt is not enabled.
 * 	Blocks the serial port while TX completes
 */
void uartPutByte(unsigned char data)
{
	// Stay here until data buffer is empty
	while (!(UCSR0A & _BV(UDRE0)));
	UDR0 = (unsigned char) data;

}

/*! \brief Writes an ASCII string to the TX buffer */
void uartWriteString(char *str)
{
	while (*str != '\0')
	{
		uartPutByte(*str);
		++str;
	}
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

ISR(USART_RX_vect,ISR_BLOCK)
{
	cli();
	unsigned char nextChar;
		
	// Daten aus dem Puffer lesen
	nextChar = UDR0;
	if( uartStringComplete == false ) {	// wenn uartString gerade in Verwendung, neues Zeichen verwerfen
			
			// Daten werden erst in uartString geschrieben, wenn nicht String-Ende/max Zeichenlänge erreicht ist/string gerade verarbeitet wird
			if( nextChar != '\n' &&
				 nextChar != '\r' &&
				 uartStringCount < RX_BUFF - 1 ) {
					uartString[uartStringCount] = nextChar;
					uartStringCount++;
			}
			else {
					uartString[uartStringCount] = '\0';
					uartStringComplete = true;
			}
	}
	sei();
}