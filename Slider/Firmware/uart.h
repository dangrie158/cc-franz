/*
 * uart.h
 *
 * UART example for ATMega328P clocked at 16 MHz
 *
 * TODO :-
 * 	- Implement string read function
 * 	- Optimize for size
 * 	- Add helper routines and compile to .a file
 *
 *  Created on: 22-Jan-2014
 *      Author: Shrikant Giridhar
 */

#ifndef UART_H_
#define UART_H_

#include <avr/io.h>
#include <stdint.h>




#define BAUD 9600L      // Baudrate
#define UBRR_VAL ((F_CPU+BAUD*8)/(BAUD*16)-1)   // clever runden
#define BAUD_REAL (F_CPU/(16*(UBRR_VAL+1)))     // Reale Baudrate
#define BAUD_ERROR ((BAUD_REAL*1000)/BAUD) // Fehler in Promille, 1000 = kein Fehler.

#if ((BAUD_ERROR<990) || (BAUD_ERROR>1010))
#error Systematischer Fehler der Baudrate gršsser 1% und damit zu hoch!
#endif

/* Settings */

#define RX_BUFF			100

/* Useful macros */
#define TX_START()		UCSR0B |= _BV(TXEN0)	// Enable TX
#define TX_STOP()		UCSR0B &= ~_BV(TXEN0)	// Disable TX
#define RX_START()		UCSR0B |= _BV(RXEN0)	// Enable RX
#define RX_STOP()		UCSR0B &= ~_BV(RXEN0)	// Disable RX
#define COMM_START()		TX_START(); RX_START()	// Enable communications
 #define _DATA			0x03					// Number of data bits in frame 

/* Interrupt macros; Remember to set the GIE bit in SREG before using (see datasheet) */
#define RX_INTEN()		UCSR0B |= _BV(RXCIE0)	// Enable interrupt on RX complete
#define RX_INTDIS()		UCSR0B &= ~_BV(RXCIE0)	// Disable RX interrupt
#define TX_INTEN()		UCSR0B |= _BV(TXCIE0)	// Enable interrupt on TX complete
#define TX_INTDIS()		UCSR0B &= ~_BV(TXCIE0)	// Disable TX interrupt

/* Prototypes */
void uartInit(void);
uint8_t uartGetByte(void);
uint8_t uartAvailable();
void uartPutByte(unsigned char data);
void uartWriteString(char *str);
uint32_t uartReadLine(char* buffer);

#endif /* UART_H_ */
