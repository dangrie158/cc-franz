#define F_CPU 16000000
#include <stdbool.h>

#include <util/delay.h>
#include <avr/io.h>
#include <avr/interrupt.h>

#include "constants.h"



volatile uint8_t uartStringComplete = 0;
volatile uint8_t uartStringCount = 0;
volatile char uartString[UART_MAXSTRLEN + 1] = "";
ISR(USART_RXC_vect){
    unsigned char nextChar;
    
    //read buffer
    nextChar = UDR0;
    if( uartStringComplete == false ) {// drop everything to avoid corruption
                                    //until the client is ready with the string
            
        if( nextChar != '\n' &&
         nextChar != '\r' &&
         uartStringCount < UART_MAXSTRLEN ) {
            uartString[uartStringCount] = nextChar;
            uartStringCount++;
        }
        else {
            uartString[uartStringCount] = '\0';
            uartStringComplete = true;
        }
    }
}

void GpioInit(){
    DDRB = 0;
    DDRC = 0;
    DDRD = 0;
    
    DDRB |= (1 << PB0); // set IR TRANSMITTER as output
    DDRB &= ~(1 << PB1); // set CW button as input
    DDRB |= (1 << PB2); // set status LED as output
    DDRB &= ~(1 << PB3); // set HOMING as input

    DDRC |= (1 << PC1); // set DIR as output
    DDRC |= (1 << PC2); // set STEP as output
    DDRC &= ~(1 << PC5); // set ENDSTOP as input

    DDRD |= (1 << PD3); // set TXD as output
    DDRD &= ~(1 << PD5); // set LEFT as input
    DDRD &= ~(1 << PD6); // set CCW as input
    DDRD &= ~(1 << PD7); // set RIGHT as input

    PORTC &= ~(1 << PC2); //save set step to low
    PORTD &= ~(1 << PD3); //save set TXD to low
}

void UartInit(){
    DDRD &= ~(1<<PD0);
    PORTD |= (1<<PD0);
    UBRR0H = UBRR_VAL >> 8;
    UBRR0L = UBRR_VAL & 0xFF;
    UCSR0C = (1<<UCSZ01)|(1<<UCSZ00); // async 8N1
    UCSR0B |= (1<<RXEN0)|(1<<TXEN0)|(1<<RXCIE0);  // enable UART RX, TX und RX interrupt
}

void doStep(){
    PORTC |= (1 << PC2);
    _delay_ms(1);
    PORTC &= ~(1 << PC2);
    _delay_ms(5);
}

void writeByte(uint8_t b){

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
    _delay_us(104);         // TIME BETWEEN BYTES SENT
}

int main (){
    GpioInit();

    UartInit();
    
    while(true){

        if((PIND >> PD5) & 1){  // if left
            PORTC |= (1 << PC1);
            PORTB |= (1 << PB2);
            doStep();
            writeByte('J');
        }
        else if((PIND >> PD7) & 1){ // if right
            PORTC &= ~(1 << PC1);
            PORTB |= (1 << PB2);
            doStep();
            writeByte('J');
        }else if((PINB >> PB3) & 1){    // if homing
            PORTB |= (1 << PB2); // LED
            PORTB |= (1 << PB0); // IR
        }else if(PINC >> PC5){
            PORTB |= (1 << PB2); // LED

        }
        else{
            PORTB &= ~(1 << PB0);
            PORTB &= ~(1 << PB2);
        }

        if(uartStringComplete){
            for(uint8_t i=0; i<uartStringCount; i++){
                writeByte(uartString[i]);
            }
            uartStringComplete = false;
        }
    }

    return 0;

}