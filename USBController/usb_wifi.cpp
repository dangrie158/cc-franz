#define ARDUINO 105
#define SB_VID null
#define USB_PID null

#include "delay.h"
#include "hid.h"
#include "hiduniversal.h"
#include "usbhub.h"
#include "SPI.h"
#include "hidjoystickrptparser.h"

extern "C"
{
    #include "utils.h"    
    #include "wiring_private.h"
}

int main(void)
{
    init();
    USB Usb;
    USBHub Hub(&Usb);
    HIDUniversal Hid(&Usb);
    JoystickEvents JoyEvents;
    JoystickReportParser Joy(&JoyEvents);
    DDRD = DDRD | 0b00010000;

    Usb.Init();
    _delay_ms(200);
    Hid.SetReportParser(0, &Joy);

    while(1)
    {
    	Usb.Task();
    }

}