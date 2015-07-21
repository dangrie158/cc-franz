#include <avr/io.h>
#include <avr/interrupt.h>
#include "uart.h"

void (*timerCallback)();

void timerInit(void (*callback)()){
	cli();

    //F_CPU/Prescaler/1000 = 0x3F for 1kHz
	OCR0A = 0x3F;

    // Set the Timer Mode to CTC
    TCCR0A |= (1 << WGM01);

   	TIMSK0 |= (1 << OCIE0A);    //Set the ISR COMPA vect

    TCCR0B |= (1 << CS02);
    // set prescaler to 256 and start the timer

    timerCallback = callback;

    sei();
    // enable interrupts
}

ISR (TIMER0_COMPA_vect)
{
    timerCallback();
}
