; ==============================================================================
; Project:       AVR Assembler Lessons
; Author:        Kevin Thomas
; Version:       1.0.0
; Date:          2026-06-28
; Target Device: ATmega328P
; Clock Freq:    16 MHz
; Toolchain:     avr-as, avr-ld, avrdude
; Description:   Lesson 001 - Hello Button World
; ==============================================================================

; ==============================================================================
; TEXT SECTION
; ==============================================================================
.section .text

; ==============================================================================
; DEFINES
; ==============================================================================
  .equ RAMEND, 0x08FF                  ; Last SRAM address (ATmega328P)
  .equ SPL,    0x3D                    ; Stack Pointer Low register
  .equ SPH,    0x3E                    ; Stack Pointer High register
  .equ DDRB,   0x04                    ; Port B Data Direction Register
  .equ PORTB,  0x05                    ; Port B Data Register
  .equ PB5,    5                       ; Port B Pin 5 (built-in LED)
  .equ DDRD,   0x0A                    ; Port D Data Direction Register
  .equ PORTD,  0x0B                    ; Port D Data Register
  .equ PIND,   0x09                    ; Port D Input Pins Register
  .equ PD2,    2                       ; Port D Pin 2 (Button)

; ==============================================================================
; RESET VECTOR
; ==============================================================================
  .org 0x0000                          ; Program starts at address 0
  RJMP   main                          ; Jump to main program

; ==============================================================================
; SUBROUTINE:  main
; ==============================================================================
; Description: Sets up the stack pointer, configures PB5 as an output for the
;              LED, configures PD2 as an input for the button, enables the
;              internal pull-up resistor on PD2, and then continually reads PD2
;              to toggle the LED state.
; ------------------------------------------------------------------------------
; Parameters:  None
; Returns:     None
; ==============================================================================
main:                             
  LDI    R16, lo8(RAMEND)              ; R16 = low byte of last RAM address
  OUT    SPL, R16                      ; Stack Pointer Low = R16
  LDI    R16, hi8(RAMEND)              ; R16 = high byte of last RAM address
  OUT    SPH, R16                      ; Stack Pointer High = R16
  SBI    DDRB, PB5                     ; DDRB bit 5 = 1, PB5 becomes an output
  CBI    DDRD, PD2                     ; DDRD bit 2 = 0, PD2 becomes an input
  SBI    PORTD, PD2                    ; PORTD bit 2 = 1, enable PD2 pull-up
.loop:                            
  SBIS   PIND, PD2                     ; Skip next instruction if PD2 is HIGH
  RJMP   .btn_pressed                  ; Jump to btn_pressed if PD2 is LOW
  CBI    PORTB, PB5                    ; PB5 = 0, LED turns OFF
  RJMP   .loop                         ; Jump back to loop
.btn_pressed:                     
  SBI    PORTB, PB5                    ; PB5 = 1, LED turns ON
  RJMP   .loop                         ; Jump back to loop
