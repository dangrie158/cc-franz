#if !defined(__HIDJOYSTICKRPTPARSER_H__)
#define __HIDJOYSTICKRPTPARSER_H__

#include <hid.h>
#include <string.h>
#include <stdlib.h>

extern "C"
{
    #include "utils.h"    
}

// Kind of Data that come from the HID gamepad
struct GamePadEventData {
        uint8_t X, Y, Z1, Z2, Rz;
};

// Kind of Events that can occure for the USBController
class JoystickEvents {

        char rotateCommand[7];
        char moveCommand[7];
        char moveDir = '0';
        char rotateDir = '0';
        bool lPressed = false;
        bool rPressed = false;
        bool resetted = true;
        bool dirtyRotate = false;
        bool dirtyMove = false;
        uint8_t rotateSpeed = 0;
        uint8_t moveSpeed = 0;

public:
        JoystickEvents();

        // events when the gamepad state changes
        virtual void OnGamePadChanged(const GamePadEventData *evt);
        virtual void OnHatSwitch(uint8_t hat);
        virtual void OnButtonUp(uint8_t but_id);
        virtual void OnButtonDn(uint8_t but_id);

        // Functions that enable the parser to send the current command
        void SendMoveCommand();
        void SendRotateCommand();
};

#define RPT_GEMEPAD_LEN		5

class JoystickReportParser : public HIDReportParser {
        JoystickEvents *joyEvents;

        uint8_t oldPad[RPT_GEMEPAD_LEN];
        uint8_t oldHat;
        uint16_t oldButtons;

public:
        JoystickReportParser(JoystickEvents *evt);

        virtual void Parse(HID *hid, bool is_rpt_id, uint8_t len, uint8_t *buf);
};

#endif // __HIDJOYSTICKRPTPARSER_H__
