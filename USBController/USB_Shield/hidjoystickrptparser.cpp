#include "hidjoystickrptparser.h"


JoystickEvents::JoystickEvents()
{
    strcpy(rotateCommand, "R000\r\n");
    strcpy(moveCommand, "M000\r\n");
}

JoystickReportParser::JoystickReportParser(JoystickEvents *evt) :
joyEvents(evt),
oldHat(0xDE),
oldButtons(0) {
        for (uint8_t i = 0; i < RPT_GEMEPAD_LEN; i++)
                oldPad[i] = 0xD;
}

void JoystickReportParser::Parse(HID *hid, bool is_rpt_id, uint8_t len, uint8_t *buf) {
        bool match = true;

        // Checking if there are changes in report since the method was last called
        for (uint8_t i = 0; i < RPT_GEMEPAD_LEN; i++)
                if (buf[i] != oldPad[i]) {
                        match = false;
                        break;
                }

        // Calling Game Pad event handler
        if (!match && joyEvents) {
                joyEvents->OnGamePadChanged((const GamePadEventData*)buf);

                for (uint8_t i = 0; i < RPT_GEMEPAD_LEN; i++) oldPad[i] = buf[i];
        }

        uint8_t hat = (buf[5] & 0xF);

        // Calling Hat Switch event handler
        if (hat != oldHat && joyEvents) {
                joyEvents->OnHatSwitch(hat);
                oldHat = hat;
        }

        uint16_t buttons = (0x0000 | buf[6]);
        buttons <<= 4;
        buttons |= (buf[5] >> 4);
        uint16_t changes = (buttons ^ oldButtons);

        // Calling Button Event Handler for every button changed
        if (changes) {
                for (uint8_t i = 0; i < 0x0C; i++) {
                        uint16_t mask = (0x0001 << i);

                        if (((mask & changes) > 0) && joyEvents)
                                if ((buttons & mask) > 0)
                                        joyEvents->OnButtonDn(i + 1);
                                else
                                        joyEvents->OnButtonUp(i + 1);
                }
                oldButtons = buttons;
        }
}

void JoystickEvents::OnGamePadChanged(const GamePadEventData *evt) {
        
        dirtyMove = true;
        dirtyRotate = true;

        // Doing Movement?
        if(evt->Z2 == 255)
        {
            moveDir = '+';
        }
        else if(evt->Z2 == 0)
        {
            moveDir = '-';
        }
        else
        {
            moveDir = '0';
        }

        // Doing Rotation?
        if(evt->Rz == 255)
        {
            rotateDir = '+';
        }
        else if(evt->Rz == 0)
        {
            rotateDir = '-';
        }
        else
        {
            rotateDir = '0';
        }

        resetted = false;
}

// Not used in this implementation
void JoystickEvents::OnHatSwitch(uint8_t hat) {}

void JoystickEvents::OnButtonUp(uint8_t but_id) {

        dirtyMove = true;
        dirtyRotate = true;

        // L Button was pushed
        if(but_id == 5)
        {
            lPressed = false;
        }

        // R Button was pushed
        else if(but_id == 6)
        {
            rPressed = false;
        }
}

void JoystickEvents::OnButtonDn(uint8_t but_id) {

        dirtyMove = true;
        dirtyRotate = true;

        uint8_t maxSpeed = 255;

        // Start Button was pushed
        // Reset both to Zero
        if(but_id == 10)
        {
            strcpy(rotateCommand, "R000\r\n");
            rotateSpeed = 0;
            rotateDir = '0';
            strcpy(moveCommand, "M000\r\n");
            moveSpeed = 0;
            moveDir = '0';
            resetted = true;
        }

        // X Button was pushed
        // Rotation Speed is high
        else if(but_id == 1)
        {
            rotateSpeed = maxSpeed/2;
            resetted = false;
        }

        // A Button was pushed
        // Move Speed is high
        else if(but_id == 2)
        {
            moveSpeed = maxSpeed/2;
            resetted = false;
        }

        // B Button was pushed
        // Move Speed is low
        else if(but_id == 3)
        {
            moveSpeed = maxSpeed/8;
            resetted = false;
        }

        // Y Button was pushed
        // Rotation Speed is low
        else if(but_id == 4)
        {
            rotateSpeed = maxSpeed/8;
            resetted = false;
        }

        // L Button was pushed
        else if(but_id == 5)
        {
            lPressed = true;
            resetted = false;
        }

        // R Button was pushed
        else if(but_id == 6)
        {
            rPressed = true;
            resetted = false;
        }
}

void JoystickEvents::GetMoveCommand() {

    if(dirtyMove)
    {
        uint8_t moveStep = 2;
        if(lPressed)
        {
            moveSpeed -= moveStep;
        }
        if(rPressed)
        {
            moveSpeed += moveStep;
        }
    
        // Create Move Command
        char moveSign[3];
        itoa(moveSpeed, moveSign, 16);
        char moving[7];
        char movePrefix = 'M';
    
        if(resetted)
        {
            uart_writeString(moveCommand);
            dirtyMove = false;
            return;
        }
        else
        {
            strcpy(moving, &movePrefix);
            strcpy(moving+1, &moveDir);
            strcpy(moving+2, moveSign);
            strcpy(moving+4, "\r\n");
            strcpy(moveCommand, moving);
        }
    
        //uart_writeString("Move Command:\r\n");
        uart_writeString(moveCommand);
        //uart_writeString("\r\n");
        dirtyMove = false;
    }
}

void JoystickEvents::GetRotateCommand() {

    if(dirtyRotate)
    {
        // Create Rotate Command
        char rotSign[3];
        itoa(rotateSpeed, rotSign, 16);
        char rotating[7];
        char rotatePrefix = 'R';

        if(resetted)
        {
            uart_writeString(rotateCommand);
            dirtyRotate = false;
            return;
        }
        else
        {
            strcpy(rotating, &rotatePrefix);
            strcpy(rotating+1, &rotateDir);
            strcpy(rotating+2, rotSign);
            strcpy(rotating+4, "\r\n");
            strcpy(rotateCommand, rotating);
        }

        //uart_writeString("Rotate Command:\r\n");
        uart_writeString(rotateCommand);
        //uart_writeString("\r\n");

        dirtyRotate = false;
    }
}
