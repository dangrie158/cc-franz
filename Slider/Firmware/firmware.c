#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include <util/delay.h>
#include <avr/interrupt.h>
#include <avr/io.h>

#include "constants.h"

#include "uart.h"
#include "timer.h"
#include "software_uart.h"

#define __LOGARITHMIC_SPEED__ 1

volatile uint8_t speedLinear = 0;
volatile uint8_t speedAngular = 0;

volatile uint32_t stepCounterLinear = 0;
volatile uint32_t stepCounterAngular = 0;

volatile uint32_t sendPositionDebounceCounter = 0;

volatile bool linearDirection = DIR_LEFT; 
volatile bool angularDirection = DIR_CW; 

volatile bool linearStopped = false; 
volatile bool angularStopped = false; 

void gpioInit()
{
    // save set all DDRs to a known state
    DDRB = 0x00;
    DDRC = 0x00;
    DDRD = 0x00;

    // set all pin DDRs
    SET(IR_DDR, IR_PIN); // set IR TRANSMITTER as output
    SET(LED_DDR, LED_PIN); // set status LED as output
    SET(SOFT_UART_DDR, SOFT_UART_TX_PIN); // set TXD as output

    SET(MOTOR_DRIVER_DDR, ANGULAR_DIR_PIN); // set DIR1 as output
    SET(MOTOR_DRIVER_DDR, ANGULAR_STEP_PIN); // set STEP1 as output
    SET(MOTOR_DRIVER_DDR, LINEAR_DIR_PIN); // set DIR2 as output
    SET(MOTOR_DRIVER_DDR, LINEAR_STEP_PIN); // set STEP2 as output

    CLEAR(BUTTON_LEFT_DDR, BUTTON_LEFT_PIN); // set LEFT as input
    CLEAR(BUTTON_RIGHT_DDR, BUTTON_RIGHT_PIN); // set RIGHT as input
    CLEAR(BUTTON_CCW_DDR, BUTTON_CCW_PIN); // set CCW as input
    CLEAR(BUTTON_CW_DDR, BUTTON_CW_PIN); // set CW button as input
    CLEAR(BUTTON_HOMING_DDR, BUTTON_HOMING_PIN); // set HOMING as input
    CLEAR(ENDSTOP_TRIGGER_DDR, ENDSTOP_TRIGGER_PIN); // set ENDSTOP as input
}

void doLinearStep(uint8_t dir)
{
    //increment or decrement the step counter
    dir ? stepCounterLinear++ : stepCounterLinear--;

    //set the dir pin to the direction
    VALUE(MOTOR_DRIVER_PORT, LINEAR_DIR_PIN, dir);

    //set the step pin high
    SET(MOTOR_DRIVER_PORT, LINEAR_STEP_PIN);

    //wait a millisecond
    _delay_ms(1);

    //set the step count back low
    CLEAR(MOTOR_DRIVER_PORT, LINEAR_STEP_PIN);

    //wait another millisecond
    _delay_ms(1);
}
void doAngularStep(uint8_t dir)
{
    //increment or decrement the step counter
    dir ? stepCounterAngular++ : stepCounterAngular--;

    //set the dir pin to the direction
    VALUE(MOTOR_DRIVER_PORT, ANGULAR_DIR_PIN, dir);

    //set the step pin high
    SET(MOTOR_DRIVER_PORT, ANGULAR_STEP_PIN);

    //wait a millisecond
    _delay_ms(1);

    //set the step count back low
    CLEAR(MOTOR_DRIVER_PORT, ANGULAR_STEP_PIN);

    //wait another millisecond
    _delay_ms(1);
}

void timerElapsed()
{
    static uint8_t timeoutCounterLinear = 0;
    static uint8_t timeoutCounterAngular = 0;

    timeoutCounterLinear++;
    timeoutCounterAngular++;
    sendPositionDebounceCounter++;

    if (timeoutCounterLinear >= speedLinear && !linearStopped) {

        //set the direction pin
        VALUE(MOTOR_DRIVER_PORT, LINEAR_DIR_PIN, linearDirection);

        timeoutCounterLinear = 0;
        //increment step counter because we're going to perform a step
        linearDirection ? stepCounterLinear++ : stepCounterLinear--;
        // set move pin high, to perform a step
        SET(MOTOR_DRIVER_PORT, LINEAR_STEP_PIN);
    }
    else {
        // set step pin low again to be ready for the next step
        CLEAR(MOTOR_DRIVER_PORT, LINEAR_STEP_PIN);
    }

    if (timeoutCounterAngular >= speedAngular && !angularStopped) {

        //set the direction pin
        VALUE(MOTOR_DRIVER_PORT, ANGULAR_DIR_PIN, angularDirection);

        timeoutCounterAngular = 0;
        //increment step counter because we're going to perform a step
        linearDirection ? stepCounterAngular++ : stepCounterAngular--;
        // set rotate pin high to do a step
        SET(MOTOR_DRIVER_PORT, ANGULAR_STEP_PIN);
    }
    else {
        // set step pin low again to be ready for the next step
        CLEAR(MOTOR_DRIVER_PORT, ANGULAR_STEP_PIN);
    }
}

