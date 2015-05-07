/*
  clock_gen:
  
  Uses an Arduino Uno (ATMega328P chip) to produce two master clock signals:
  
  pin 3: 2MHz clock output
  pin 5: 1kHz clock output
  
  where the pin numbers are board pin numbers, not chip pin numbers.
  
  This will not work on anything but the Arduino Uno. Make sure to use the Uno that has a crystal oscillator, since these have 0.01% temporal accuracy as opposed to RC oscillators, which are worse.
   
  @author John Choi 
*/

#include <avr/io.h>  
#include <avr/interrupt.h> 

// Pin designations
const int SWITCH1_PIN = 2;
const int SWITCH2_PIN = 4;
const int DIRECT_TRIG_PIN = 7;
const int LED_PIN = 12;
const int TRIG_OUT_PIN = 8;
const int FAST_PWM_PIN = 3;
const int SLOW_PWM_PIN = 5;

const double dbtime = 100e-3;  // debounce time

typedef enum    // debounce state enum
  {LOW_READY, LOW_IGNORING, HIGH_READY, HIGH_IGNORING}
  DebounceState; 

// globals
double t;
DebounceState dbstate;
double t_dbstart;
bool sw_debounce;

void setup() {
  cli(); // disable interrupts
  // pin 3 2MHz output using timer 2
  TCCR2A = 0xB3 ; // fast PWM with programmed TOP val
  TCCR2B = 0x09 ; // divide by 1 prescale
  TCNT2  = 0x00 ;
  OCR2A  = 0x07; // TOP = 7, cycles every 8 clocks
  OCR2B  = 0x05 ; // COMP for pin3

  // pin 5 1kHz output using timer 0
  TCCR0A = 0xB3 ; // fast PWM with programmed TOP val
  TCCR0B = 0x0B; // divide by 64 prescale
  TCNT0  = 0x00;
  OCR0A  = 0xF9; // TOP = 249, every 250 clocks
  OCR0B  = 0x64 ; // COMP value

  // timer 1 handles global timing, 500Hz. No output pin
  TCCR1A = 0;
  TCCR1B = 0;
  TCNT1 = 0;
  OCR1A = 0x007C; // 16MHz/(500Hz * 256) -1 = 124 = 0x007C
  TCCR1B |= (1 << WGM12);  // Mode 4, CTC on OCR1A
  TCCR1B |= (1 << CS12);   // set prescaler to 256
  TIMSK1 |= (1 << OCIE1A);  //Set interrupt on compare match
 
  t = 0.0; // set global time to 0
  sei(); // enable interrupts
  
  pinMode (SWITCH1_PIN, INPUT);     // pin directionalities
  pinMode (SWITCH2_PIN, INPUT);
  pinMode (DIRECT_TRIG_PIN, INPUT);
  pinMode (TRIG_OUT_PIN, OUTPUT);
  pinMode (LED_PIN, OUTPUT);  
  pinMode (FAST_PWM_PIN, OUTPUT);
  pinMode (SLOW_PWM_PIN, OUTPUT);
  
  analogWrite(FAST_PWM_PIN, 3);   // set duty cycles of clock outputs
  analogWrite(SLOW_PWM_PIN, 100);

  dbstate = LOW_READY; // debounce state init
  sw_debounce = 0;  
  t_dbstart = 0.0;
}




void loop() {
  
  // debounce using timer 1
  bool direct = digitalRead(DIRECT_TRIG_PIN);
  bool sw = digitalRead(SWITCH1_PIN) || digitalRead(SWITCH2_PIN);
    
  switch (dbstate)
    {
    case LOW_READY:
      if (sw){
  	sw_debounce = 1;
  	dbstate = HIGH_IGNORING;
  	t_dbstart = t;
      }
      break;
    case HIGH_IGNORING:
      if (t - t_dbstart >= dbtime){
  	dbstate = HIGH_READY;
      }
      break;
    case HIGH_READY:
      if (!sw){
  	sw_debounce = 0;
  	dbstate = LOW_IGNORING;
  	t_dbstart = t;
      }
      break;
    case LOW_IGNORING:
      if (t - t_dbstart >= dbtime){	
  	dbstate = LOW_READY;
      }
      break;

    }
  
  digitalWrite(TRIG_OUT_PIN, sw_debounce || direct);
  digitalWrite(LED_PIN, sw_debounce || direct);

}


ISR(TIMER1_COMPA_vect){
  t+= 0.002;   // called every 2ms (500Hz)   
}



