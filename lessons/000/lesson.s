; ==============================================================================
; Project:       AVR Assembler Lessons
; Author:        Kevin Thomas
; Version:       1.0.0
; Date:          2026-06-28
; Target Device: ATmega328P
; Clock Freq:    16 MHz
; Toolchain:     avr-as, avr-ld, avrdude
; Description:   Lesson 000 - Hello Blinky World
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

; ==============================================================================
; RESET VECTOR
; ==============================================================================
  .org 0x0000                          ; Program starts at address 0
  RJMP   main                          ; Jump to main program

; ==============================================================================
; SUBROUTINE:  main
; ==============================================================================
; Description: Sets up the stack pointer so we can use subroutines, configures
;              PB5 as an output pin, then blinks the LED on and off forever.
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
.loop:                            
  SBI    PORTB, PB5                    ; PB5 = 1, LED turns ON
  RCALL  delay                         ; Wait exactly half a second
  CBI    PORTB, PB5                    ; PB5 = 0, LED turns OFF
  RCALL  delay                         ; Wait exactly half a second
  RJMP   .loop                         ; Jump back and blink forever

; ==============================================================================
; SUBROUTINE:  delay
; ==============================================================================
; Description: 24-bit countdown loop that burns exactly 0.5 seconds.
;              Clobbers R16, R17, R18.
; ------------------------------------------------------------------------------
; Parameters:  None
; Returns:     None
; ==============================================================================
delay:                            
  LDI    R18, 0x18                     ; 24-bit counter High Byte (1599998)
  LDI    R17, 0x69                     ; 24-bit counter Mid Byte
  LDI    R16, 0xFE                     ; 24-bit counter Low Byte
.d_loop:                          
  SUBI   R16, 1                        ; Subtract 1 from Low Byte
  SBCI   R17, 0                        ; Subtract carry from Mid Byte
  SBCI   R18, 0                        ; Subtract carry from High Byte
  BRNE   .d_loop                       ; Branch if the 24-bit result != 0
  NOP                                  ; Padding to get exactly 8M cycles
  RET                                  ; Return to caller