void handleUI()
{
    if (ISSET(BUTTON_LEFT_PORT, BUTTON_LEFT_PIN)) { // if left pressed
        SET(LED_PORT, LED_PIN); // switch on LED while button is pressed
        doLinearStep(DIR_LEFT);
    }
    else if (ISSET(BUTTON_RIGHT_PORT, BUTTON_RIGHT_PIN)) { // if right pressed
        SET(LED_PORT, LED_PIN); // switch on LED while button is pressed
        doLinearStep(DIR_RIGHT);
    }
    else if (ISSET(BUTTON_CCW_PORT, BUTTON_CCW_PIN)) { // if ccw pressed
        SET(LED_PORT, LED_PIN); // switch on LED while button is pressed
        doAngularStep(DIR_CCW);
    }
    else if (ISSET(BUTTON_CW_PORT, BUTTON_CW_PIN)) { // if cw pressed
        SET(LED_PORT, LED_PIN); // switch on LED while button is pressed
        doAngularStep(DIR_CW);
    }
    else if (PINC >> PC5) { // endstop triggered

        SET(LED_PORT, LED_PIN); // LED on
    }
    else {
        CLEAR(IR_PORT, IR_PIN); // switch off IR output driver
        CLEAR(LED_PORT, LED_PIN); // switch off LED
    }
}

int speedStringToSpeed(char* speedString){
#if __LOGARITHMIC_SPEED__
                return ((1.0f / strtol(speedString, NULL, 16)) * 255);
#else
                return 255 - strtol(speedString, NULL, 16);
#endif
}

void handleUartMessages()
{
    if (uartAvailable()) {
        char line[RX_BUFF];
        uartReadLine(line);

        if (line[0] == 'M') {
            if (line[1] == '+') {
                linearStopped = false;
                linearDirection = DIR_RIGHT;
                speedLinear = speedStringToSpeed(line + 2);
            }
            else if (line[1] == '-') {
                linearStopped = false;
                linearDirection = DIR_LEFT;
                speedLinear = speedStringToSpeed(line + 2);
            }
            else if (line[1] == '0') {
                linearStopped = true;
            }
        }
        else if (line[0] == 'R') {
            if (line[1] == '+') {
                angularStopped = false;
                angularDirection = DIR_CW;
                speedAngular = speedStringToSpeed(line + 2);
            }
            else if (line[1] == '-') {
                angularStopped = false;
                angularDirection = DIR_CCW;
                speedAngular = speedStringToSpeed(line + 2);
            }
            else if (line[1] == '0') {
                angularStopped = true;
            }
        }
    }
}

void handleHardcodedScript()
{
    static bool running = false;
    static uint8_t totalSteps = 0;

    if (ISSET(BUTTON_HOMING_PORT, BUTTON_HOMING_PIN)) { // start the script if the
        // homing button was
        // pressed
        running = true; // start the script
    }

    // check if the script was started
    if (running) {
        SET(LED_PORT, LED_PIN); // LED on

        if (totalSteps % 12 == 0) {
            doAngularStep(DIR_CW);
        }

        doLinearStep(DIR_LEFT);

        totalSteps++;

        _delay_ms(100);
    }
}

void checkPositionAndSendUpdate(){
    static int lastStepCountLinear = 0;
    static int lastStepCountAngular = 0;

    if(lastStepCountAngular != stepCounterAngular){
        char* message = "PM0000";
        if(stepCounterAngular <= 0xFFFF){
            //write the speed to the buffer at offset 2
            itoa(stepCounterAngular, message + 2, 16);
        
            uartWriteLine(message);
            lastStepCountAngular = stepCounterAngular;
        }
    }

    if(lastStepCountLinear != stepCounterLinear){
        char* message = "PR0000";
        if(stepCounterLinear <= 0xFFFF){
            //write the speed to the buffer at offset 2
            itoa(stepCounterLinear, message + 2, 16);
        
            uartWriteLine(message);
            lastStepCountLinear = stepCounterLinear;
        }
        lastStepCountLinear = stepCounterLinear;
    }
}

int main()
{
    // setup GPIO functions
    gpioInit();

    // register timer callback and start timer
    timerInit(timerElapsed);

    // setup hardware UART
    uartInit();
    
    // mainloop
    while (true) {
        handleUI();

        handleUartMessages();

        handleHardcodedScript();
        if(sendPositionDebounceCounter >= POSITION_DEBOUNCE_DELAY){   
            checkPositionAndSendUpdate();
            sendPositionDebounceCounter = 0;
        }
    }

    return 0;
}