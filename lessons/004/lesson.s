; ==============================================================================
; Project:       AVR Assembler Lessons
; Author:        Kevin Thomas
; Version:       1.0.0
; Date:          2026-06-29
; Target Device: ATmega328P
; Clock Freq:    16 MHz
; Toolchain:     avr-as, avr-ld, avrdude
; Description:   Lesson 004 - Receiving Data
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
  .equ UBRR0L, 0xC4                    ; UART Baud Rate Register Low
  .equ UBRR0H, 0xC5                    ; UART Baud Rate Register High
  .equ UCSR0A, 0xC0                    ; UART Control and Status Register A
  .equ UCSR0B, 0xC1                    ; UART Control and Status Register B
  .equ UCSR0C, 0xC2                    ; UART Control and Status Register C
  .equ UDR0,   0xC6                    ; UART Data Register
  .equ TXC0,   6                       ; Transmit Complete Flag Bit
  .equ TXEN0,  3                       ; Transmitter Enable Bit
  .equ RXEN0,  4                       ; Receiver Enable Bit
  .equ UCSZ01, 2                       ; Character Size Bit 1
  .equ UCSZ00, 1                       ; Character Size Bit 0
  .equ UDRE0,  5                       ; USART Data Register Empty Bit
  .equ RXC0,   7                       ; USART Receive Complete Bit


; ==============================================================================
; RESET VECTOR
; ==============================================================================
  .org 0x0000                          ; Program starts at address 0
  RJMP   main                          ; Jump to main program

; ==============================================================================
; SUBROUTINE:  main
; ==============================================================================
; Description: Sets up stack pointer, calls UART init, and enters echo loop.
; ------------------------------------------------------------------------------
; Parameters:  None
; Returns:     None
; ==============================================================================
main:
  LDI    R16, lo8(RAMEND)              ; R16 = low byte of last RAM address
  OUT    SPL, R16                      ; Stack Pointer Low = R16
  LDI    R16, hi8(RAMEND)              ; R16 = high byte of last RAM address
  OUT    SPH, R16                      ; Stack Pointer High = R16
  RCALL  uart_init                     ; Call UART initialization routine
.loop:
  RCALL  uart_receive                  ; Wait for character, put in R16
  RCALL  uart_transmit                 ; Transmit character in R16
  RJMP   .loop                         ; Infinite loop to echo back data

; ==============================================================================
; SUBROUTINE:  uart_init
; ==============================================================================
; Description: Initializes UART for 9600 baud, 8 data bits, 1 stop bit,
;              parity. Uses 16 MHz clock, so UBRR0 = 103. Flushes RX buffer.
;              Clobbers R16.
; ------------------------------------------------------------------------------
; Parameters:  None
; Returns:     None
; ==============================================================================
uart_init:                        
  LDI    R16, (1<<TXC0)                ; Clear TXC0, Normal Speed (U2X0=0)
  STS    UCSR0A, R16                   ; Store to Control and Status Reg A
  LDI    R16, 0                        ; UBRR0H = 0
  STS    UBRR0H, R16                   ; Store into upper byte of baud rate
  LDI    R16, 103                      ; UBRR0L = 103 (9600 baud at 16 MHz)
  STS    UBRR0L, R16                   ; Store into lower byte of baud rate
  LDI    R16, (1<<TXEN0)|(1<<RXEN0)    ; Enable transmitter and receiver
  STS    UCSR0B, R16                   ; Store to Control and Status Reg B
  LDI    R16, (1<<UCSZ01)|(1<<UCSZ00)  ; 8 data bits, 1 stop bit, no parity
  STS    UCSR0C, R16                   ; Store to Control and Status Reg C
.flush_rx:                        
  LDS    R16, UCSR0A                   ; Read UCSR0A into R16
  SBRS   R16, 7                        ; Skip next if RXC0 (bit 7) is set
  RJMP   .flush_done                   ; If empty, we are done flushing
  LDS    R16, UDR0                     ; Read UDR0 to flush the buffer
  RJMP   .flush_rx                     ; Loop back to check again
.flush_done:                      
  RET                                  ; Return to caller

; ==============================================================================
; SUBROUTINE:  uart_receive
; ==============================================================================
; Description: Waits until the UART receive buffer has data, then reads it.
;              Clobbers R17.
; ------------------------------------------------------------------------------
; Parameters:  None
; Returns:     R16 = Received character
; ==============================================================================
uart_receive:
  LDS    R17, UCSR0A                   ; Read UCSR0A into R17
  SBRS   R17, RXC0                     ; Skip next instruction if RXC0 is set
  RJMP   uart_receive                  ; Otherwise loop back and check again
  LDS    R16, UDR0                     ; Read UART Data Register into R16
  RET                                  ; Return to caller

; ==============================================================================
; SUBROUTINE:  uart_transmit
; ==============================================================================
; Description: Waits until the UART transmit buffer is empty, then sends the
;              character contained in R16.
;              Clobbers R17.
; ------------------------------------------------------------------------------
; Parameters:  R16 = Character to transmit
; Returns:     None
; ==============================================================================
uart_transmit:
  LDS    R17, UCSR0A                   ; Read UCSR0A into R17
  SBRS   R17, UDRE0                    ; Skip next instruction if UDRE0 is set
  RJMP   uart_transmit                 ; Otherwise loop back and check again
  STS    UDR0, R16                     ; Store data to UART Data Register
  RET                                  ; Return to caller
