//Defines for compatibility to Arduino IDE
#define ARDUINO 105
#define SB_VID null
#define USB_PID null

// Includes from the USB Library
#include "usbhub.h"
#include "hid.h"
#include "hiduniversal.h"
#include "hidjoystickrptparser.h"

// Timing and SPI Protocol
#include "delay.h"
#include "SPI.h"

// UART and other Stuff
extern "C"
{
    #include "utils.h"    
    #include "wiring_private.h"
}

// main entry routine
int main(void)
{
    // Init Timing and UART
    init();
    uart_init();
    uart_writeString("UART initialized.\r\n");

    // Init USB Functionality
    USB Usb;
    USBHub Hub(&Usb);
    HIDUniversal Hid(&Usb);
    JoystickEvents JoyEvents;
    JoystickReportParser Joy(&JoyEvents);
    Usb.Init();
    _delay_ms(200);
    // Joy is the report structure that gets the USB events when actions are performed
    // and sets the correct move or rotate command respectively the current pressed buttons
    Hid.SetReportParser(0, &Joy);
    uart_writeString("USB initialized.\r\n");

    // endless loop, check USB events and send move / rotate commands through UART
    while(1)
    {
    	Usb.Task();
        JoyEvents.SendMoveCommand();
        JoyEvents.SendRotateCommand();
    }

}