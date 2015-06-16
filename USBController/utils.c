#include "utils.h"
#include <avr/io.h>
#include "delay.h"

void writeByte(uint8_t b)
{
    //START BIT
    PORTD &= ~( 1 << PD4 ); // START BIT IS HIGH
    _delay_us(104);

    //DATA BITS
    for(uint8_t bit = 0; bit < 8; bit++ )
    {
    
        if((b & 0b00000001)){ //test left most bit
            PORTD |= 1 << PD4; //TXPIN HIGH
        } else {
            PORTD &= ~( 1 << PD4 ); //TXPIN LOW
        }

        b >>= 1;
        _delay_us(104);
    }

    //STOP BIT 
    PORTD |= ( 1 << PD4 ); //STOP BIT IS LOW
    _delay_us(104);         // TIME BETWEEN BYTES SENT
}

void writeString(uint8_t* a)
{
    while(a != '\0')
    {
        writeByte(*a++);
    }

}