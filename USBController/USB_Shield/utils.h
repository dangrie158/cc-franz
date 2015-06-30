#ifndef UTILS_H
#define UTILS_H

#include <inttypes.h>
#include <avr/io.h>
#include "delay.h"

void uart_init();

int uart_writeByte(unsigned char c);

void uart_writeString(char *s);

#endif