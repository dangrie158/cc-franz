#ifndef UART_H_
#define UART_H_

#include <avr/io.h>
#include <stdint.h>

#include "constants.h"

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
#define TX_START()		SET(UCSR0B, TXEN0)		// Enable TX
#define TX_STOP()		CLEAR(UCSR0B, TXEN0)	// Disable TX
#define RX_START()		SET(UCSR0B, RXEN0)		// Enable RX
#define RX_STOP()		CLEAR(UCSR0B, RXEN0)	// Disable RX
#define COMM_START()	TX_START(); RX_START()	// Enable communications

/* Interrupt macros; Remember to set the GIE bit in SREG before using (see datasheet) */
#define RX_INTEN()		SET(UCSR0B, RXCIE0)	// Enable interrupt on RX complete
#define RX_INTDIS()		CLEAR(UCSR0B, RXCIE0)	// Disable RX interrupt
#define TX_INTEN()		SET(UCSR0B, TXCIE0)	// Enable interrupt on TX complete
#define TX_INTDIS()		CLEAR(UCSR0B, TXCIE0)	// Disable TX interrupt

/* Prototypes */
void uartInit(void);
uint8_t uartGetByte(void);
uint8_t uartAvailable();
void uartPutByte(unsigned char data);
void uartWriteLine(char *str);
uint32_t uartReadLine(char* buffer);

#endif /* UART_H_ */
