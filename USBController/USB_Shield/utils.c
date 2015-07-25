#include "utils.h"

// Define of CPU Frequence and Baudrate
#ifndef F_CPU
#warning "F_CPU war noch nicht definiert, wird nun nachgeholt mit 16000000"
#define F_CPU 16000000UL  // Systemtakt in Hz - Definition als unsigned long beachten 
#endif
#define BAUDRATE 9600UL
 
// Calculation of correct UART timing values
#define UBRR_VAL ((F_CPU+BAUDRATE*8)/(BAUDRATE*16)-1)   // round up
#define BAUD_REAL (F_CPU/(16*(UBRR_VAL+1)))     // real baudrate
#define BAUD_ERROR ((BAUD_REAL*1000)/BAUDRATE) // error in promille, 1000 = no error
 
#if ((BAUD_ERROR<990) || (BAUD_ERROR>1010))
  #error Systematischer Fehler der Baudrate grösser 1% und damit zu hoch! 
#endif

// Initializing the UART Registers
void uart_init()
{
  UBRR0H = UBRR_VAL >> 8;
  UBRR0L = UBRR_VAL & 0xFF;
 
  UCSR0B |= (1<<TXEN0);  // UART TX turn on
  //UCSR0C = (1<<UCSZ1)|(1<<UCSZ0);  // Asynchron 8N1 
  //UCSR0A &= ~(1 << U2X); // U2X not necessary
}

// sending one byte through UART
int uart_writeByte(unsigned char c)
{
    while (!(UCSR0A & (1<<UDRE0)))
    {
      // Wait until we can send data
    }                             
 
    // send the data
    UDR0 = c;
    return 0;
}

// sending one string through UART
void uart_writeString(char *s)
{
    while (*s)
    {   // while *s != '\0', being not the terminal symbol
        uart_writeByte(*s);
        s++;
    }
}