#include <util/delay.h>
#include <avr/io.h>

#include "constants.h"

void debugWriteByte(uint8_t b){

    //START BIT
    CLEAR(SOFT_UART_DDR, SOFT_UART_TX_PIN); // staertbit is low
    _delay_us(SOFT_UART_BITTIME); 

    //DATA BITS
    for(uint8_t bit = 0; bit < 8; bit++ )
    {
    
        if((b & 0b00000001)){ //test left most bit
            SET(SOFT_UART_DDR, SOFT_UART_TX_PIN); //TXPIN HIGH
        } else {
            CLEAR(SOFT_UART_DDR, SOFT_UART_TX_PIN); //TXPIN LOW
        }

        b >>= 1;
        _delay_us(SOFT_UART_BITTIME);
    }

    //STOP BIT 
    SET(SOFT_UART_DDR, SOFT_UART_TX_PIN); //stopbit is low
    _delay_us(SOFT_UART_BITTIME * 2); // wait two time periods
}

void debugWriteLine(char* line){
    for(int i=0; i < strlen(line); i++){
        debugWriteByte(line[i]);
    }
    debugWriteByte('\n');
    debugWriteByte('\r');
}