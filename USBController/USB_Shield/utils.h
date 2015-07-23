#ifndef UTILS_H
#define UTILS_H

#include <inttypes.h>
#include <avr/io.h>
#include "delay.h"

// Initializing the UART Registers
void uart_init();

// sending one byte through UART
int uart_writeByte(unsigned char c);

// sending a string through UART
void uart_writeString(char *s);

#endif