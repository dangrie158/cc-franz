#include <stdbool.h>
#include <stdlib.h> 

#include <util/delay.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <string.h>
#include "uart.h"
#include "timer.h"

#include "constants.h"

void GpioInit(){
    DDRB = 0;
    DDRC = 0;
    DDRD = 0;
    
    DDRB |= (1 << PB0); // set IR TRANSMITTER as output
    DDRB &= ~(1 << PB1); // set CW button as input
    DDRB |= (1 << PB2); // set status LED as output
    DDRB &= ~(1 << PB3); // set HOMING as input

    DDRC |= (1 << PC3); // set DIR1 as output
    DDRC |= (1 << PC4); // set STEP1 as output
    DDRC |= (1 << PC1); // set DIR2 as output
    DDRC |= (1 << PC2); // set STEP2 as output
    DDRC &= ~(1 << PC5); // set ENDSTOP as input

    DDRD |= (1 << PD3); // set TXD as output
    DDRD &= ~(1 << PD5); // set LEFT as input
    DDRD &= ~(1 << PD6); // set CCW as input
    DDRD &= ~(1 << PD7); // set RIGHT as input

    PORTC &= ~(1 << PC2); //save set step to low
    PORTD &= ~(1 << PD3); //save set TXD to low
}

void doStepMove(){
    PORTC |= (1 << PC2);
    _delay_ms(1);
    PORTC &= ~(1 << PC2);
    _delay_ms(1);
}
void doStepRotate(){
    PORTC |= (1 << PC4);
    _delay_ms(1);
    PORTC &= ~(1 << PC4);
    _delay_ms(1);   
}

void debugWriteByte(uint8_t b){

    //START BIT
    PORTD &= ~( 1 << PD3 ); // START BIT IS HIGH
    _delay_us(104);

    //DATA BITS
    for(uint8_t bit = 0; bit < 8; bit++ )
    {
    
        if((b & 0b00000001)){ //test left most bit
            PORTD |= 1 << PD3; //TXPIN HIGH
        } else {
            PORTD &= ~( 1 << PD3 ); //TXPIN LOW
        }

        b >>= 1;
        _delay_us(104);
    }

    //STOP BIT 
    PORTD |= ( 1 << PD3 ); //STOP BIT IS LOW
    _delay_us(208);         // TIME BETWEEN BYTES SENT
}

volatile uint8_t speedM = 0; 
volatile uint8_t speedP = 0;
volatile bool moveM = false;
volatile bool moveP = false;
volatile uint8_t counterM = 0;
volatile uint8_t counterP = 0;

void timerElapsed(){
    counterM++;
    counterP++;

    if(counterM  >= speedM && speedM != 0){
        counterM = 0;
        //set move pin high, to perform a step
        PORTC |= (1 << PC2);
    }else{
        //set step pin low again to be ready for the next step
        PORTC &= ~(1 << PC2);
    }

    if(counterP >= speedP && speedP != 0){
        counterP = 0;
        //set rotate pin high to do a step
        PORTC |= (1 << PC4);
    }else{
        //set step pin low again to be ready for the next step
        PORTC &= ~(1 << PC4);
    }
}



int main (){

    bool running = false;
    uint8_t totalSteps = 0;

    GpioInit();

    uartInit();

    timerInit(timerElapsed);

    //debugWriteByte('I');
    
    while(true){
        if((PIND >> PD5) & 1){  // if left
            PORTC |= (1 << PC1);
            PORTB |= (1 << PB2);
            doStepMove();
            debugWriteByte('J');
        }
        else if((PIND >> PD7) & 1){ // if right
            PORTC &= ~(1 << PC1);
            PORTB |= (1 << PB2);
            doStepMove();
            debugWriteByte('J');
        }
        else if((PIND >> PD6) & 1){  // if ccw
            PORTC |= (1 << PC3);
            PORTB |= (1 << PB2);
            doStepRotate();
            debugWriteByte('J');
        }
        else if((PINB >> PB1) & 1){  // if cw
            PORTC &= ~(1 << PC3);
            PORTB |= (1 << PB2);
            doStepRotate();
            debugWriteByte('J');
        }
        else if((PINB >> PB3) & 1){    // if homing
            PORTB |= (1 << PB2); // LED
            PORTB |= (1 << PB0); // IR
            running = true;

        }else if(PINC >> PC5){  //endstop
            PORTB |= (1 << PB2); // LED

        }
        else{
            PORTB &= ~(1 << PB0);
            PORTB &= ~(1 << PB2);
        }

         if(uartAvailable()){
            char line[RX_BUFF];
             uartReadLine(line);
            for(int i=0; i < strlen(line); i++){
                debugWriteByte(line[i]);
            }
            debugWriteByte('\n');
            debugWriteByte('\r');

             if(line[0] == 'M'){
                if(line[1] == '+'){
                    PORTC &= ~(1 << PC1);

                    speedM = ((1.0f / strtol(line + 2, NULL, 16)) * 255);
                }else if(line[1] == '-'){
                    PORTC |= (1 << PC1);
                    speedM = ((1.0f / strtol(line + 2, NULL, 16)) * 255);
                }else if(line[1] == '0'){
                    speedM = 0;
                }
             }else if(line[0] == 'R'){
                if(line[1] == '+'){
                    PORTC &= ~(1 << PC3);
                    speedP = ((1.0f / strtol(line + 2, NULL, 16)) * 255);
                }else if(line[1] == '-'){
                    PORTC |= (1 << PC3);
                    speedP = ((1.0f / strtol(line + 2, NULL, 16)) * 255);
                }else if(line[1] == '0'){
                    speedP = 0;
                }
             }
         }

        if(running){
            PORTB |= (1 << PB2); // LED
            PORTC |= (1 << PC1); //DIR2
            PORTC &= ~(1 << PC3); //DIR1

            if(totalSteps % 12 == 0){
                doStepRotate();
            }

            doStepMove();

            totalSteps++;

            _delay_ms(100);
        }
    }

    return 0;

}