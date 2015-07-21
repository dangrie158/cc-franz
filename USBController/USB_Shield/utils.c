#include "utils.h"

#ifndef F_CPU
#warning "F_CPU war noch nicht definiert, wird nun nachgeholt mit 16000000"
#define F_CPU 16000000UL  // Systemtakt in Hz - Definition als unsigned long beachten 
#endif
 
#define BAUDRATE 9600UL      // Baudrate
 
// Berechnungen
#define UBRR_VAL ((F_CPU+BAUDRATE*8)/(BAUDRATE*16)-1)   // clever runden
#define BAUD_REAL (F_CPU/(16*(UBRR_VAL+1)))     // Reale Baudrate
#define BAUD_ERROR ((BAUD_REAL*1000)/BAUDRATE) // Fehler in Promille, 1000 = kein Fehler.
 
#if ((BAUD_ERROR<990) || (BAUD_ERROR>1010))
  #error Systematischer Fehler der Baudrate grösser 1% und damit zu hoch! 
#endif

void uart_init()
{
  UBRR0H = UBRR_VAL >> 8;
  UBRR0L = UBRR_VAL & 0xFF;
 
  UCSR0B |= (1<<TXEN0);  // UART TX einschalten
  //UCSR0C = (1<<UCSZ1)|(1<<UCSZ0);  // Asynchron 8N1 
  //UCSR0A &= ~(1 << U2X); // U2X nicht erforderlich
}

int uart_writeByte(unsigned char c)
{
    while (!(UCSR0A & (1<<UDRE0)))  /* warten bis Senden moeglich */
    {
    }                             
 
    UDR0 = c;                      /* sende Zeichen */
    return 0;
}

void uart_writeString(char *s)
{
    while (*s)
    {   /* so lange *s != '\0' also ungleich dem "String-Endezeichen(Terminator)" */
        uart_writeByte(*s);
        s++;
    }
}