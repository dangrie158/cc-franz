#define DIR_LEFT 1
#define DIR_RIGHT 0

#define BAUD 9600L      // Baudrate
#define UART_MAXSTRLEN 47
// Berechnungen
#define UBRR_VAL ((F_CPU+BAUD*8)/(BAUD*16)-1)   // F_CPU is defined in make
#define BAUD_REAL (F_CPU/(16*(UBRR_VAL+1)))     // real baudrate