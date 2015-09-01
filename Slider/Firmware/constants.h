#ifndef __CONSTANTS_H__
#define __CONSTANTS_H__

#include <avr/io.h>

/********************************/
/*        HELPER MACROS         */
/********************************/
#define SET(PORT,PIN) ((PORT) |= ((1) << (PIN)))
#define CLEAR(PORT,PIN) ((PORT) &= ~((1) << (PIN)))
#define TOGGLE(PORT,PIN) ((PORT) ^= ((1) << (PIN)))
#define ISSET(PORT, PIN) (((PORT) >> (PIN)) & (1))
#define VALUE(PORT, PIN, STATUS) (PORT) = (PORT) & ~((uintmax_t)(1) << (PIN)) | ((uintmax_t)(STATUS) << (PIN))

/********************************/
/*     VARIOUS DEFINITIONS      */
/*       FOR READABILITY        */
/********************************/
#define DIR_LEFT 1
#define DIR_RIGHT 0
#define DIR_CW 0
#define DIR_CCW 1

#define POSITION_DEBOUNCE_DELAY 100 //send positions every x microseconds

/********************************/
/*       SOFTWARE UART          */
/********************************/
#define SOFT_UART_BAUD_RATE 9600
#define SECONDS_TO_MICROSECONDS 1000000
#define SOFT_UART_BITTIME (SECONDS_TO_MICROSECONDS / SOFT_UART_BAUD_RATE) // 1/9600 BAUD = 104µS

/********************************/
/*       PIN DEFINITIONS        */
/********************************/

/************ OUTPUTS ***********/

#define MOTOR_DRIVER_PORT PORTC
#define MOTOR_DRIVER_DDR DDRC
#define LINEAR_DIR_PIN PC1
#define ANGULAR_DIR_PIN PC3
#define LINEAR_STEP_PIN PC2
#define ANGULAR_STEP_PIN PC4

#define LED_PORT PORTB
#define LED_DDR DDRB
#define LED_PIN PB2

#define IR_PORT PORTB
#define IR_DDR DDRB
#define IR_PIN PB0

#define SOFT_UART_PORT PORTD
#define SOFT_UART_DDR DDRD
#define SOFT_UART_TX_PIN PD3

/************* INPUTS ***********/

#define BUTTON_LEFT_PORT PIND
#define BUTTON_LEFT_DDR DDRD
#define BUTTON_LEFT_PIN PD5

#define BUTTON_RIGHT_PORT PIND
#define BUTTON_RIGHT_DDR DDRD
#define BUTTON_RIGHT_PIN PD7

#define BUTTON_CCW_PORT PIND
#define BUTTON_CCW_DDR DDRD
#define BUTTON_CCW_PIN PD6

#define BUTTON_CW_PORT PINB
#define BUTTON_CW_DDR DDRB
#define BUTTON_CW_PIN PB1

#define BUTTON_HOMING_PORT PINB
#define BUTTON_HOMING_DDR DDRB
#define BUTTON_HOMING_PIN PB3

#define ENDSTOP_TRIGGER_PORT PINC
#define ENDSTOP_TRIGGER_DDR DDRC
#define ENDSTOP_TRIGGER_PIN PC5

#endif //__CONSTANTS_H__
